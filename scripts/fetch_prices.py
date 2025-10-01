import os
import yfinance as yf
import pandas as pd
from supabase import create_client, Client
from datetime import date, datetime, timedelta
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
if not url or not key or not MARKET:
    raise RuntimeError("SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, and MARKET must be set in environment variables.")

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

if not is_trading_day(MARKET):
    print(f"[INFO] Today is not a trading day for {MARKET}, exiting.")
    exit(0)

# ---------------------------
# 取得最近的交易日
# ---------------------------
def get_last_trading_day(market: str) -> str:
    if market == "US":
        cal = mcal.get_calendar("NYSE")
    elif market == "JP":
        cal = mcal.get_calendar("JPX")
    else:
        raise ValueError(f"Unsupported market: {market}")

    now = datetime.now(cal.tz)  # 带市场时区
    today = now.date()

    # 往前推一周（足够覆盖周末/休市）
    schedule = cal.schedule(start_date=today - timedelta(days=7), end_date=today)

    # 取最后一个交易日
    if not schedule.empty:
        last_day = schedule.index[-1].date()
        return last_day.isoformat()
    else:
        return None

base_day = get_last_trading_day(MARKET)
if not base_day:
    print(f"[ERROR] Cannot determine last trading day for {MARKET}")
    exit(1)
print(f"[INFO] Base trading day for {MARKET} is {base_day}")

