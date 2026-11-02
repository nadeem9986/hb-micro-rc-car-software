// translate_strings.js - replace every Chinese (CJK) user-facing string in the
// decoded app with English. Idempotent; throws when an expected pattern is
// missing, same contract as material_revamp.js.
//
// Deliberately NOT touched (functional code, not user-facing text):
//   - androidx PatternsCompat.smali / FindAddress.smali (CJK in regex char classes)
//   - www/__uniappes6.js (ideographic space in the core-js whitespace list)
//   - the identifier-validation regex in view.umd.min.js
//   - all BLE protocol logic (BACKEND_FLOW.md contract)

const fs = require("fs");
const path = require("path");

const root = path.resolve(__dirname, "..");
const outDir = path.join(root, "apktool_out");
const www = path.join(outDir, "assets", "apps", "__UNI__FB0AA52", "www");

const CJK = /[一-鿿　-〿＀-￯]/;

function read(file) {
  return fs.readFileSync(file, "utf8");
}
function writeIfChanged(file, next) {
  const current = read(file);
  if (current !== next) {
    fs.writeFileSync(file, next, "utf8");
    console.log(`updated ${path.relative(root, file)}`);
    return true;
  }
  console.log(`unchanged ${path.relative(root, file)}`);
  return false;
}
function replaceRequired(source, pattern, replacement, label) {
  const next = source.replace(pattern, replacement);
  if (next === source) {
    throw new Error(`Could not patch ${label}`);
  }
  return next;
}

function replaceSoft(source, pattern, replacement, label) {
  // Idempotent: throws only when the pattern is absent entirely; replacing an
  // already-translated value with itself counts as unchanged, not failure.
  if (!pattern.test(source)) {
    throw new Error(`Could not patch ${label}`);
  }
  return source.replace(pattern, replacement);
}

// 1. www/manifest.json - iOS Bluetooth permission descriptions
{
  const file = path.join(www, "manifest.json");
  let m = read(file);
  for (const key of ["NSBluetoothAlwaysUsageDescription", "NSBluetoothPeripheralUsageDescription"]) {
    m = replaceSoft(
      m,
      new RegExp(`("${key}"\\s*:\\s*")[^"]*(")`),
      `$1Bluetooth is used to connect to the RC car.$2`,
      `manifest.json ${key}`
    );
  }
  writeIfChanged(file, m);
}

// 2. www/view.umd.min.js - zh locale tables + fullwidth punctuation
{
  const file = path.join(www, "view.umd.min.js");
  let v = read(file);
  const blobRe = /JSON\.parse\('\{"uni\.app\.quit".*?\}'\)/g;
  const blobs = v.match(blobRe) || [];
  const enBlob = blobs.find((b) => b.includes('"uni.app.quit":"Press back button again to exit"'));
  if (!enBlob) {
    throw new Error("Could not find the English uni.* locale table in view.umd.min.js");
  }
  v = v.replace(blobRe, (b) => {
    if (b === enBlob) return b;
    // zh-Hans / zh-Hant tables: original Chinese on a fresh decode, or the
    // placeholder-mangled version in the current tree.
    if (CJK.test(b) || b.includes('"uni.app.quit":"English"')) return enBlob;
    return b; // fr / es tables stay untouched
  });
  v = v.split("Not Found：Page[").join("Not Found: Page[");
  writeIfChanged(file, v);
}

// 3. unknown/io/dcloud/uni-app-service.js - console.warn messages
{
  const file = path.join(outDir, "unknown", "io", "dcloud", "uni-app-service.js");
  let s = read(file);
  for (const api of ["createMapContext", "createVideoContext", "createLivePusherContext"]) {
    s = replaceSoft(
      s,
      new RegExp(`console\\.warn\\("uni\\.${api}[^"]*"\\)`),
      `console.warn("uni.${api} failed: pass the current component instance (vm, i.e. this)")`,
      `uni-app-service.js ${api} warning`
    );
  }
  writeIfChanged(file, s);
}

