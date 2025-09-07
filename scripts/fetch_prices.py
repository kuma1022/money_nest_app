import os
import math
import sys
import time
import random
from datetime import datetime
from concurrent.futures import ThreadPoolExecutor, as_completed

import yfinance as yf
import pandas_market_calendars as mcal
from supabase import create_client, Client

# ---------------------------
# Supabase 初始化
# ---------------------------
url = os.environ.get("SUPABASE_URL")
key = os.environ.get("SUPABASE_SERVICE_ROLE_KEY")
supabase: Client = create_client(url, key)
MARKET = os.environ.get("MARKET", "US")  # 默认 US

# ---------------------------
# 判断交易日
# ---------------------------
def is_trading_day(market: str) -> bool:
    if market == "US":
        cal = mcal.get_calendar('NYSE')
        now = datetime.now().astimezone(cal.tz)
    elif market == "JP":
        cal = mcal.get_calendar('JPX')
        now = datetime.now().astimezone(cal.tz)
    else:
        return True
    schedule = cal.schedule(start_date=now.date(), end_date=now.date())
    return True #not schedule.empty

if not is_trading_day(MARKET):
    print(f"[INFO] Today is not a trading day for {MARKET}, exiting.")
    sys.exit(0)

# ---------------------------
# 下载函数（带重试）
# ---------------------------
def download_with_retry(tickers, max_retries=3, delay=5):
    for attempt in range(1, max_retries + 1):
        try:
            data = yf.download(tickers, period="1d", progress=False, group_by="ticker")["Close"].iloc[-1]
            return data
        except Exception as e:
            print(f"[WARN] Attempt {attempt} failed for {tickers[:3]}...: {e}")
            if attempt < max_retries:
                time.sleep(delay + random.uniform(0, 2))
            else:
                return None

# ---------------------------
# 格式化 ticker
# ---------------------------
def format_ticker(ticker, exchange):
    if exchange == "TSE":
        return f"{ticker}.T"
    elif exchange == "US":
        return ticker
    else:
        return ticker

# ---------------------------
# 抓取单个批次
# ---------------------------
def fetch_batch(batch):
    tickers = [format_ticker(s["ticker"], s["exchange"]) for s in batch]
    data = download_with_retry(tickers)
    rows, failed = [], []

    if data is not None:
        # 获取实际交易日
        price_date = data.index[-1].date().isoformat()
        for s in batch:
            yfticker = format_ticker(s["ticker"], s["exchange"])
            try:
                if isinstance(data, dict):
                    price = data.get(yfticker)
                else:
                    price = data[yfticker] if yfticker in data else None

                if price is not None and not math.isnan(price):
                    rows.append({
                        "stock_id": s["id"],
                        "price": float(price),
                        "price_at": price_date,
                    })
                else:
                    failed.append({"stock_id": s["id"], "ticker": s["ticker"], "market": MARKET, "reason": "price missing"})
            except Exception as e:
                failed.append({"stock_id": s["id"], "ticker": s["ticker"], "market": MARKET, "reason": str(e)})
    else:
        for s in batch:
            failed.append({"stock_id": s["id"], "ticker": s["ticker"], "market": MARKET, "reason": "download failed"})

    return rows, failed

# ---------------------------
# 主逻辑
# ---------------------------
def main():
    exchange_map = {"US": "US", "JP": "TSE"}
    exchange_filter = exchange_map.get(MARKET, "US")

    stocks = supabase.table("stocks").select("id, ticker, exchange").limit(100) \
        .eq("exchange", exchange_filter).execute().data

    if not stocks:
        print(f"[INFO] No stocks found for market {MARKET}")
        return

    batch_size = 30
    batches = [stocks[i:i + batch_size] for i in range(0, len(stocks), batch_size)]
    all_rows, all_failed = [], []

    with ThreadPoolExecutor(max_workers=5) as executor:
        futures = [executor.submit(fetch_batch, batch) for batch in batches]
        for f in as_completed(futures):
            rows, failed = f.result()
            all_rows.extend(rows)
            all_failed.extend(failed)

    print(f"[INFO] Collected {len(all_rows)} prices for market {MARKET}")

    # 分批写入价格
    for i in range(0, len(all_rows), 500):
        batch = all_rows[i:i+500]
        supabase.table("stock_prices").upsert(batch).execute()

    # 分批写入失败记录
    if all_failed:
        for i in range(0, len(all_failed), 500):
            batch = all_failed[i:i+500]
            supabase.table("stock_price_failures").upsert(batch).execute()

if __name__ == "__main__":
    main()
