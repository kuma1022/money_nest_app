import os
import yfinance as yf
import pandas as pd
import math
from supabase import create_client, Client
from datetime import date, datetime
import time, random
from concurrent.futures import ThreadPoolExecutor, as_completed
import pandas_market_calendars as mcal

# ---------------------------
# Supabase 初始化
# ---------------------------
url = os.environ.get("SUPABASE_URL")
key = os.environ.get("SUPABASE_SERVICE_ROLE_KEY")
supabase: Client = create_client(url, key)
MARKET = os.environ.get("MARKET")

# ---------------------------
# 下载函数（带重试，返回 {ticker: {"price": float, "price_at": str}}）
# ---------------------------
def download_with_retry(tickers, max_retries=3, delay=5):
    for attempt in range(1, max_retries + 1):
        try:
            df = yf.download(
                tickers,
                period="1d",
                progress=False,
                group_by="ticker",
                auto_adjust=True,
            )
            if df.empty:
                raise ValueError("No data returned")

            # 单 ticker 时修正 MultiIndex
            if isinstance(df.columns, pd.Index):
                df.columns = pd.MultiIndex.from_product([tickers, df.columns])

            trade_date = df.index[-1].date().isoformat()
            print(f"[INFO] Downloaded data for {tickers[:3]}..., attempt {attempt}, rows: {len(df)}")
            return df, trade_date
        except Exception as e:
            print(f"[WARN] Attempt {attempt} failed for {tickers[:3]}...: {e}")
            if attempt < max_retries:
                time.sleep(delay + random.uniform(0, 2))
            else:
                return None, None

# ---------------------------
# 判断交易日
# ---------------------------
def is_trading_day(market: str) -> bool:
    if market == "US":
        cal = mcal.get_calendar("NYSE")
        now = datetime.now().astimezone(cal.tz)
    elif market == "JP":
        cal = mcal.get_calendar("JPX")
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
    if exchange == "JP":  # 日股
        return f"{ticker}.T"
    elif exchange == "US":  # 美股
        return ticker
    else:
        return ticker

# ---------------------------
# 抓取单个批次（支持单 ticker 回退，price_at 使用交易日）
# ---------------------------
def fetch_batch(batch):
    tickers = [format_ticker(s["ticker"], s["exchange"]) for s in batch]
    data, trade_date = download_with_retry(tickers)

    rows = []
    failed_rows = []

    if data is None:
        print(f"[INFO] Batch failed, falling back to single ticker fetch for {tickers[:3]}...")
        for s in batch:
            yfticker = format_ticker(s["ticker"], s["exchange"])
            single_data, single_trade_date = download_with_retry([yfticker])
            trade_date = single_trade_date or date.today().isoformat()

            if single_data is not None:
                price = single_data[yfticker]["Close"].iloc[-1] if isinstance(single_data, pd.DataFrame) else single_data
                if price is not None and not (price != price) and math.isfinite(price):
                    rows.append({"stock_id": s["id"], "price": float(price), "price_at": trade_date})
                else:
                    failed_rows.append({"stock_id": s["id"], "price_at": trade_date, "reason": "Invalid price"})
            else:
                failed_rows.append({"stock_id": s["id"], "price_at": trade_date, "reason": "Download failed"})
        return rows, failed_rows

    # 批量成功
    for s in batch:
        yfticker = format_ticker(s["ticker"], s["exchange"])
        try:
            price = data[yfticker]["Close"].iloc[-1]
            if price is not None and not (price != price) and math.isfinite(price):
                rows.append({"stock_id": s["id"], "price": float(price), "price_at": trade_date})
            else:
                failed_rows.append({"stock_id": s["id"], "price_at": trade_date, "reason": "Invalid price"})
        except Exception as e:
            failed_rows.append({"stock_id": s["id"], "price_at": trade_date, "reason": str(e)})
    return rows, failed_rows

# ---------------------------
# 主逻辑
# ---------------------------
def main():
    stocks = supabase.table("stocks").select("id, ticker, exchange").eq("exchange", MARKET).limit(10).execute().data
    if not stocks:
        print(f"[INFO] No stocks found for market {MARKET}")
        return

    batch_size = 50
    batches = [stocks[i:i + batch_size] for i in range(0, len(stocks), batch_size)]

    all_rows = []
    all_failed = []

    with ThreadPoolExecutor(max_workers=5) as executor:
        futures = [executor.submit(fetch_batch, batch) for batch in batches]
        for f in as_completed(futures):
            rows, failed = f.result()
            all_rows.extend(rows)
            all_failed.extend(failed)

    print(f"[INFO] Collected {len(all_rows)} prices for market {MARKET}")

    # ---------------------------
    # 删除已有记录
    # ---------------------------
    if all_rows:
        stock_ids = list({r["stock_id"] for r in all_rows})
        supabase.table("stock_prices").delete().in_("stock_id", stock_ids).eq("price_at", all_rows[0]["price_at"]).execute()

    # ---------------------------
    # 插入新记录
    # ---------------------------
    batch_size = 500
    for i in range(0, len(all_rows), batch_size):
        batch = all_rows[i:i + batch_size]
        try:
            supabase.table("stock_prices").insert(batch).execute()
            print(f"[OK] Inserted {len(batch)} rows")
        except Exception as e:
            print(f"[ERROR] Exception on batch {i}: {e}")

    # ---------------------------
    # 保存失败记录
    # ---------------------------
    if all_failed:
        for i in range(0, len(all_failed), batch_size):
            batch = all_failed[i:i + batch_size]
            try:
                supabase.table("stock_price_failures").insert(batch).execute()
                print(f"[INFO] Saved {len(batch)} failed records")
            except Exception as e:
                print(f"[ERROR] Failed to save failures batch {i}: {e}")

if __name__ == "__main__":
    main()