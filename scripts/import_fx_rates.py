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

# 读取 CSV
df = pd.read_csv(CSV_FILE)

# 只保留 Date 和 Price
df = df[["Date", "Price"]]

# 转换日期格式和数值
df["Date"] = pd.to_datetime(df["Date"], format="%m/%d/%Y").dt.date
df["Price"] = pd.to_numeric(df["Price"], errors="coerce")

# 构造要插入的字典列表
records = [
    {
        "fx_pair_id": 1,
        "rate_date": row["Date"].isoformat(),
        "rate": float(row["Price"]),
    }
    for _, row in df.iterrows()
    if pd.notnull(row["Price"])
]

# 每 500 条批量插入
batch_size = 500
for i in range(0, len(records), batch_size):
    batch = records[i : i + batch_size]
    resp = supabase.table("fx_rates").insert(batch).execute()
    if resp.get("error"):
        print("Error inserting batch:", resp["error"])
    else:
        print(f"Inserted batch {i // batch_size + 1} ({len(batch)} rows)")
