import os
import json
import requests
from supabase import create_client, Client
from datetime import datetime, timezone

SUPABASE_URL = os.environ["SUPABASE_URL"]
SUPABASE_KEY = os.environ["SUPABASE_SERVICE_ROLE_KEY"]
supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

NASDAQ_URL = "https://www.nasdaqtrader.com/dynamic/symdir/nasdaqlisted.txt"
OTHER_URL = "https://www.nasdaqtrader.com/dynamic/symdir/otherlisted.txt"

BATCH_SIZE = 200

# ------------------------
# ファイルダウンロードと解析
# ------------------------
def download_text(url: str) -> str:
    res = requests.get(url)
    res.raise_for_status()
    return res.text

# ------------------------
# ファイル解析 (NASDAQ Listed)
# ------------------------
def parse_nasdaq_file(text: str):
    lines = text.strip().split("\n")
    headers = [h.strip() for h in lines.pop(0).split("|")]

    idx_symbol = headers.index("Symbol")
    idx_name = headers.index("Security Name")

    result = []
    for line in lines:
        parts = [p.strip() for p in line.split("|")]
        # カラム数がヘッダー未満の場合はスキップ
        if len(parts) <= max(idx_symbol, idx_name):
            continue
        # 必須カラムが空の場合はスキップ
        if not parts[idx_symbol] or not parts[idx_name]:
            continue

        ticker, file_name = formatTickerAndFileName(parts[idx_symbol])

        result.append({
            "ticker": ticker,
            "exchange": "US",
            "name": parts[idx_name],
            "name_us": parts[idx_name],
            "all_fetch_file_name": file_name,
            "status": "active",
            "currency": "USD",
            "country": "USA"
        })
    return result

# ------------------------
# ファイル解析 (Other Listed)
# ------------------------
def parse_other_file(text: str):
    lines = text.strip().split("\n")
    headers = [h.strip() for h in lines.pop(0).split("|")]

    idx_name = headers.index("Security Name")
    idx_nasdaq = headers.index("NASDAQ Symbol")

    result = []
    for line in lines:
        parts = [p.strip() for p in line.split("|")]

        # カラム数がヘッダー未満の場合はスキップ
        if len(parts) <= max(idx_name, idx_nasdaq):
            continue
        # 必須カラムが空の場合はスキップ
        if not parts[idx_nasdaq] or not parts[idx_name]:
            continue

        ticker, file_name = formatTickerAndFileName(parts[idx_nasdaq])

        result.append({
            "ticker": ticker,
            "exchange": "US",
            "name": parts[idx_name],
            "name_us": parts[idx_name],
            "all_fetch_file_name": file_name,
            "status": "active",
            "currency": "USD",
            "country": "USA"
        })
    return result

# ------------------------
# NASDAQ Symbol → ティッカーとファイル名
# ------------------------
def formatTickerAndFileName(nasdaq_symbol: str):
    
    ticker = nasdaq_symbol.replace("-", "-P").replace("+", "-WT").replace("=", "-UN").replace(".", "-")
    file_name = nasdaq_symbol.replace("-", "_").replace("+", "-WS").replace("=", "-U").replace(".", "-").lower() + ".us.txt"

    print(f"Ticker: {ticker}, FileName: {file_name}")
    return ticker, file_name

# ------------------------
# DB 更新
# ------------------------
def batch_update_insert(rows, batch_size=BATCH_SIZE):
    for i in range(0, len(rows), batch_size):
        batch = rows[i:i + batch_size]
        tickers = [r["ticker"] for r in batch]

        try:
            # 既存の NASDAQ Symbol を取得
            resp = supabase.table("stocks").select("ticker,exchange").in_("ticker", tickers).execute()
        except Exception as e:
            print(f"查询已有记录失败: {e}")
            continue

        existing_tickers = {r["ticker"] for r in resp.data}

        to_insert = []

        for r in batch:
            if r["ticker"] not in existing_tickers:
                to_insert.append(r)

        try:
            # 新規挿入
            if to_insert:
                supabase.table("stocks").insert(to_insert).execute()
        except Exception as e:
            print(f"插入失败: {e}")

        print(f"✅ 批次完成 [{i}-{i+len(batch)}], insert {len(to_insert)}")


# ------------------------
# 実行
# ------------------------
def main():
    print("🔹 Step 1: ダウンロード")
    nasdaq_text = download_text(NASDAQ_URL)
    other_text = download_text(OTHER_URL)

    print("🔹 Step 2: 解析")
    nasdaq_data = parse_nasdaq_file(nasdaq_text)
    other_data = parse_other_file(other_text)

    all_data = {f"{r['ticker']}-US": r for r in (nasdaq_data + other_data)}
    rows = list(all_data.values())

    print(f"🔹 Step 3: DB 更新 (total {len(rows)} 件)")
    batch_update_insert(rows)


if __name__ == "__main__":
    main()
