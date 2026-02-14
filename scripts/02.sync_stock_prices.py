import os
import io
import pandas as pd
import yfinance as yf
from datetime import datetime, timedelta
from supabase import create_client, Client

# 环境配置
SUPABASE_URL = os.environ["SUPABASE_URL"]
SUPABASE_KEY = os.environ["SUPABASE_SERVICE_ROLE_KEY"]
BUCKET_NAME = "money_grow_app"
STORAGE_PATH = "historical_prices"

supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

def get_monitored_stocks(only_new=False):
    """获取需要同步的股票"""
    query = supabase.table("stocks").select("ticker, last_synced_at").eq("is_monitored", True)
    if only_new:
        query = query.is_("last_synced_at", "null")
    res = query.execute()
    return res.data

def download_from_storage(ticker):
    """从 Storage 下载现有的 CSV"""
    file_path = f"{STORAGE_PATH}/{ticker}.csv"
    try:
        res = supabase.storage.from_(BUCKET_NAME).download(file_path)
        return pd.read_csv(io.BytesIO(res), index_col="price_at", parse_dates=True)
    except:
        return None

def upload_to_storage(ticker, df):
    """将 DataFrame 上传到 Storage"""
    # 格式化输出: price_at, price
    df.index.name = "price_at"
    df.columns = ["price"]
    csv_data = df.to_csv(index=True, date_format='%Y-%m-%d')
    
    file_path = f"{STORAGE_PATH}/{ticker}.csv"
    # 上传 (使用 upsert=True 覆盖)
    supabase.storage.from_(BUCKET_NAME).upload(
        path=file_path,
        file=csv_data.encode(),
        file_options={"content-type": "text/csv", "x-upsert": "true"}
    )

def update_last_synced(ticker):
    """更新数据库同步时间"""
    today = datetime.now().strftime('%Y-%m-%d')
    supabase.table("stocks").update({"last_synced_at": today}).eq("ticker", ticker).execute()

def process_stock(stock, force_full=False):
    ticker = stock["ticker"]
    last_synced = stock.get("last_synced_at")
    
    try:
        if force_full or not last_synced:
            # --- 全量获取 (2010年以后) ---
            df = yf.download(ticker, start="2010-01-01", auto_adjust=False, actions=True, progress=False)
            if df.empty: return
            new_df = df[['Adj Close']].copy()
        else:
            # --- 增量检查 ---
            # 1. 检查最近 5 天是否有分割
            check_df = yf.download(ticker, period="5d", actions=True, progress=False)
            if check_df['Stock Splits'].any():
                print(f"⚠️ {ticker} 检测到分割，触发全量重刷")
                df = yf.download(ticker, start="2010-01-01", auto_adjust=False, actions=True, progress=False)
                new_df = df[['Adj Close']].copy()
            else:
                # 2. 无分割，下载增量部分
                start_date = (datetime.strptime(last_synced, '%Y-%m-%d') + timedelta(days=1)).strftime('%Y-%m-%d')
                incremental_df = yf.download(ticker, start=start_date, auto_adjust=False, progress=False)
                if incremental_df.empty: 
                    update_last_synced(ticker)
                    return
                
                # 读取旧数据并合并
                old_df = download_from_storage(ticker)
                if old_df is None: # 兜底逻辑：如果没有旧文件，则全量
                    df = yf.download(ticker, start="2010-01-01", auto_adjust=False, progress=False)
                    new_df = df[['Adj Close']].copy()
                else:
                    added_df = incremental_df[['Adj Close']].copy()
                    added_df.columns = ["price"]
                    # 合并去重
                    new_df = pd.concat([old_df, added_df])
                    new_df = new_df[~new_df.index.duplicated(keep='last')].sort_index()

        # 执行上传和 DB 更新
        upload_to_storage(ticker, new_df)
        update_last_synced(ticker)
        print(f"✅ {ticker} 同步成功")

    except Exception as e:
        print(f"❌ {ticker} 处理失败: {e}")

if __name__ == "__main__":
    import sys
    mode = sys.argv[1] if len(sys.argv) > 1 else "normal"
    
    if mode == "initial":
        stocks = get_monitored_stocks(only_new=False)
        for s in stocks: process_stock(s, force_full=True)
    else:
        # 1. 处理新添加的股票
        new_stocks = get_monitored_stocks(only_new=True)
        for s in new_stocks: process_stock(s, force_full=True)
        # 2. 处理已有股票的增量更新
        existing_stocks = [s for s in get_monitored_stocks() if s.get("last_synced_at")]
        for s in existing_stocks: process_stock(s, force_full=False)