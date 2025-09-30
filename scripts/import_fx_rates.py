import os
import pandas as pd
from supabase import create_client, Client
from datetime import datetime

# 从环境变量读取 Supabase 配置
SUPABASE_URL = os.environ.get("SUPABASE_URL")
SUPABASE_KEY = os.environ.get("SUPABASE_SERVICE_ROLE_KEY")  # 建议用 service_role key

if not SUPABASE_URL or not SUPABASE_KEY:
    raise ValueError("Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY environment variables")

supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

# CSV 文件路径 (可以在 GitHub Actions workflow 里传入)
CSV_FILE = os.environ.get("FX_RATES_CSV", "scripts/data/fx_rates.csv")

# --- 读取 CSV ---
df = pd.read_csv(CSV_FILE)
df = df[["Date", "Price"]]
df["Date"] = pd.to_datetime(df["Date"], format="%m/%d/%Y").dt.date
df["Price"] = pd.to_numeric(df["Price"], errors="coerce")

# --- 构造所有记录 ---
records = [
    {"fx_pair_id": 1, "rate_date": row["Date"].isoformat(), "rate": float(row["Price"])}
    for _, row in df.iterrows() if pd.notnull(row["Price"])
]

print(f"Prepared {len(records)} records to process")

batch_size = 500
for i in range(0, len(records), batch_size):
    batch = records[i:i+batch_size]

    # 1️⃣ 查询已有 rate_date
    dates = [r["rate_date"] for r in batch]
    existing_resp = supabase.table("fx_rates") \
        .select("rate_date") \
        .eq("fx_pair_id", 1) \
        .in_("rate_date", dates) \
        .execute()

    existing_dates = set()
    if existing_resp.data:
        existing_dates = set([r["rate_date"] for r in existing_resp.data])

    # 2️⃣ 分 insert 和 update
    insert_list = [r for r in batch if r["rate_date"] not in existing_dates]
    update_list = [r for r in batch if r["rate_date"] in existing_dates]

    # 3️⃣ 批量 insert
    if insert_list:
        resp = supabase.table("fx_rates").insert(insert_list).execute()
        if resp.error:
            print(f"Error inserting batch {i//batch_size+1}: {resp.error}")
        else:
            print(f"Inserted {len(insert_list)} rows in batch {i//batch_size+1}")

    # 4️⃣ 批量 update（单条 update）
    #if update_list:
    #    for r in update_list:
    #        resp = supabase.table("fx_rates") \
    #            .update({"rate": r["rate"]}) \
    #            .eq("fx_pair_id", 1) \
    #            .eq("rate_date", r["rate_date"]) \
    #            .execute()
    #        if resp.error:
    #            print(f"Error updating rate_date {r['rate_date']}: {resp.error}")
    #    print(f"Updated {len(update_list)} rows in batch {i//batch_size+1}")