# ---------------------------
# supabase 分页查询所有数据
# ---------------------------
def fetch_all(supabase, table_name, select_cols="*", filters=None, page_size=500):
    """
    自动分页获取 Supabase 表的所有数据
    supabase: Supabase 客户端
    table_name: 表名
    select_cols: 要查询的列，默认 '*'
    filters: dict，等于条件，比如 {"exchange": "US"}
    page_size: 每次拉取的数量，默认 500
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
def fetch_all_failures_joined(supabase, market, page_size=500):
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
            .select("reason, stocks(id, ticker, exchange)")
            .eq("price_at", base_day)
            .eq("stocks.exchange", market)   # 关键过滤条件
            .eq("stocks.status", "active") # 只要 active 的
            .range(offset, offset + page_size - 1)
            .execute()
        )
        data = result.data
        if not data:
            break

        # 扁平化 stocks 数据
        for item in data:
            reason = item.get("reason", "")
            if "delisted" in reason.lower():
                continue  # 跳过退市的
            stock = item.get("stocks")
            if stock:
                all_data.append(stock)

        offset += page_size

    return all_data

# ---------------------------
# 下载函数（带重试，返回 {ticker: {"price": float, "price_at": str}}）
# ---------------------------
def download_with_retry(tickers, max_retries=3, delay=5):
    last_error = None
    for attempt in range(1, max_retries + 1):
        try:
            df = yf.download(
                tickers,
                period="1d",
                progress=False,
                group_by="ticker",
                auto_adjust=True,
                timeout=15,
            )
            print(f"[INFO] Downloaded data for {tickers[:3]}..., attempt {attempt}, rows: {len(df)}")

            result = {}
            if isinstance(df.columns, pd.MultiIndex):
                # 多 ticker
                for ticker in tickers:
                    try:
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

            return result, None

        except Exception as e:
            last_error = f"{type(e).__name__}: {str(e)}"
            print(f"[WARN] Attempt {attempt} failed for {tickers[:3]}...: {e}")
            if attempt < max_retries:
                time.sleep(delay + random.uniform(0, 2))
            else:
                return None, last_error

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
    delay = random.uniform(3, 5)  # 每个 batch 下载前加延迟
    print(f"[INFO] Sleeping {delay:.2f}s before next batch...")
    time.sleep(delay)
    tickers = [format_ticker(s["ticker"], s["exchange"]) for s in batch]
    data, error_reason = download_with_retry(tickers)

    rows = []
    failed_rows = []

    # 整个批次下载失败 → 单个再尝试
    if data is None:
        print(f"[INFO] Batch failed, falling back to single ticker fetch for {tickers[:3]}...")
        for s in batch:
            yfticker = format_ticker(s["ticker"], s["exchange"])
            single_data, single_error = download_with_retry([yfticker])
            price = single_data[yfticker]["price"] if single_data else None
            reason = single_error or "Download failed or NaN"
            if price is not None and not (math.isnan(price) or math.isinf(price)):
                rows.append({
                    "stock_id": s["id"],
                    "price": float(price),
                    "price_at": single_data[yfticker]["price_at"],
                })
            else:
                failed_rows.append({
                    "stock_id": s["id"],
                    "price_at": base_day,
                    "reason": reason
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
            single_data, single_error = download_with_retry([yfticker])
            single_price = single_data[yfticker]["price"] if single_data else None
            reason = single_error or "Download failed or NaN"

            if single_price is not None and not (math.isnan(single_price) or math.isinf(single_price)):
                rows.append({
                    "stock_id": s["id"],
                    "price": float(single_price),
                    "price_at": single_data[yfticker]["price_at"],
                })
            else:
                failed_rows.append({
                    "stock_id": s["id"],
                    "price_at": base_day,
                    "reason": reason
                })
                
    return rows, failed_rows

# ---------------------------
# 检查汇率是否已存在
# ---------------------------
def fetch_existing_fx_dates(supabase, fx_pair_id, start_day, end_day):
    res = supabase.table("fx_rates") \
        .select("rate_date") \
        .eq("fx_pair_id", fx_pair_id) \
        .gte("rate_date", start_day) \
        .lte("rate_date", end_day) \
        .execute()
    return {row["rate_date"] for row in res.data}

# ---------------------------
# 抓取 JPY=X 汇率
# ---------------------------
def fetch_jpy_fx_rate(start_day, end_day):
    try:
        df = yf.download(
            "JPY=X",
            start=start_day,
            end=(datetime.fromisoformat(end_day) + timedelta(days=1)).date().isoformat(),
            progress=False,
            group_by="ticker",
            auto_adjust=True,
            timeout=15,
        )
        rates = []
        if df is not None and not df.empty:
            if isinstance(df.columns, pd.MultiIndex):
                close = df[("JPY=X", "Close")]
            else:
                close = df["Close"]
            for dt, price in close.items():
                if not pd.isna(price) and not math.isinf(price):
                    rates.append({"rate_date": dt.date().isoformat(), "rate": float(price)})
        return rates
    except Exception as e:
        print(f"[ERROR] Failed to fetch JPY=X rate: {e}")
        return []

# ---------------------------
# 检查某日期的汇率是否存在，存在返回 True
# ---------------------------
def insert_missing_fx_rates(supabase, fx_pair_id, rates, existing_dates):
    to_insert = [
        {"fx_pair_id": fx_pair_id, "rate_date": r["rate_date"], "rate": r["rate"]}
        for r in rates if r["rate_date"] not in existing_dates
    ]
    if to_insert:
        supabase.table("fx_rates").insert(to_insert).execute()
        print(f"[OK] Inserted {len(to_insert)} missing FX rates")
    else:
        print("[INFO] No missing FX rates to insert")


# ---------------------------
# 获取前一个交易日
# ---------------------------
def get_prev_trading_day(base_day: str) -> str:
    cal = mcal.get_calendar("NYSE")
    base = datetime.fromisoformat(base_day).date()
    # 往前推10天，找前一个交易日
    schedule = cal.schedule(start_date=base - timedelta(days=10), end_date=base)
    prev_days = schedule.index[schedule.index.date < base]
    if len(prev_days) == 0:
        raise RuntimeError("No previous trading day found")
    return prev_days[-1].date().isoformat()

# ---------------------------
# 主逻辑
# ---------------------------
def main():
    # ---------------------------
    # 获取最近10个交易日的 JPY=X 汇率
    # ---------------------------
    end = get_prev_trading_day(base_day)
    start = end - timedelta(days=10)
    rates = fetch_jpy_fx_rate(start, end)
    print(f"[INFO] Fetched {len(rates)} FX rates from {start} to {end}")
    if not rates or len(rates) == 0:
        print("[WARN] No FX rates fetched")
    else:
        start_date = min(r["rate_date"] for r in rates)
        end_date = max(r["rate_date"] for r in rates)
        existing_dates = fetch_existing_fx_dates(supabase, 1, start_date, end_date)
        insert_missing_fx_rates(supabase, 1, rates, existing_dates)
    
    # ---------------------------
    # 查询待处理的股票
    # ---------------------------
    if isRetry:
        print("[INFO] Running in retry mode, exiting fetch_prices.py")
        stocks = fetch_all_failures_joined(supabase, MARKET)
    else:
        print(f"[INFO] Fetching prices for market {MARKET}")
        # 1. 查询 stocks 表
        stocks = fetch_all(
            supabase,
            "stocks",
            select_cols="id, ticker, exchange",
            filters={"exchange": MARKET, "status": "active"}
        )
        # 2. 查询 stock_prices（当天已有的）
        existing = fetch_all(
            supabase,
            "stock_prices",
            select_cols="stock_id, price_at",
            filters={"price_at": base_day}
        )
        done_ids = {x["stock_id"] for x in existing}
        # 3. 过滤掉已有的
        stocks = [s for s in stocks if s["id"] not in done_ids]

    if not stocks:
        print(f"[INFO] No stocks found for market {MARKET}")
        return

    batch_size = 50
    batches = [stocks[i:i + batch_size] for i in range(0, len(stocks), batch_size)]

    all_rows = []
    all_failed = []

    with ThreadPoolExecutor(max_workers=1) as executor:
        futures = [executor.submit(fetch_batch, batch) for batch in batches]
        for f in as_completed(futures):
            try:
                rows, failed = f.result()
                all_rows.extend(rows)
                all_failed.extend(failed)
            except TimeoutError:
                print(f"[ERROR] Batch fetch timed out")
            except Exception as e:
                print(f"[ERROR] Exception occurred: {e}")
            
    print(f"[INFO] Collected {len(all_rows)} raw rows for market {MARKET}")

    # ---------------------------
    # 删除已有的记录（按 price_at 分组，每组每500条删除）
    # ---------------------------
    from collections import defaultdict
    rows_by_date = defaultdict(list)
    for r in all_rows:
        rows_by_date[r["price_at"]].append(r)

    batch_size = 500
    for price_at, rows in rows_by_date.items():
        stock_ids = list({r["stock_id"] for r in rows})
        for i in range(0, len(stock_ids), batch_size):
            batch_ids = stock_ids[i:i + batch_size]
            supabase.table("stock_prices") \
                .delete() \
                .in_("stock_id", batch_ids) \
                .eq("price_at", price_at) \
                .execute()

    # ---------------------------
    # 去重 (保证 stock_id + price_at 唯一, 按日期分组)
    # ---------------------------
    deduped_rows_by_date = {}
    for price_at, rows in rows_by_date.items():
        unique = {}
        for r in rows:
            key = (r["stock_id"], r["price_at"])
            unique[key] = r
        deduped_rows_by_date[price_at] = list(unique.values())

    # ---------------------------
    # 插入新记录（所有日期合并，每500条一次性插入）
    # ---------------------------
    all_insert_rows = []
    for rows in deduped_rows_by_date.values():
        all_insert_rows.extend(rows)

    print(f"[INFO] Deduplicated rows, {len(all_insert_rows)} unique records remain")

    for i in range(0, len(all_insert_rows), batch_size):
        batch = all_insert_rows[i:i + batch_size]
        try:
            res = supabase.table("stock_prices").insert(batch).execute()
            print(f"[OK] Inserted {len(batch)} rows")
        except Exception as e:
            print(f"[ERROR] Exception on batch {i}: {e}")

    # ---------------------------
    # 删除已成功的失败记录（仅限最近交易日 base_day）
    # ---------------------------
    stock_ids = [s["id"] for s in stocks]
    if stock_ids:
        for i in range(0, len(stock_ids), batch_size):
            batch_ids = stock_ids[i:i + batch_size]
            supabase.table("stock_price_failures") \
                .delete() \
                .in_("stock_id", batch_ids) \
                .eq("price_at", base_day) \
                .execute()

    # ---------------------------
    # 保存失败记录（all_failed 里的每条 stock_id+base_day 只会有一条，不会重复）
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