// Landing quality gates. Reproducible: needs a static server serving dist/.
//
//   npm run build
//   npx http-server dist -p 4322      (or: python -m http.server 4322 --directory dist)
//   npm run check:gates
//
// Env: BASE (default http://localhost:4322), ART (default ../docs/artifacts),
//      CHROME (default the Windows Chrome path).
// Exit 0 = every gate passed. Exit 1 = at least one failed (details printed + JSON written).
import { chromium } from "playwright-core";
import { mkdirSync, writeFileSync } from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const here = path.dirname(fileURLToPath(import.meta.url));
const BASE = process.env.BASE ?? "http://localhost:4322";
const ART = process.env.ART ?? path.join(here, "..", "..", "docs", "artifacts");
const CHROME =
  process.env.CHROME ?? "C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe";
const WIDTHS = [320, 390, 768, 1024, 1440];
const SHOT_WIDTHS = [390, 768, 980, 1440];

// ---- WCAG 2.x contrast ----
const lin = (c) => {
  c /= 255;
  return c <= 0.03928 ? c / 12.92 : Math.pow((c + 0.055) / 1.055, 2.4);
};
const lum = (hex) => {
  const n = hex.replace("#", "");
  const r = parseInt(n.slice(0, 2), 16);
  const g = parseInt(n.slice(2, 4), 16);
  const b = parseInt(n.slice(4, 6), 16);
  return 0.2126 * lin(r) + 0.7152 * lin(g) + 0.0722 * lin(b);
};
const ratio = (a, b) => {
  const A = lum(a);
  const B = lum(b);
  const hi = Math.max(A, B);
  const lo = Math.min(A, B);
  return Math.round(((hi + 0.05) / (lo + 0.05)) * 100) / 100;
};

const T = {
  light: { canvas: "#f4f1ea", surface: "#fbf9f4", surfaceAlt: "#ede7da", ink: "#26251f", inkMuted: "#6a6659", primary: "#4a5a44", primaryContainer: "#dde3d6", onPrimary: "#fbf9f4", onPrimaryMuted: "#dde3d6", clayContainer: "#f2dcd1", honeyContainer: "#f6e4c2" },
  dark: { canvas: "#0f1a14", surface: "#152219", surfaceAlt: "#1c2c21", ink: "#e8f0e7", inkMuted: "#9daf9f", primary: "#8fe0a9", primaryContainer: "#20362a", onPrimary: "#0f1a14", onPrimaryMuted: "#20362a", clayContainer: "#3a2620", honeyContainer: "#3a3220" },
};
const PAIRS = [
  ["ink/canvas", "ink", "canvas"],
  ["ink/surface", "ink", "surface"],
  ["inkMuted/canvas", "inkMuted", "canvas"],
  ["inkMuted/surface", "inkMuted", "surface"],
  ["primary/canvas(link)", "primary", "canvas"],
  ["onPrimary/primary(btn)", "onPrimary", "primary"],
  ["onPrimaryMuted/primary(downloadLead)", "onPrimaryMuted", "primary"],
  ["ink/primaryContainer(tint)", "ink", "primaryContainer"],
  ["ink/honeyContainer(tint)", "ink", "honeyContainer"],
  ["ink/clayContainer(tint)", "ink", "clayContainer"],
  ["ink/surfaceAlt", "ink", "surfaceAlt"],
];

const failures = [];
const result = { base: BASE, contrast: {}, responsive: {}, reducedMotion: null, jsOff: null, weight: null, dark: null };

mkdirSync(ART, { recursive: true });

const browser = await chromium.launch({ executablePath: CHROME, headless: true });

// 1. Contrast (static token math)
for (const theme of ["light", "dark"]) {
  result.contrast[theme] = PAIRS.map(([name, a, b]) => {
    const r = ratio(T[theme][a], T[theme][b]);
    if (r < 4.5) failures.push(`contrast ${theme} ${name} = ${r} (< 4.5)`);
    return { pair: name, ratio: r, bodyAA: r >= 4.5, largeAA: r >= 3 };
  });
}

// 2. No horizontal overflow
{
  const ctx = await browser.newContext({ locale: "en-US" });
  for (const w of WIDTHS) {
    const page = await ctx.newPage();
    await page.setViewportSize({ width: w, height: 900 });
    await page.goto(BASE + "/en/", { waitUntil: "networkidle" });
    const m = await page.evaluate(() => ({ iw: innerWidth, sw: document.documentElement.scrollWidth }));
    const overflow = m.sw > m.iw + 1;
    if (overflow) failures.push(`overflow at ${w}px: scrollWidth ${m.sw} > ${m.iw}`);
    result.responsive["w" + w] = { ...m, overflow };
    await page.close();
  }
  await ctx.close();
}

