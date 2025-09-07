import os
import yfinance as yf
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
# 下载函数（带重试）
# ---------------------------
def download_with_retry(tickers, max_retries=3, delay=5):
    for attempt in range(1, max_retries + 1):
        try:
            data = yf.download(
                tickers,
                period="1d",
                progress=False,
                group_by="ticker",
                auto_adjust=True,
            )["Close"].iloc[-1]
            return data
        except Exception as e:
            print(f"[WARN] Attempt {attempt} failed for {tickers[:3]}...: {e}")
            if attempt < max_retries:
                time.sleep(delay + random.uniform(0, 2))
            else:
                return None

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
# 抓取单个批次（支持单 ticker 回退）
# ---------------------------
def fetch_batch(batch, today):
    tickers = [format_ticker(s["ticker"], s["exchange"]) for s in batch]
    data = download_with_retry(tickers)

    rows = []
    failed_rows = []

    # 如果批量失败 → 回退到单 ticker
    if data is None:
        print(f"[INFO] Batch failed, falling back to single ticker fetch for {tickers[:3]}...")
        for s in batch:
            yfticker = format_ticker(s["ticker"], s["exchange"])
            single_data = download_with_retry([yfticker])
            if single_data is not None:
                price = single_data[yfticker] if isinstance(single_data, dict) else single_data
                if price is not None and not (price != price):  # NaN 检查
                    rows.append({
                        "stock_id": s["id"],
                        "price": float(price),
                        "price_at": today,
                    })
                else:
                    failed_rows.append({"stock_id": s["id"], "price_at": today, "reason": "NaN"})
            else:
                failed_rows.append({"stock_id": s["id"], "price_at": today, "reason": "Download failed"})
        return rows, failed_rows

    # 批量成功 → 正常处理
    for s in batch:
        yfticker = format_ticker(s["ticker"], s["exchange"])
        try:
            price = data[yfticker] if isinstance(data, dict) else data[yfticker]
            if price is not None and not (price != price):
                rows.append({
                    "stock_id": s["id"],
                    "price": float(price),
                    "price_at": today,
                })
            else:
                failed_rows.append({"stock_id": s["id"], "price_at": today, "reason": "NaN"})
        except Exception as e:
            failed_rows.append({"stock_id": s["id"], "price_at": today, "reason": str(e)})
    return rows, failed_rows

# ---------------------------
# 主逻辑
# ---------------------------
def main():
    today = date.today().isoformat()
    stocks = supabase.table("stocks").select("id, ticker, exchange").eq("exchange", MARKET).limit(50).execute().data

    if not stocks:
        print(f"[INFO] No stocks found for market {MARKET}")
        return

    batch_size = 50
    batches = [stocks[i:i + batch_size] for i in range(0, len(stocks), batch_size)]

    all_rows = []
    all_failed = []

    with ThreadPoolExecutor(max_workers=5) as executor:
        futures = [executor.submit(fetch_batch, batch, today) for batch in batches]
        for f in as_completed(futures):
            rows, failed = f.result()
            all_rows.extend(rows)
            all_failed.extend(failed)

    print(f"[INFO] Collected {len(all_rows)} prices for market {MARKET}")

    # ---------------------------
    # 先删除当天已有的记录
    # ---------------------------
    if all_rows:
        stock_ids = list({r["stock_id"] for r in all_rows})
        supabase.table("stock_prices").delete().in_("stock_id", stock_ids).eq("price_at", today).execute()

    # ---------------------------
    # 分批插入新记录
    # ---------------------------
    batch_size = 500
    for i in range(0, len(all_rows), batch_size):
        batch = all_rows[i:i + batch_size]
        try:
            res = supabase.table("stock_prices").insert(batch).execute()
            if res.status_code >= 400:
                print(f"[ERROR] Failed batch {i}: {res.data}")
            else:
                print(f"[OK] Inserted {len(batch)} rows")
        except Exception as e:
            print(f"[ERROR] Exception on batch {i}: {e}")

    # ---------------------------
    # 保存失败记录
    # ---------------------------
    if all_failed:
        for i in range(0, len(all_failed), batch_size):
            batch = all_failed[i:i + batch_size]
            res = supabase.table("stock_price_failures").insert(batch).execute()
            if res.status_code >= 400:
                print(f"[ERROR] Failed to save failures batch {i}: {res.data}")
            else:
                print(f"[INFO] Saved {len(batch)} failed records")

if __name__ == "__main__":
    main()