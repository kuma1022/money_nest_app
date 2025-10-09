import os
import requests
import urllib.parse
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

# ---------------------------
# API 情報（投資信託情報検索用）
# ---------------------------
API_URL = "https://toushin-lib.fwg.ne.jp/FdsWeb/FDST999900/fundDataSearch"
API_HEADERS = {
    "Accept": "application/json, text/javascript, */*; q=0.01",
    "Content-Type": "application/x-www-form-urlencoded;charset=UTF-8",
}

# ---------------------------
# 投資信託情報を API から取得
# ---------------------------
def fetch_fund_info(name: str):
    """APIからisin_cd, associ_fund_cdを取得"""
    payload = {
        "s_keyword": urllib.parse.quote(name),
        "s_kensakuKbn": "1",
        "s_supplementKindCd": "1",
        "f_etfKBun": "1",
        "s_standardPriceCond1": "0",
        "s_standardPriceCond2": "0",
        "s_riskCond1": "0",
        "s_riskCond2": "0",
        "s_sharpCond1": "0",
        "s_sharpCond2": "0",
        "s_buyFee": "1",
        "s_trustReward": "1",
        "s_monthlyCancelCreateVal": "1",
        "startNo": "0",
        "draw": "4",
        "searchBtnClickFlg": "true",
    }

    print(f"[INFO] Fetching fund info for: {name}")
    print(f"[DEBUG] Payload: {payload}")

    resp = requests.post(API_URL, headers=API_HEADERS, data=payload)
    print(f"[DEBUG] Response: {resp}")

    resp.raise_for_status()
    data = resp.json()

    if not data.get("resultInfoMapList"):
        return {}

    info = data["resultInfoMapList"][0]
    return {
        "isin_cd": info.get("isinCd"),
    }

def download_excel():
    print("[INFO] Downloading Excel file...")
    response = requests.get(EXCEL_URL)
    response.raise_for_status()
    with open(LOCAL_FILE, "wb") as f:
        f.write(response.content)
    # 为了测试，只下载前10行数据
    df = pd.read_excel(LOCAL_FILE, sheet_name="対象商品一覧", header=1)
    df.head(10).to_excel(LOCAL_FILE, index=False)
    
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
def sync_to_supabase(df: pd.DataFrame, batch_size: int = 500, lookup_size: int = 100):
    print("[INFO] Syncing to Supabase in batches...")

    # DataFrame を dict のリストに変換（foundation_date は ISO 文字列に変換）
    records = []
    # コードごとにまとめて既存データを取得
    codes = df["code"].tolist()
    existing_map = {}

    for i in range(0, len(codes), lookup_size):
        chunk = codes[i:i + lookup_size]
        res = supabase.table("funds").select("code,isin_cd").in_("code", chunk).execute()
        for row in res.data or []:
            existing_map[row["code"]] = {
                "isin_cd": row.get("isin_cd"),
            }

    # データ作成
    for _, row in df.iterrows():
        record = {
            "code": row["code"],
            "name": row["name"],
            "management_company": row["management_company"],
            "foundation_date": row["foundation_date"].isoformat() if pd.notnull(row["foundation_date"]) else None,
            "tsumitate_flag": row["tsumitate_flag"],
        }

        existing = existing_map.get(row["code"])
        if not existing or not existing.get("isin_cd"):
            # API呼び出しして不足分を取得
            api_data = fetch_fund_info(row["name"])
            record.update(api_data)

        records.append(record)

    # Supabaseへアップサート
    for i in range(0, len(records), batch_size):
        batch = records[i:i + batch_size]
        try:
            supabase.table("funds").upsert(batch, on_conflict=["code"]).execute()
            print(f"[OK] Upserted batch {i+1} to {i+len(batch)}")
        except Exception as e:
            print(f"[ERROR] Failed for batch {i+1} to {i+len(batch)}: {e}")


# ---------------------------
# メイン処理
# ---------------------------
def main():
    download_excel()
    df = parse_excel()
    sync_to_supabase(df)


if __name__ == "__main__":
    main()
