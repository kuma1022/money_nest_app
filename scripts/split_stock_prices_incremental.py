import os
import io
import json
import pandas as pd
from supabase import create_client, Client

# ---------------------------
# Supabase 初始化
# ---------------------------
url = os.environ.get("SUPABASE_URL")
key = os.environ.get("SUPABASE_SERVICE_ROLE_KEY")
supabase: Client = create_client(url, key)

BUCKET = "money_grow_app"
SRC_PATH = "historical_prices/"
PROCESSED_FILE = f"{SRC_PATH}processed_files.json"

def list_csv_files():
    """列出所有 stock_prices_xxx.csv 文件"""
    res = supabase.storage.from_(BUCKET).list(SRC_PATH)
    return [f["name"] for f in res if f["name"].startswith("stock_prices") and f["name"].endswith(".csv")]

def read_csv_from_storage(path, chunksize=100_000):
    """按块读取大CSV"""
    data = supabase.storage.from_(BUCKET).download(path)
    return pd.read_csv(io.BytesIO(data), chunksize=chunksize)

def download_stock_csv(exchange: str, ticker: str):
    """下载目标股票CSV，如果不存在则返回空DataFrame"""
    path = f"{SRC_PATH}{exchange}/{ticker}.csv"
    try:
        data = supabase.storage.from_(BUCKET).download(path)
        return pd.read_csv(io.BytesIO(data))
    except Exception:
        return pd.DataFrame(columns=["stock_id","ticker","exchange","price","price_at"])

def upload_stock_csv(df: pd.DataFrame, exchange: str, ticker: str):
    """上传股票CSV"""
    path = f"{SRC_PATH}{exchange}/{ticker}.csv"
    csv_bytes = df.to_csv(index=False).encode("utf-8")
    supabase.storage.from_(BUCKET).upload(path, csv_bytes, {"upsert": True})
    print(f"[UPLOAD] {path}, rows={len(df)}")

def load_processed_files():
    """读取 processed_files.json"""
    try:
        data = supabase.storage.from_(BUCKET).download(PROCESSED_FILE)
        return json.loads(data.decode("utf-8"))
    except Exception:
        return []

def save_processed_files(processed):
    """保存 processed_files.json"""
    data = json.dumps(processed, indent=2).encode("utf-8")
    supabase.storage.from_(BUCKET).upload(PROCESSED_FILE, data, {"upsert": True})
    print(f"[UPDATE] processed_files.json updated, total={len(processed)}")

def process_new_file(file_name: str):
    """处理单个 stock_prices_xxx.csv 文件"""
    path = f"{SRC_PATH}{file_name}"
    print(f"Processing {path} ...")

    for chunk in read_csv_from_storage(path):
        for (exchange, ticker), g in chunk.groupby(["exchange", "ticker"]):
            # 读旧数据
            df_old = download_stock_csv(exchange, ticker)

            # 合并新数据
            df_new = pd.concat([df_old, g], ignore_index=True)

            # 去重 + 按日期排序
            df_new.drop_duplicates(
                subset=["stock_id", "ticker", "exchange", "price_at"], inplace=True
            )
            df_new.sort_values(by=["price_at"], inplace=True)

            # 上传
            upload_stock_csv(df_new, exchange, ticker)

def main():
    files = list_csv_files()
    print(f"Found {len(files)} csv files")

    # 已处理文件
    processed = load_processed_files()

    # 找出未处理的新文件
    new_files = [f for f in files if f not in processed]
    print(f"New files to process: {new_files}")

    if not new_files:
        print("No new files. Done.")
        return

    for f in new_files:
        process_new_file(f)
        processed.append(f)

    # 更新 processed_files.json
    save_processed_files(processed)

if __name__ == "__main__":
    main()
