import { createClient } from "@supabase/supabase-js";

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!supabaseUrl || !supabaseKey) {
  console.error("SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY missing!");
  process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseKey);
const BUCKET = "money_grow_app";

const FILE_BATCH = 50;      // 每次处理多少个文件
const MAX_UPSERT_SIZE_MB = 1; // 每次 upsert 最大约 1MB

async function listAllFiles(bucket, prefix) {
  let files = [];
  let offset = 0;
  const limit = 1000;

  while (true) {
    const { data, error } = await supabase.storage
      .from(bucket)
      .list(prefix, { limit, offset, recursive: true });

    if (error) throw error;
    if (!data || data.length === 0) break;

    for (const item of data) {
      if (item.name.toLowerCase().endsWith(".txt")) {
        files.push(`${prefix}/${item.name}`);
      } else if (!item.name.includes(".")) {
        const subFiles = await listAllFiles(bucket, `${prefix}/${item.name}`);
        files = files.concat(subFiles);
      }
    }

    if (data.length < limit) break;
    offset += data.length;
  }
  return files;
}

async function processFile(filePath, stockMap) {
  const { data, error } = await supabase.storage.from(BUCKET).download(filePath);
  if (error || !data) {
    console.error(`Download error: ${filePath}`, error);
    return 0;
  }

  const text = await data.text();
  const lines = text.split("\n").filter((l) => l.trim().length > 0);
  let count = 0;
  let batch = [];
  let batchSizeBytes = 0;

  for (const line of lines) {
    if (line.startsWith("<")) continue;
    const [ticker, _per, date, _time, _open, _high, _low, close] = line.split(",");
    if (parseInt(date) < 20150101) continue;

    const stockId = stockMap.get(ticker);
    if (!stockId) continue;

    const record = {
      stock_id: stockId,
      price: parseFloat(close),
      price_at: date.replace(/(\d{4})(\d{2})(\d{2})/, "$1-$2-$3"),
    };

    batch.push(record);
    batchSizeBytes += JSON.stringify(record).length;

    // 如果累计大小超过约 1MB，则先 upsert
    if (batchSizeBytes >= MAX_UPSERT_SIZE_MB * 1024 * 1024) {
      const { error: upsertErr } = await supabase
        .from("stock_prices")
        .upsert(batch, { onConflict: "stock_id,price_at" });
      if (upsertErr) console.error("Upsert error:", upsertErr);
      batch = [];
      batchSizeBytes = 0;
    }
    count++;
  }

  if (batch.length > 0) {
    const { error: upsertErr } = await supabase
      .from("stock_prices")
      .upsert(batch, { onConflict: "stock_id,price_at" });
    if (upsertErr) console.error("Upsert error:", upsertErr);
  }

  return count;
}

async function main() {
  const market = process.argv[2] || "jp";
  console.log("Processing market:", market);

  const { data: stocks, error: stockErr } = await supabase
    .from("stocks")
    .select("id,ticker,exchange");
  if (stockErr || !stocks) throw stockErr;

  const stockMap = new Map(stocks.map((s) => [`${s.ticker}.${s.exchange}`, s.id]));

  const allFiles = await listAllFiles(BUCKET, `upload/${market}`);
  console.log(`Total files found: ${allFiles.length}`);

  for (let i = 0; i < allFiles.length; i += FILE_BATCH) {
    const batchFiles = allFiles.slice(i, i + FILE_BATCH);
    console.log(`Processing files ${i + 1} ~ ${i + batchFiles.length}`);
    for (const file of batchFiles) {
      await processFile(file, stockMap);
    }
  }

  console.log("All done!");
}

main().catch((err) => {
  console.error("Fatal error:", err);
  process.exit(1);
});
