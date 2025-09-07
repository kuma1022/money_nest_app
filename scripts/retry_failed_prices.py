import os
import math
from datetime import datetime
from concurrent.futures import ThreadPoolExecutor, as_completed

import yfinance as yf
from supabase import create_client

supabase = create_client(os.environ.get("SUPABASE_URL"), os.environ.get("SUPABASE_SERVICE_ROLE_KEY"))

def download_with_retry(tickers, max_retries=3, delay=5):
    import time, random
    for attempt in range(1, max_retries + 1):
        try:
            data = yf.download(tickers, period="1d", progress=False, group_by="ticker")["Close"].iloc[-1]
            return data
        except:
            if attempt < max_retries:
                time.sleep(delay + random.uniform(0, 2))
            else:
                return None

def format_ticker(ticker, market):
    if market == "JP":
        return f"{ticker}.T"
    return ticker

def fetch_batch(batch):
    tickers = [format_ticker(s["ticker"], s["market"]) for s in batch]
    data = download_with_retry(tickers)
    rows, failed = [], []

    if data is not None:
        price_date = data.index[-1].date().isoformat()
        for s in batch:
            yfticker = format_ticker(s["ticker"], s["market"])
            try:
                price = data[yfticker] if yfticker in data else None
                if price is not None and not math.isnan(price):
                    rows.append({"stock_id": s["stock_id"], "price": float(price), "price_at": price_date})
                else:
                    failed.append(s)
            except:
                failed.append(s)
    else:
        failed.extend(batch)

    return rows, failed

def main():
    failed_stocks = supabase.table("stock_price_failures").select("*").execute().data
    if not failed_stocks:
        print("[INFO] No failed stocks to retry")
        return

    batch_size = 20
    batches = [failed_stocks[i:i+batch_size] for i in range(0, len(failed_stocks), batch_size)]
    all_rows, all_remaining_failed = [], []

    with ThreadPoolExecutor(max_workers=5) as executor:
        futures = [executor.submit(fetch_batch, batch) for batch in batches]
        for f in as_completed(futures):
            rows, remaining_failed = f.result()
            all_rows.extend(rows)
            all_remaining_failed.extend(remaining_failed)

    # 写入成功价格
    for i in range(0, len(all_rows), 500):
        supabase.table("stock_prices").upsert(all_rows[i:i+500]).execute()

    # 删除成功记录
    success_ids = [r["stock_id"] for r in all_rows]
    if success_ids:
        supabase.table("stock_price_failures").delete().in_("stock_id", success_ids).execute()

    print(f"[INFO] Retry completed: {len(all_rows)} recovered, {len(all_remaining_failed)} still failed")

if __name__ == "__main__":
    main()