// 4. assets/data/dcloud_error.html - error page strings
{
  const file = path.join(outDir, "assets", "data", "dcloud_error.html");
  let h = read(file);
  h = replaceSoft(
    h,
    /info\.innerText="[^"]*"\+e\.url\+"[^"]*";/,
    'info.innerText="The requested page ("+e.url+") cannot be opened";',
    "dcloud_error.html innerText"
  );
  h = replaceSoft(
    h,
    /console\.log\("[^"]*"\+e\.href\);/,
    'console.log("The requested page cannot be opened: "+e.href);',
    "dcloud_error.html console.log"
  );
  writeIfChanged(file, h);
}

// 5. www/__uniappchooselocation.js - zh locale table
{
  const file = path.join(www, "__uniappchooselocation.js");
  let c = read(file);
  c = replaceSoft(
    c,
    /zh:\{search_tips:"[^"]*",no_found:"[^"]*",nearby:"[^"]*",more:"[^"]*"\}/,
    'zh:{search_tips:"Search for a place",no_found:"No results found",nearby:"Nearby",more:"More"}',
    "__uniappchooselocation.js zh locale"
  );
  writeIfChanged(file, c);
}

// 6. www/app-service.js - fullwidth punctuation escapes in app strings
{
  const file = path.join(www, "app-service.js");
  let a = read(file);
  const qm = a.split("\\uff1f").length - 1;
  const cm = a.split("\\uff0c").length - 1;
  a = a.split("\\uff1f").join("?").split("\\uff0c").join(", ");
  console.log(`app-service.js: replaced ${qm} fullwidth question marks, ${cm} fullwidth commas`);
  writeIfChanged(file, a);
}

// 7. smali string literals - dictionary-driven translation
{
  const dict = Object.assign(
    {},
    require("./smali_translations_part1.js"),
    require("./smali_translations_part2.js")
  );
  const SKIP_FILES = new Set([
    // CJK code points inside URL/address regex character classes - functional
    path.join("smali", "androidx", "core", "util", "PatternsCompat.smali"),
    path.join("smali", "androidx", "core", "text", "util", "FindAddress.smali"),
  ]);

  function decodeSmali(raw) {
    return raw.replace(/\\(u[0-9a-fA-F]{4}|n|t|r|b|f|"|'|\\)/g, (m, e) => {
      if (e[0] === "u") return String.fromCharCode(parseInt(e.slice(1), 16));
      return { n: "\n", t: "\t", r: "\r", b: "\b", f: "\f", '"': '"', "'": "'", "\\": "\\" }[e];
    });
  }
  function encodeSmali(text) {
    return text
      .replace(/\\/g, "\\\\")
      .replace(/"/g, '\\"')
      .replace(/\n/g, "\\n")
      .replace(/\t/g, "\\t")
      .replace(/\r/g, "\\r");
  }

  const literalRe = /"((?:[^"\\]|\\.)*)"/g;
  const missing = new Map();
  let filesTouched = 0;
  let stringsTranslated = 0;

  function walk(dir) {
    for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
      const p = path.join(dir, entry.name);
      if (entry.isDirectory()) {
        walk(p);
        continue;
      }
      if (!entry.name.endsWith(".smali")) continue;
      const rel = path.relative(outDir, p);
      if (SKIP_FILES.has(rel)) continue;
      const src = read(p);
      let changed = false;
      const next = src.replace(literalRe, (whole, raw) => {
        if (!/(?:\\u[3-9a-fA-F][0-9a-fA-F]{3}|[一-鿿　-〿＀-￯])/.test(raw)) return whole;
        const decoded = decodeSmali(raw);
        if (!CJK.test(decoded)) return whole; // escapes outside the CJK ranges
        const en = dict[decoded];
        if (en === undefined) {
          missing.set(decoded, rel);
          return whole;
        }
        changed = true;
        stringsTranslated += 1;
        return `"${encodeSmali(en)}"`;
      });
      if (changed) {
        fs.writeFileSync(p, next, "utf8");
        filesTouched += 1;
        console.log(`updated ${rel}`);
      }
    }
  }

  walk(outDir);

  if (missing.size > 0) {
    for (const [zh, rel] of missing) {
      console.error(`MISSING TRANSLATION [${rel}]: ${JSON.stringify(zh)}`);
    }
    throw new Error(`${missing.size} untranslated CJK string(s) remain; add them to the dictionary`);
  }
  console.log(`smali: translated ${stringsTranslated} string literal(s) across ${filesTouched} file(s)`);
}
