// Verifies that the ID and EN dictionaries share an identical structure
// (same keys, same array lengths, same nested shapes). Values differ, structure must not.
import path from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";

const here = path.dirname(fileURLToPath(import.meta.url));
const tsPath = path.join(here, "..", "src", "i18n", "index.ts");

let mod;
try {
  mod = await import(pathToFileURL(tsPath).href);
} catch (err) {
  console.error("check-i18n: cannot import", tsPath);
  console.error(String(err && err.message ? err.message : err));
  process.exit(2);
}

const { dict } = mod;
if (!dict || !dict.id || !dict.en) {
  console.error("check-i18n: dict.id / dict.en missing");
  process.exit(2);
}

function shape(v) {
  if (Array.isArray(v)) return ["array", v.map(shape)];
  if (v && typeof v === "object") {
    const out = {};
    for (const k of Object.keys(v).sort()) out[k] = shape(v[k]);
    return out;
  }
  return typeof v;
}

function firstDiff(a, b, where) {
  const sa = JSON.stringify(shape(a));
  const sb = JSON.stringify(shape(b));
  if (sa === sb) return null;
  return { where, id: sa.slice(0, 300), en: sb.slice(0, 300) };
}

const diff = firstDiff(dict.id, dict.en, "root");
if (diff) {
  console.error("check-i18n: MISMATCH between id and en");
  console.error(JSON.stringify(diff, null, 2));
  process.exit(1);
}

const keys = Object.keys(dict.id);
let arrayCount = 0;
for (const k of keys) if (Array.isArray(dict.id[k])) arrayCount++;
console.log(
  `check-i18n: OK — id/en identical structure (${keys.length} top-level keys, ${arrayCount} arrays).`
);