import os
import json
import requests
from supabase import create_client, Client
from datetime import datetime

SUPABASE_URL = os.environ["SUPABASE_URL"]
SUPABASE_KEY = os.environ["SUPABASE_SERVICE_ROLE_KEY"]
supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

NASDAQ_URL = "https://www.nasdaqtrader.com/dynamic/symdir/nasdaqlisted.txt"
OTHER_URL = "https://www.nasdaqtrader.com/dynamic/symdir/otherlisted.txt"

BATCH_SIZE = 100

# ------------------------
# 例外読み込み
# ------------------------
with open("scripts/data/yahoo_exceptions.json", "r") as f:
    YAHOO_EXCEPTIONS = json.load(f)


# ------------------------
# ユーティリティ
# ------------------------
def normalize_ticker_for_yahoo(symbol: str) -> str:
    """ファイル内 NASDAQ Symbol → Yahoo Finance 用ティッカー"""
    if not symbol:
        return symbol
    if symbol in YAHOO_EXCEPTIONS:
        return YAHOO_EXCEPTIONS[symbol]
    return symbol.replace(".", "-")


def download_text(url: str) -> str:
    res = requests.get(url)
    res.raise_for_status()
    return res.text


def parse_file(text: str):
    lines = text.strip().split("\n")
    headers = lines.pop(0).split("|")

    idx_act = headers.index("ACT Symbol")
    idx_name = headers.index("Security Name")
    idx_nasdaq = headers.index("NASDAQ Symbol")

    result = []
    for line in lines:
        parts = line.split("|")
        if not parts[idx_nasdaq] or not parts[idx_name]:
            continue

        act_symbol_raw = parts[idx_act]
        nasdaq_symbol_raw = parts[idx_nasdaq]

        ticker = normalize_ticker_for_yahoo(nasdaq_symbol_raw)
        act_symbol = act_symbol_raw.replace(".", "-").replace("$", "_")  # ACT Symbol も正規化

        result.append({
            "ticker": ticker,
            "ticker_before": nasdaq_symbol_raw,
            "exchange": "US",
            "name": parts[idx_name],
            "name_us": parts[idx_name],
            "act_symbol": act_symbol,
            "status": "active",
            "currency": "USD",
            "country": "USA"
        })
    return result


# ------------------------
# DB 更新
# ------------------------
def batch_update_insert(rows, batch_size=BATCH_SIZE):
    for i in range(0, len(rows), batch_size):
        batch = rows[i:i + batch_size]
        tickers = [r["ticker"] for r in batch]
        act_symbols = [r["act_symbol"] for r in batch]
        ticker_befores = [r["ticker_before"] for r in batch]
        all_tickers = list(set(tickers + act_symbols + ticker_befores))

        # 既存の NASDAQ Symbol / ACT Symbol を取得
        resp = supabase.table("stocks").select("ticker,exchange").in_("ticker", all_tickers).execute()
        if resp.error:
            print(f"查询已有记录失败: {resp.error}")
            continue

        existing_tickers = {r["ticker"] for r in resp.data}

        to_insert, to_update, to_rename_act, to_rename_before = [], [], [], []

        for r in batch:
            if r["ticker"] in existing_tickers:
                to_update.append(r)
            elif r["act_symbol"] in existing_tickers:
                to_rename_act.append(r)
            elif r["ticker_before"] in existing_tickers:
                to_rename_before.append(r)
            else:
                to_insert.append(r)

        # ACT Symbol → NASDAQ/Yahoo ティッカーに更新
        for r in to_rename_act:
            upd_resp = supabase.table("stocks").update({
                "ticker": r["ticker"],
                "name_us": r["name_us"],
                "updated_at": datetime.now(datetime.timezone.utc)
            }).eq("ticker", r["act_symbol"]).eq("exchange", r["exchange"]).execute()
            if upd_resp.error:
                print(f"ACT→NASDAQ 更新失败: {r['act_symbol']} → {r['ticker']} {upd_resp.error}")

        # Before Symbol → NASDAQ/Yahoo ティッカーに更新
        for r in to_rename_before:
            upd_resp = supabase.table("stocks").update({
                "ticker": r["ticker"],
                "name_us": r["name_us"],
                "updated_at": datetime.now(datetime.timezone.utc)
            }).eq("ticker", r["ticker_before"]).eq("exchange", r["exchange"]).execute()
            if upd_resp.error:
                print(f"Before→NASDAQ 更新失败: {r['ticker_before']} → {r['ticker']} {upd_resp.error}")
            else:
                print(f"🔄 Before→NASDAQ 更新: {r['ticker_before']} → {r['ticker']}")

        # 既存 NASDAQ Symbol 更新
        #for r in to_update:
        #    upd_resp = supabase.table("stocks").update({
        #        "name_us": r["name_us"],
        #        "updated_at": datetime.now(datetime.timezone.utc)
        #    }).eq("ticker", r["ticker"]).eq("exchange", r["exchange"]).execute()
        #    if upd_resp.error:
        #        print(f"更新失败: {r['ticker']}, {upd_resp.error}")

        # 新規挿入
        if to_insert:
            # 去掉 act_symbol 字段
            to_insert_clean = [
                {k: v for k, v in r.items() if k != "act_symbol" and k != "ticker_before"}
                for r in to_insert
            ]
            ins_resp = supabase.table("stocks").insert(to_insert_clean).execute()
            if ins_resp.error:
                print(f"插入失败: {ins_resp.error}")

        print(f"✅ 批次完成 [{i}-{i+len(batch)}], 更新 {len(to_update)}, rename {len(to_rename_act)}, rename_before {len(to_rename_before)}, insert {len(to_insert)}")


# ------------------------
# 実行
# ------------------------
def main():
    print("🔹 Step 1: ダウンロード")
    nasdaq_text = download_text(NASDAQ_URL)
    other_text = download_text(OTHER_URL)

    print("🔹 Step 2: 解析")
    nasdaq_data = parse_file(nasdaq_text)
    other_data = parse_file(other_text)

    all_data = {f"{r['ticker']}-US": r for r in (nasdaq_data + other_data)}
    rows = list(all_data.values())

    print(f"🔹 Step 3: DB 更新 (total {len(rows)} 件)")
    batch_update_insert(rows)


if __name__ == "__main__":
    main()
