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
    res = supabase.storage.from_(BUCKET).list(SRC_PATH)
    return [f["name"] for f in res if f["name"].startswith("stock_prices") and f["name"].endswith(".csv")]

def read_csv_from_storage(path, chunksize=100_000):
    data = supabase.storage.from_(BUCKET).download(path)
    return pd.read_csv(io.BytesIO(data), chunksize=chunksize)

def download_stock_csv(exchange: str, ticker: str):
    path = f"{SRC_PATH}{exchange}/{ticker}.csv"
    try:
        data = supabase.storage.from_(BUCKET).download(path)
        df = pd.read_csv(io.BytesIO(data))
        # 删除全 NA 列，避免 concat warning
        df = df.dropna(axis=1, how='all')
        return df
    except Exception:
        return pd.DataFrame(columns=["stock_id","ticker","exchange","price","price_at"])

def upload_stock_csv(df: pd.DataFrame, exchange: str, ticker: str):
    path = f"{SRC_PATH}{exchange}/{ticker}.csv"
    csv_bytes = df.to_csv(index=False).encode("utf-8")
    supabase.storage.from_(BUCKET).upload(
        path,
        csv_bytes,
        file_options={"upsert": "true", "content-type": "text/csv"}
    )
    return len(df)

def load_processed_files():
    try:
        data = supabase.storage.from_(BUCKET).download(PROCESSED_FILE)
        return json.loads(data.decode("utf-8"))
    except Exception:
        return []

def save_processed_files(processed):
    data = json.dumps(processed, indent=2).encode("utf-8")
    supabase.storage.from_(BUCKET).upload(
        PROCESSED_FILE,
        data,
        file_options={"upsert": "true", "content-type": "application/json"}
    )

def process_new_file(file_name: str, stats: dict):
    path = f"{SRC_PATH}{file_name}"
    print(f"[PROCESS] {path}")

    for chunk in read_csv_from_storage(path):
        # 删除 chunk 中全 NA 列，保证 concat 安全
        chunk = chunk.dropna(axis=1, how='all')

        for (exchange, ticker), g in chunk.groupby(["exchange", "ticker"]):
            # 读旧数据
            df_old = download_stock_csv(exchange, ticker)
            old_rows = len(df_old)

            # 确保列对齐
            g = g.reindex(columns=df_old.columns)

            # 合并新数据
            df_new = pd.concat([df_old, g], ignore_index=True)

            # 去重 + 按日期排序
            df_new.drop_duplicates(
                subset=["stock_id", "ticker", "exchange", "price_at"], inplace=True
            )
            df_new.sort_values(by=["price_at"], inplace=True)

            new_rows = len(df_new) - old_rows
            total_rows = upload_stock_csv(df_new, exchange, ticker)

            # 更新统计
            stats["updated_stocks"] += 1
            stats["new_rows"] += max(new_rows, 0)

            print(f"  -> {exchange}/{ticker}: +{new_rows}, total={total_rows}")

def main():
    files = list_csv_files()
    print(f"[INFO] Found {len(files)} stock_prices csv files")

    processed = load_processed_files()
    new_files = [f for f in files if f not in processed]

    print(f"[INFO] New files to process: {new_files}")

    if not new_files:
        print("[DONE] No new files, nothing to update.")
        return

    stats = {"new_files": len(new_files), "updated_stocks": 0, "new_rows": 0}

    for f in new_files:
        process_new_file(f, stats)
        processed.append(f)

    save_processed_files(processed)

    # ---- 汇总日志 ----
    print("========== SUMMARY ==========")
    print(f"Processed new files : {stats['new_files']}")
    print(f"Updated stock files : {stats['updated_stocks']}")
    print(f"New rows inserted   : {stats['new_rows']}")
    print("=============================")

if __name__ == "__main__":
    main()
