import os
import yfinance as yf
import pandas as pd
from supabase import create_client, Client
from datetime import date
import time, random
import math
from concurrent.futures import ThreadPoolExecutor, as_completed
import pandas_market_calendars as mcal

# ---------------------------
# Supabase 初始化
# ---------------------------
url = os.environ.get("SUPABASE_URL")
key = os.environ.get("SUPABASE_SERVICE_ROLE_KEY")
supabase: Client = create_client(url, key)
MARKET = os.environ.get("MARKET")
isRetry = os.environ.get("IS_RETRY", "0") == "1"

# ---------------------------
# supabase 分页查询所有数据
# ---------------------------
def fetch_all(supabase, table_name, select_cols="*", filters=None, page_size=1000):
    """
    自动分页获取 Supabase 表的所有数据
    supabase: Supabase 客户端
    table_name: 表名
    select_cols: 要查询的列，默认 '*'
    filters: dict，等于条件，比如 {"exchange": "US"}
    page_size: 每次拉取的数量，默认 1000
    """
    all_data = []
    offset = 0

    while True:
        query = supabase.table(table_name).select(select_cols)
        if filters:
            for k, v in filters.items():
                query = query.eq(k, v)

        result = query.range(offset, offset + page_size - 1).execute()
        data = result.data
        if not data:
            break
        all_data.extend(data)
        offset += page_size

    return all_data

# ---------------------------
# supabase 分页查询所有失败数据
# ---------------------------
def fetch_all_failures_joined(supabase, page_size=1000):
    """
    获取 stock_price_failures 对应的 stocks 信息
    直接在 Supabase 端做 JOIN，相当于：
    SELECT s.id, s.ticker, s.exchange
    FROM stock_price_failures spf
    JOIN stocks s ON spf.stock_id = s.id
    支持分页拉取
    """
    all_data = []
    offset = 0

    while True:
        # 使用嵌套 select，通过 foreign key 显式条件
        result = (
            supabase.table("stock_price_failures")
            .select("stocks(id, ticker, exchange)")
            .range(offset, offset + page_size - 1)
            .execute()
        )
        data = result.data
        if not data:
            break

        # 扁平化 stocks 数据
        for item in data:
            stock = item.get("stocks")
            if stock:
                all_data.append(stock)

        offset += page_size

    return all_data

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
            print(f"[INFO] Downloaded data for {tickers[:3]}..., attempt {attempt}, rows: {len(df)}")

            result = {}
            if isinstance(df.columns, pd.MultiIndex):
                # 多 ticker
                for ticker in tickers:
                    try:
                        print(f"[DEBUG] Processing ticker {ticker}: {df[ticker].head()}")
                        price = df[ticker]["Close"].iloc[-1]
                        if pd.isna(price) or math.isinf(price):
                            price = None
                        price_at = df.index[-1].date().isoformat()
                        result[ticker] = {"price": price, "price_at": price_at}
                    except Exception:
                        result[ticker] = {"price": None, "price_at": None}
            else:  # 单 ticker
                price = df["Close"].iloc[-1]
                if pd.isna(price) or math.isinf(price):
                    price = None
                price_at = df.index[-1].date().isoformat()
                result[tickers[0]] = {"price": price, "price_at": price_at}

            return result

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
# 抓取单个批次（支持单 ticker 回退，price_at 使用交易日）
# ---------------------------
def fetch_batch(batch):
    time.sleep(random.uniform(5, 10))  # 每个 batch 下载前加延迟
    tickers = [format_ticker(s["ticker"], s["exchange"]) for s in batch]
    data = download_with_retry(tickers)

    rows = []
    failed_rows = []

    # 整个批次下载失败 → 单个再尝试
    if data is None:
        print(f"[INFO] Batch failed, falling back to single ticker fetch for {tickers[:3]}...")
        for s in batch:
            yfticker = format_ticker(s["ticker"], s["exchange"])
            single_data = download_with_retry([yfticker])
            price = single_data[yfticker]["price"] if single_data else None
            if price is not None and not (math.isnan(price) or math.isinf(price)):
                rows.append({
                    "stock_id": s["id"],
                    "price": float(price),
                    "price_at": single_data[yfticker]["price_at"],
                })
            else:
                failed_rows.append({
                    "stock_id": s["id"],
                    "price_at": date.today().isoformat(),
                    "reason": "Download failed or NaN"
                })
        return rows, failed_rows

    # 批量成功 → 对单个价格为 None/NaN 的再尝试
    for s in batch:
        yfticker = format_ticker(s["ticker"], s["exchange"])
        price = data[yfticker]["price"]

        if price is not None and not (math.isnan(price) or math.isinf(price)):
            rows.append({
                "stock_id": s["id"],
                "price": float(price),
                "price_at": data[yfticker]["price_at"],
            })
        else:
            # 单独下载失败 ticker
            single_data = download_with_retry([yfticker])
            single_price = single_data[yfticker]["price"] if single_data else None

            if single_price is not None and not (math.isnan(single_price) or math.isinf(single_price)):
                rows.append({
                    "stock_id": s["id"],
                    "price": float(single_price),
                    "price_at": single_data[yfticker]["price_at"],
                })
            else:
                failed_rows.append({
                    "stock_id": s["id"],
                    "price_at": date.today().isoformat(),
                    "reason": "Download failed or NaN"
                })
                
    return rows, failed_rows

# ---------------------------
# 主逻辑
# ---------------------------
def main():
    if isRetry:
        print("[INFO] Running in retry mode, exiting fetch_prices.py")
        stocks = fetch_all_failures_joined(supabase)
    else:
        print(f"[INFO] Fetching prices for market {MARKET}")
        stocks = fetch_all(
            supabase,
            "stocks",
            select_cols="id, ticker, exchange",
            filters={"exchange": MARKET}
        )
    if not stocks:
        print(f"[INFO] No stocks found for market {MARKET}")
        return

    batch_size = 50
    batches = [stocks[i:i + batch_size] for i in range(0, len(stocks), batch_size)]

    all_rows = []
    all_failed = []

    with ThreadPoolExecutor(max_workers=2) as executor:
        futures = [executor.submit(fetch_batch, batch) for batch in batches]
        for f in as_completed(futures):
            rows, failed = f.result()
            all_rows.extend(rows)
            all_failed.extend(failed)

    print(f"[INFO] Collected {len(all_rows)} prices for market {MARKET}")

    # ---------------------------
    # 删除当天已有的记录
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
            res = supabase.table("stock_prices").insert(batch).execute()
            print(f"[OK] Inserted {len(batch)} rows")
        except Exception as e:
            print(f"[ERROR] Exception on batch {i}: {e}")

    # ---------------------------
    # 删除已成功的失败记录
    # ---------------------------
    if isRetry:
        stock_ids = [s["id"] for s in stocks]
        if stock_ids:
            supabase.table("stock_price_failures") \
                .delete() \
                .in_("stock_id", stock_ids) \
                .execute()

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