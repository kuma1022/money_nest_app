import os
import time
import sys
import requests
from concurrent.futures import ThreadPoolExecutor, as_completed
from supabase import create_client, Client
from tqdm import tqdm
import pandas_market_calendars as mcal
from datetime import datetime, timedelta

# ---------------------------
# Supabase 接続設定
# ---------------------------
SUPABASE_URL = os.environ.get("SUPABASE_URL")
SUPABASE_KEY = os.environ.get("SUPABASE_SERVICE_ROLE_KEY")
supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

BUCKET_NAME = "money_grow_app"
STORAGE_PATH = "funds_history_prices/"

# ---------------------------
# 判断交易日
# ---------------------------
def is_trading_day(market: str) -> bool:
    if market == "US":
        cal = mcal.get_calendar("NYSE")
    elif market == "JP":
        cal = mcal.get_calendar("JPX")
    else:
        return True

    now = datetime.now().astimezone(cal.tz)
    # 看昨天是不是交易日
    prev_day = now.date() - timedelta(days=1)
    schedule = cal.schedule(start_date=prev_day, end_date=prev_day)
    return not schedule.empty

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
        for attempt in range(1, 4):  # 最多重试3次
            try:
                bucket = supabase.storage.from_(BUCKET_NAME)
                # 先删除旧文件（如果存在）
                try:
                    bucket.remove([storage_path])
                except Exception as e:
                    # 删除失败（文件不存在等情况）忽略
                    pass

                # 再上传
                bucket.upload(
                    path=storage_path,
                    file=filepath,
                )
                break  # 成功就跳出重试循环
            except Exception as e:
                if "Duplicate" in str(e):
                    print(f"[WARNING] Duplicate file {filename} already exists.")
                    break  # 文件已存在，跳出重试循环
                if attempt < 3:
                    wait_time = 1 * attempt  # 指数退避，例如 1s, 2s
                    #print(f"[INFO] Retrying in {wait_time}s...")
                    time.sleep(wait_time)
                else:
                    print(f"[ERROR] Failed to upload {filename} after 3 attempts")

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
    # 仅在交易日运行
    if not (is_trading_day("JP")):
        print("[INFO] Today is not a trading day. Exiting.")
        sys.exit(0)
        
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

    # 2️⃣ 分批上传，每批 20 个文件，上传也可并行，带进度条
    batch_size = 20
    batches = [downloaded_files[i:i + batch_size] for i in range(0, len(downloaded_files), batch_size)]
    with ThreadPoolExecutor(max_workers=5) as upload_executor:
        upload_futures = {upload_executor.submit(upload_files_batch, batch): batch for batch in batches}
        for future in tqdm(as_completed(upload_futures), total=len(batches), desc="Uploading batches"):
            future.result()

    print("[INFO] All files downloaded and uploaded successfully.")
    sys.exit(0)  # 强制退出


if __name__ == "__main__":
    main()
