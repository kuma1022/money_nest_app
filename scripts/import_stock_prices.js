import { createClient } from "@supabase/supabase-js";
import pLimit from "p-limit"; // 限制并发

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!supabaseUrl || !supabaseKey) {
  console.error("SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY missing!");
  process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseKey);
const BUCKET = "money_grow_app";

const FILE_BATCH = 50;          // 每次处理多少个文件
const MAX_UPSERT_SIZE_MB = 1;   // 每次 upsert 最大约 1MB
const MAX_CONCURRENCY = 5;      // 同时下载/处理的文件数
const SKIP_DATE = "2025-09-05"; // ✅ 新增：跳过判断的基准日期

// 递归列出所有文件
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

// 下载文件 + 重试
async function downloadWithRetry(path, retries = 3) {
  for (let i = 0; i < retries; i++) {
    const { data, error } = await supabase.storage.from(BUCKET).download(path);
    if (!error && data) return data;
    console.error(`Download failed (${i+1}/${retries}): ${path}`, error?.message || error);
    await new Promise(r => setTimeout(r, 1000 * (i + 1))); // 递增等待
  }
  return null;
}

// 处理单个文件
async function processFile(filePath, stockMap) {
  const data = await downloadWithRetry(filePath, 5);
  if (!data) {
    console.error(`Failed to download after retries: ${filePath}`);
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
    if (parseInt(date) < 20161001) continue;

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

// ✅ 新增：批量过滤已导入的文件
async function filterAlreadyImported(batchFiles, stockMap) {
  const stockIds = batchFiles.map(f => {
    const filename = f.split("/").pop(); // eg: 9900.jp.txt
    const [ticker, exchange] = filename.replace(".txt", "").split(".");
    return stockMap.get(`${ticker.toUpperCase()}.${exchange.toUpperCase()}`);
  }).filter(Boolean);

  if (stockIds.length === 0) return batchFiles;

  const { data, error } = await supabase
    .from("stock_prices")
    .select("stock_id")
    .in("stock_id", stockIds)
    .neq("price_at", SKIP_DATE);  // 关键：过滤掉只有 SKIP_DATE 的情况

  if (error) {
    console.error("Batch check failed:", error);
    return batchFiles; // 查询失败时，不跳过
  }

  const importedIds = new Set(data.map(d => d.stock_id));

  return batchFiles.filter(f => {
    const filename = f.split("/").pop();
    const [ticker, exchange] = filename.replace(".txt", "").split(".");
    const stockId = stockMap.get(`${ticker}.${exchange.toUpperCase()}`);
    return !importedIds.has(stockId);
  });
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

  let totalImported = 0;
  const limit = pLimit(MAX_CONCURRENCY);

  for (let i = 0; i < allFiles.length; i += FILE_BATCH) {
    let batchFiles = allFiles.slice(i, i + FILE_BATCH);

    // ✅ 新增：批量过滤
    batchFiles = await filterAlreadyImported(batchFiles, stockMap);
    if (batchFiles.length === 0) {
      console.log(`Batch ${i + 1} ~ ${i + FILE_BATCH} 全部已导入，跳过`);
      continue;
    }

    console.log(`Processing files ${i + 1} ~ ${i + batchFiles.length}`);

    const results = await Promise.all(
      batchFiles.map((file) => limit(() => processFile(file, stockMap)))
    );

    totalImported += results.reduce((a, b) => a + b, 0);
  }

  console.log(`All done! Total imported records: ${totalImported}`);
}

main().catch((err) => {
  console.error("Fatal error:", err);
  process.exit(1);
});
