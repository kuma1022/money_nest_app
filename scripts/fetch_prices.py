import os
import time
import random
from datetime import date, datetime
from concurrent.futures import ThreadPoolExecutor, as_completed

import yfinance as yf
import pandas_market_calendars as mcal
from supabase import create_client

# ---------------------------
# Supabase 初始化
# ---------------------------
url = os.environ.get("SUPABASE_URL")
key = os.environ.get("SUPABASE_SERVICE_ROLE_KEY")
supabase = create_client(url, key)
MARKET = os.environ.get("MARKET", "US")

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
    return not schedule.empty

#if not is_trading_day(MARKET):
#    print(f"[INFO] Today is not a trading day for {MARKET}, exiting.")
#    exit(0)

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
# 单只股票下载函数（带重试）
# ---------------------------
def download_price(ticker, max_retries=3, delay=5):
    for attempt in range(1, max_retries + 1):
        try:
            df = yf.download(ticker, period="1d", progress=False, auto_adjust=False)
            if df.empty:
                raise ValueError("Empty DataFrame")
            price = df["Close"].iloc[-1]
            price_date = df.index[-1].date().isoformat()
            return price, price_date
        except Exception as e:
            print(f"[WARN] Attempt {attempt} failed for {ticker}: {e}")
            if attempt < max_retries:
                time.sleep(delay + random.uniform(0, 2))
            else:
                return None, str(e)

# ---------------------------
# 抓取批次
# ---------------------------
def fetch_batch(batch):
    rows, failed = [], []
    for s in batch:
        yfticker = format_ticker(s["ticker"], s["exchange"])
        price, result = download_price(yfticker)
        if price is not None:
            rows.append({
                "stock_id": s["id"],
                "price": float(price),
                "price_at": result
            })
        else:
            failed.append({
                "stock_id": s["id"],
                "ticker": s["ticker"],
                "market": MARKET,
                "reason": result
            })
    return rows, failed

# ---------------------------
# 主逻辑
# ---------------------------
def main():
    # 获取股票列表
    exchange_map = {"US": "US", "JP": "TSE"}
    exchange_filter = exchange_map.get(MARKET, "US")

    stocks = supabase.table("stocks").select("id, ticker, exchange") \
        .eq("exchange", exchange_filter).execute().data

    if not stocks:
        print(f"[INFO] No stocks found for market {MARKET}")
        return

    # 分批（线程池处理）
    batch_size = 20
    batches = [stocks[i:i+batch_size] for i in range(0, len(stocks), batch_size)]
    all_rows, all_failed = [], []

    with ThreadPoolExecutor(max_workers=5) as executor:
        futures = [executor.submit(fetch_batch, batch) for batch in batches]
        for f in as_completed(futures):
            rows, failed = f.result()
            all_rows.extend(rows)
            all_failed.extend(failed)

    print(f"[INFO] Collected {len(all_rows)} prices for market {MARKET}")

    # 写入 stock_prices
    for i in range(0, len(all_rows), 500):
        batch = all_rows[i:i+500]
        res = supabase.table("stock_prices").upsert(batch).execute()
        if res.error:
            print(f"[ERROR] Failed batch {i}: {res.error}")
        else:
            print(f"[OK] Upserted {len(batch)} rows")

    # 写入失败记录
    if all_failed:
        for i in range(0, len(all_failed), 500):
            batch = all_failed[i:i+500]
            supabase.table("stock_price_failures").upsert(batch).execute()
        print(f"[INFO] {len(all_failed)} stocks failed and written to stock_price_failures")

if __name__ == "__main__":
    main()
