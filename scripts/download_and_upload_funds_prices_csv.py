import os
import time
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
# 下载并上传单个基金 CSV 文件
# ---------------------------
def download_and_upload_one(fund):
    isin_cd = fund["isin_cd"]
    code = fund["code"]
    filename = f"{code}_{isin_cd}.csv"
    filepath = os.path.join("/tmp", filename)
    url = f"https://toushin-lib.fwg.ne.jp/FdsWeb/FDST030000/csv-file-download?isinCd={isin_cd}&associFundCd={code}"

    # 下载 CSV
    try:
        resp = requests.get(url)
        resp.raise_for_status()
        with open(filepath, "wb") as f:
            f.write(resp.content)
    except Exception as e:
        print(f"[ERROR] Failed to download {filename}: {e}")
        return False

    # 上传 CSV，最多重试3次
    storage_path = f"{STORAGE_PATH}{filename}"
    for attempt in range(1, 4):
        try:
            supabase.storage.from_(BUCKET_NAME).upload(
                path=storage_path,
                file=filepath,
            )
            return True  # 成功
        except Exception as e:
            print(f"[WARN] Attempt {attempt} failed for {filename}: {e}")
            if attempt < 3:
                time.sleep(2 * attempt)
            else:
                print(f"[ERROR] Failed to upload {filename} after 3 attempts")
                return False

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

    # 并行下载+上传
    max_workers = 10
    success_count = 0
    with ThreadPoolExecutor(max_workers=max_workers) as executor:
        futures = {executor.submit(download_and_upload_one, fund): fund for fund in funds}
        for future in tqdm(as_completed(futures), total=len(funds), desc="Processing funds"):
            if future.result():
                success_count += 1

    print(f"[INFO] Completed. Successfully processed {success_count}/{len(funds)} funds.")

if __name__ == "__main__":
    main()