// 3. Page weight
{
  const ctx = await browser.newContext({ locale: "en-US" });
  const page = await ctx.newPage();
  await page.setViewportSize({ width: 1440, height: 900 });
  await page.goto(BASE + "/en/", { waitUntil: "networkidle" });
  const w = await page.evaluate(() => {
    const res = performance.getEntriesByType("resource");
    const by = {};
    let enc = 0;
    for (const r of res) {
      const e = r.encodedBodySize || 0;
      enc += e;
      const k = r.initiatorType || "other";
      by[k] = (by[k] || 0) + e;
    }
    return {
      count: res.length,
      encodedKB: Math.round((enc / 1024) * 10) / 10,
      byInitiatorKB: Object.fromEntries(Object.entries(by).map(([k, v]) => [k, Math.round((v / 1024) * 10) / 10])),
    };
  });
  if (w.encodedKB > 900) failures.push(`page weight ${w.encodedKB} KB (> 900)`);
  result.weight = w;
  await ctx.close();
}

// 4. Reduced motion
{
  const ctx = await browser.newContext({ locale: "en-US", reducedMotion: "reduce" });
  const page = await ctx.newPage();
  await page.setViewportSize({ width: 900, height: 900 });
  await page.goto(BASE + "/en/", { waitUntil: "networkidle" });
  const rm = await page.evaluate(() => {
    const reveals = [...document.querySelectorAll("[data-reveal]")];
    const card = document.querySelector(".tk-card");
    return {
      runningAnimations: document.getAnimations().length,
      revealCount: reveals.length,
      allRevealsVisible: reveals.every((e) => getComputedStyle(e).opacity === "1"),
      cardTransitionDuration: card ? getComputedStyle(card).transitionDuration : null,
    };
  });
  if (rm.runningAnimations !== 0) failures.push(`reduced-motion still runs ${rm.runningAnimations} animations`);
  if (!rm.allRevealsVisible) failures.push("reduced-motion hides some reveal elements");
  result.reducedMotion = rm;
  await ctx.close();
}

// 5. JS disabled: copy must be in the HTML
{
  const ctx = await browser.newContext({ javaScriptEnabled: false, locale: "id-ID" });
  const page = await ctx.newPage();
  await page.setViewportSize({ width: 390, height: 900 });
  await page.goto(BASE + "/", { waitUntil: "load" });
  const html = await page.content();
  const jsOff = {
    htmlBytes: html.length,
    containsHeadline: html.includes("Selesai lebih tenang"),
    containsAllSectionTitles: [
      "Yang benar-benar dipakai tiap hari",
      "Terpasang dalam tiga langkah",
      "Pertanyaan yang sering muncul",
    ].every((t) => html.includes(t)),
  };
  if (!jsOff.containsHeadline) failures.push("JS-off: headline missing from HTML");
  if (!jsOff.containsAllSectionTitles) failures.push("JS-off: a section title is missing from HTML");
  result.jsOff = jsOff;
  await page.screenshot({ path: path.join(ART, "landing-js-off-390.png"), fullPage: true });
  await ctx.close();
}

// 6. Dark theme actually applies
{
  const ctx = await browser.newContext({ locale: "en-US" });
  const page = await ctx.newPage();
  await page.setViewportSize({ width: 900, height: 900 });
  await page.goto(BASE + "/en/", { waitUntil: "networkidle" });
  const dark = await page.evaluate(() => {
    document.documentElement.setAttribute("data-theme", "dark");
    const cs = getComputedStyle(document.body);
    return { bg: cs.backgroundColor, color: cs.color };
  });
  if (dark.bg !== "rgb(15, 26, 20)") failures.push(`dark canvas is ${dark.bg}, expected rgb(15, 26, 20)`);
  result.dark = dark;
  await ctx.close();
}

// 7. Screenshots (transitions off, explicit locale so "/" does not redirect)
const FORCE =
  "*,*::before,*::after{transition:none!important;animation:none!important} .js [data-reveal]{opacity:1!important;transform:none!important}";
{
  const ctx = await browser.newContext({ locale: "id-ID" });
  for (const w of SHOT_WIDTHS) {
    const page = await ctx.newPage();
    await page.setViewportSize({ width: w, height: 900 });
    await page.goto(BASE + "/", { waitUntil: "networkidle" });
    await page.addStyleTag({ content: FORCE });
    await page.waitForTimeout(250);
    await page.screenshot({ path: path.join(ART, `landing-id-${w}.png`), fullPage: true });
    await page.close();
  }
  await ctx.close();
}
{
  const ctx = await browser.newContext({ locale: "en-US" });
  for (const w of [390, 1440]) {
    const page = await ctx.newPage();
    await page.setViewportSize({ width: w, height: 900 });
    await page.goto(BASE + "/en/", { waitUntil: "networkidle" });
    await page.evaluate(() => document.documentElement.setAttribute("data-theme", "dark"));
    await page.addStyleTag({ content: FORCE });
    await page.waitForTimeout(250);
    await page.screenshot({ path: path.join(ART, `landing-dark-${w}.png`), fullPage: true });
    await page.close();
  }
  await ctx.close();
}

await browser.close();
result.failures = failures;
writeFileSync(path.join(ART, "landing-gates.json"), JSON.stringify(result, null, 2));

console.log(JSON.stringify({ ...result, failures }, null, 2));
if (failures.length) {
  console.error(`\nFAILED ${failures.length} gate(s):`);
  for (const f of failures) console.error(" - " + f);
  process.exit(1);
}
console.log("\nAll gates passed.");