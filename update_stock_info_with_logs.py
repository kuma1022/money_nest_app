import os
import yfinance as yf
from supabase import create_client, Client
from concurrent.futures import ThreadPoolExecutor, as_completed
import time

# -----------------------------
# 配置 Supabase
# -----------------------------
SUPABASE_URL = os.environ.get("SUPABASE_URL")
SUPABASE_KEY = os.environ.get("SUPABASE_SERVICE_ROLE_KEY")
supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

# -----------------------------
# 配置参数
# -----------------------------
BATCH_SIZE = 200
MAX_WORKERS = 5
SLEEP_BETWEEN_BATCHES = 1
RETRY_COUNT = 3
RETRY_DELAY = 2

# -----------------------------
# 获取 US 股票列表
# -----------------------------
def get_us_stocks():
    try:
        response = supabase.table("stocks").select("ticker").eq("exchange", "US").limit(10).execute()
        # 检查返回数据
        if response.data is None:
            raise Exception("Supabase 返回 data 为 None")
        return [row["ticker"] for row in response.data]
    except Exception as e:
        raise Exception(f"Supabase 获取股票列表异常: {e}")

# -----------------------------
# 获取单只股票信息（带重试）
# -----------------------------
def fetch_stock_info(ticker):
    for attempt in range(1, RETRY_COUNT + 1):
        try:
            t = yf.Ticker(ticker)
            info = t.info
            # print(f"✅ {info} 信息获取成功")
            return {
                "ticker": ticker,
                "exchange": "US",
                "sector": info.get("sector"),
                "industry": info.get("industry"),
                "currency": info.get("currency"),
                "country": info.get("country"),
                "isin": info.get("isin"),
                "success": True
            }
        except Exception as e:
            print(f"⚠️ {ticker} 信息获取失败，尝试 {attempt}/{RETRY_COUNT}: {e}")
            time.sleep(RETRY_DELAY)
    # 最终失败返回空信息
    return {
        "ticker": ticker,
        "exchange": "US",
        "sector": None,
        "industry": None,
        "currency": None,
        "country": None,
        "isin": None,
        "success": False
    }

# -----------------------------
# 批量更新 Supabase
# -----------------------------
def upsert_stocks(updates):
    for i in range(0, len(updates), BATCH_SIZE):
        batch = updates[i:i+BATCH_SIZE]
        # 去重 batch 中重复 ticker+exchange
        batch = list({ (d['ticker'], d['exchange']): d for d in batch }.values())
        try:
            response = supabase.table("stocks").upsert(batch, on_conflict=["ticker","exchange"]).execute()
            if response.data is None:
                print(f"❌ 批量 upsert 失败 [{i}-{i+len(batch)}]")
            else:
                print(f"✅ 批量 upsert 成功 [{i}-{i+len(batch)}]")
        except Exception as e:
            print(f"❌ 批量 upsert 异常 [{i}-{i+len(batch)}]: {e}")
        time.sleep(SLEEP_BETWEEN_BATCHES)

# -----------------------------
# 写入日志表
# -----------------------------
def write_log(total, success, fail, message=""):
    try:
        response = supabase.table("stock_update_logs").insert({
            "total_stocks": total,
            "success_count": success,
            "fail_count": fail,
            "message": message
        }).execute()
        if response.data is None:
            print(f"❌ 日志写入失败")
        else:
            print("✅ 日志写入成功")
    except Exception as e:
        print(f"❌ 日志写入异常: {e}")

# -----------------------------
# 主流程
# -----------------------------
def main():
    tickers = get_us_stocks()
    print(f"共获取 {len(tickers)} 支 US 股票")
    
    updates = []
    fail_count = 0
    success_count = 0

    with ThreadPoolExecutor(max_workers=MAX_WORKERS) as executor:
        future_to_ticker = {executor.submit(fetch_stock_info, t): t for t in tickers}
        for idx, future in enumerate(as_completed(future_to_ticker), 1):
            ticker = future_to_ticker[future]
            info = future.result()
            print(f"✅ {info} 信息获取成功")
            if info.get("success"):
                # 移除 success 字段并加入 updates
                info.pop("success", None)  # 如果不存在也不会报错
                updates.append(info)
                success_count += 1
            else:
                fail_count += 1
            print(f"[{idx}/{len(tickers)}] {ticker} 信息抓取完成 - 成功: {success_count}, 失败: {fail_count}")

    print("开始批量更新 Supabase...")
    upsert_stocks(updates)
    print("全部完成 ✅")

    # 写入日志表
    write_log(total=len(tickers), success=success_count, fail=fail_count)
    print("日志写入完成 📄")

if __name__ == "__main__":
    main()
