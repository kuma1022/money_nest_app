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
# 单只股票下载函数（带重试 + 安全 float）
# ---------------------------
def download_price(ticker, max_retries=3, delay=5):
    for attempt in range(1, max_retries + 1):
        try:
            df = yf.download(ticker, period="1d", progress=False, auto_adjust=False)
            if df.empty or "Close" not in df.columns:
                raise ValueError("Empty DataFrame or no Close column")

            price_series = df["Close"].iloc[-1]

            # 安全转换 float
            if isinstance(price_series, (float, int)):
                price = float(price_series)
            else:
                # 如果仍然是 Series
                price = float(price_series.values[-1])

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
                "price": price,
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
    exchange_map = {"US": "US", "JP": "TSE"}
    exchange_filter = exchange_map.get(MARKET, "US")

    stocks = supabase.table("stocks").select("id, ticker, exchange").limit(50) \
        .eq("exchange", exchange_filter).execute().data

    if not stocks:
        print(f"[INFO] No stocks found for market {MARKET}")
        return

    # 分批处理
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

    # 写入 stock_prices，on_conflict 与唯一索引字段匹配
    for i in range(0, len(all_rows), 500):
        batch = all_rows[i:i+500]
        try:
            supabase.table("stock_prices").upsert(
                batch,
                on_conflict=["stock_id", "price_at"]  # 必须与唯一索引字段完全一致
            ).execute()
            print(f"[OK] Upserted {len(batch)} rows")
        except Exception as e:
            print(f"[ERROR] Failed batch {i}: {e}")

    # 写入 stock_price_failures，确保唯一约束字段匹配
    if all_failed:
        for i in range(0, len(all_failed), 500):
            batch = all_failed[i:i+500]
            try:
                supabase.table("stock_price_failures").upsert(
                    batch,
                    on_conflict=["stock_id", "market", "ticker"]
                ).execute()
            except Exception as e:
                print(f"[ERROR] Failed to insert failures batch {i}: {e}")
        print(f"[INFO] {len(all_failed)} stocks failed and written to stock_price_failures")

if __name__ == "__main__":
    main()
