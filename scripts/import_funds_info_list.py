import os
import requests
import pandas as pd
from supabase import create_client, Client

# ---------------------------
# Supabase 接続設定
# ---------------------------
SUPABASE_URL = os.environ.get("SUPABASE_URL")
SUPABASE_KEY = os.environ.get("SUPABASE_SERVICE_ROLE_KEY")  # Service Role Key 推奨
supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

# ---------------------------
# Excel ファイルダウンロード
# ---------------------------
EXCEL_URL = "https://www.toushin.or.jp/files/static/486/unlisted_fund_for_investor.xlsx"
LOCAL_FILE = "/tmp/unlisted_fund_for_investor.xlsx"


def download_excel():
    print("[INFO] Downloading Excel file...")
    response = requests.get(EXCEL_URL)
    response.raise_for_status()
    with open(LOCAL_FILE, "wb") as f:
        f.write(response.content)
    print("[INFO] Download complete:", LOCAL_FILE)


# ---------------------------
# Excel を解析して DataFrame 作成
# ---------------------------
def parse_excel():
    print("[INFO] Parsing Excel file...")
    df = pd.read_excel(LOCAL_FILE, sheet_name="対象商品一覧", header=1)

    # 必要な列だけ抽出 & rename
    df = df.rename(
        columns={
            "投信協会ファンドコード": "code",
            "ファンド名称": "name",
            "運用会社名": "management_company",
            "設定日": "foundation_date",
            "つみたて投資枠の対象・非対象": "tsumitate_flag",
        }
    )

    # 文字列化 & 日付型変換
    df["code"] = df["code"].astype(str).str.strip()
    df["name"] = df["name"].astype(str).str.strip()
    df["management_company"] = df["management_company"].astype(str).str.strip()
    df["foundation_date"] = pd.to_datetime(df["foundation_date"], errors="coerce").dt.date

    # tsumitate_flag を Boolean に変換
    def to_bool(val):
        if str(val).strip() == "対象":
            return True
        elif str(val).strip() == "非対象":
            return False
        else:
            return None  # 空欄や不明な場合

    df["tsumitate_flag"] = df["tsumitate_flag"].apply(to_bool)

    print(f"[INFO] Parsed {len(df)} rows")
    return df


# ---------------------------
# Supabase へ UPSERT（バッチ対応）
# ---------------------------
def sync_to_supabase(df: pd.DataFrame, batch_size: int = 500):
    print("[INFO] Syncing to Supabase in batches...")

    # DataFrame を dict のリストに変換
    records = df.to_dict(orient="records")

    # batch_size ごとに分割して UPSERT
    for i in range(0, len(records), batch_size):
        batch = records[i : i + batch_size]
        try:
            supabase.table("funds").upsert(batch, on_conflict=["code"]).execute()
            print(f"[OK] Upserted batch {i + 1} to {i + len(batch)}")
        except Exception as e:
            print(f"[ERROR] Failed for batch {i + 1} to {i + len(batch)}: {e}")


# ---------------------------
# メイン処理
# ---------------------------
def main():
    download_excel()
    df = parse_excel()
    sync_to_supabase(df)


if __name__ == "__main__":
    main()
