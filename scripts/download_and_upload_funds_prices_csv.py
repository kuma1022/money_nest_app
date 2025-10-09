import os
import requests
from concurrent.futures import ThreadPoolExecutor, as_completed
from supabase import create_client, Client
from tqdm import tqdm

# ---------------------------
# Supabase 接続設定
# ---------------------------
SUPABASE_URL = os.environ.get("SUPABASE_URL")
SUPABASE_KEY = os.environ.get("SUPABASE_SERVICE_ROLE_KEY")
supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

BUCKET_NAME = "money_grow_app"
STORAGE_PATH = "funds_history_prices/"

# ---------------------------
# 下载单个基金 CSV 文件
# ---------------------------
def download_fund_csv(fund):
    isin_cd = fund["isin_cd"]
    code = fund["code"]
    filename = f"{code}_{isin_cd}.csv"
    url = f"https://toushin-lib.fwg.ne.jp/FdsWeb/FDST030000/csv-file-download?isinCd={isin_cd}&associFundCd={code}"

    try:
        resp = requests.get(url)
        resp.raise_for_status()
        with open(filename, "wb") as f:
            f.write(resp.content)
        return filename
    except Exception as e:
        print(f"[ERROR] Failed to download {filename}: {e}")
        return None

# ---------------------------
# 分批上传 CSV 文件
# ---------------------------
def upload_files_batch(file_list):
    for filepath in file_list:
        if not filepath:
            continue
        filename = os.path.basename(filepath)
        storage_path = f"{STORAGE_PATH}{filename}"
        try:
            supabase.storage.from_(BUCKET_NAME).upload(
                path=storage_path,
                file=filepath,
            )
        except Exception as e:
            print(f"[ERROR] Failed to upload {filename}: {e}")

# ---------------------------
# 分页获取所有 funds 数据
# ---------------------------
def get_all_funds(batch_size=500):
    all_funds = []
    offset = 0
    while True:
        res = (
            supabase.table("funds")
            .select("code,isin_cd")
            .range(offset, offset + batch_size - 1)
            .execute()
        )
        data = res.data or []
        if not data:
            break

        # Python 层过滤
        data = [row for row in data if row.get("isin_cd")]
        all_funds.extend(data)
        offset += batch_size

    print(f"[INFO] Total funds retrieved: {len(all_funds)}")
    return all_funds

# ---------------------------
# 主流程
# ---------------------------
def main():
    funds = get_all_funds()
    if not funds:
        print("[INFO] No funds to process.")
        return

    print(f"[INFO] Total funds to process: {len(funds)}")

    # 1️⃣ 并行下载 CSV 文件，带进度条
    downloaded_files = []
    max_workers = 10
    with ThreadPoolExecutor(max_workers=max_workers) as executor:
        futures = {executor.submit(download_fund_csv, fund): fund for fund in funds}
        for future in tqdm(as_completed(futures), total=len(funds), desc="Downloading CSVs"):
            file = future.result()
            if file:
                downloaded_files.append(file)

    print(f"[INFO] Total downloaded files: {len(downloaded_files)}")

    # 2️⃣ 分批上传，每批 50 个文件，上传也可并行，带进度条
    batch_size = 50
    batches = [downloaded_files[i:i + batch_size] for i in range(0, len(downloaded_files), batch_size)]
    with ThreadPoolExecutor(max_workers=5) as upload_executor:
        upload_futures = {upload_executor.submit(upload_files_batch, batch): batch for batch in batches}
        for future in tqdm(as_completed(upload_futures), total=len(batches), desc="Uploading batches"):
            future.result()

    print("[INFO] All files downloaded and uploaded successfully.")

if __name__ == "__main__":
    main()
