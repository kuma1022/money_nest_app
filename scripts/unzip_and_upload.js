import fs from "fs";
import path from "path";
import AdmZip from "adm-zip";
import { createClient } from "@supabase/supabase-js";

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
);

const zipPath = process.env.ZIP_PATH;
const targetBucket = process.env.TARGET_BUCKET;
const targetPrefix = process.env.TARGET_PREFIX || "";

const zip = new AdmZip(zipPath);
const entries = zip.getEntries().filter(e => !e.isDirectory);

console.log(`Found ${entries.length} files in ZIP`);

const batchSize = 50;
const maxRetries = 3;

async function uploadFile(entry) {
  const filePath = path.join(targetPrefix, entry.entryName);
  const content = entry.getData();

  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    const { error } = await supabase.storage
      .from(targetBucket)
      .upload(filePath, content, { upsert: true });

    if (!error) return true;
    console.log(`Retry ${attempt} failed for ${entry.entryName}: ${error.message}`);
  }
  return false;
}

async function uploadBatch(batch) {
  const results = await Promise.all(batch.map(uploadFile));
  const failed = batch.filter((_, i) => !results[i]);
  return failed;
}

async function main() {
  let failedFiles = [];

  for (let i = 0; i < entries.length; i += batchSize) {
    const batch = entries.slice(i, i + batchSize);
    const failed = await uploadBatch(batch);
    failedFiles.push(...failed);
    console.log(`Uploaded batch ${i / batchSize + 1}, failed: ${failed.length}`);
  }

  if (failedFiles.length > 0) {
    console.log(`Total failed files: ${failedFiles.length}`);
    failedFiles.forEach(f => console.log(f.entryName));
  } else {
    console.log("All files uploaded successfully!");
  }
}

main().catch(err => {
  console.error("Upload script failed:", err);
  process.exit(1);
});
