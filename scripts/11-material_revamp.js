const fs = require("fs");
const path = require("path");

const root = path.resolve(__dirname, "..");
const www = path.join(root, "apktool_out", "assets", "apps", "__UNI__FB0AA52", "www");
const servicePath = path.join(www, "app-service.js");
const viewBundlePath = path.join(www, "app-view.js");
const cssPath = path.join(www, "view.css");
const androidManifestPath = path.join(root, "apktool_out", "AndroidManifest.xml");
const manifestPath = path.join(root, "apktool_out", "assets", "data", "dcloud_control.xml");
const appsManifestPath = path.join(root, "apktool_out", "assets", "apps", "__UNI__FB0AA52", "www", "manifest.json");
const apktoolYmlPath = path.join(root, "apktool_out", "apktool.yml");

function read(file) {
  return fs.readFileSync(file, "utf8");
}

function writeIfChanged(file, next) {
  const current = read(file);
  if (current !== next) {
    fs.writeFileSync(file, next, "utf8");
    console.log(`updated ${path.relative(root, file)}`);
  } else {
    console.log(`unchanged ${path.relative(root, file)}`);
  }
}

function replaceRequired(source, pattern, replacement, label) {
  const next = source.replace(pattern, replacement);
  if (next === source) {
    throw new Error(`Could not patch ${label}`);
  }
  return next;
}

let service = read(servicePath);

service = service.replace(
  /num_speed:\d,img_speed:"\/static\/btn_speed\d\.png",speedMode:"[01]{2}"/,
  'num_speed:3,img_speed:"/static/btn_speed3.png",speedMode:"00"'
);

const switchStart = service.indexOf("switchSpeed:function(){");
const cruiseMarker = "},cruiseEnd:function";
if (switchStart === -1) {
  throw new Error("Could not find switchSpeed");
}
const switchEnd = service.indexOf(cruiseMarker, switchStart);
if (switchEnd === -1) {
  throw new Error("Could not find cruiseEnd after switchSpeed");
}
const switchReplacement =
  'switchSpeed:function(){this.num_speed=this.num_speed%3+1,1==this.num_speed?(this.img_speed="/static/btn_speed1.png",this.speedMode="10",uni.showToast({icon:"none",title:"Speed: Low",duration:650})):2==this.num_speed?(this.img_speed="/static/btn_speed2.png",this.speedMode="01",uni.showToast({icon:"none",title:"Speed: Medium",duration:650})):(this.img_speed="/static/btn_speed3.png",this.speedMode="00",uni.showToast({icon:"none",title:"Speed: High",duration:650}))}';
service = service.slice(0, switchStart) + switchReplacement + service.slice(switchEnd + 1);

service = service.replace(
  /setInterval\(\(function\(\)\{e\.sendOrder\(\)\}\),\d+\)/g,
  "setInterval((function(){e.sendOrder()}),55)"
);

if (!service.includes('Device found: "HB TOYS64"') && !service.includes("HB TOYS64")) {
  console.warn("warning: HB TOYS64 string was not found; leaving discovery logic unchanged");
}
if (service.includes("pwmTick")) {
  throw new Error("PWM experiment code is still present. Refusing to build a capped/full-stop variant.");
}

writeIfChanged(servicePath, service);

let css = read(cssPath);
const oldMarker = "/* micro-rc-modern-overhaul */";
const marker = "/* micro-rc-material-v2 */";
const oldIndex = css.indexOf(oldMarker);
const existingMaterialIndex = css.indexOf(marker);
if (oldIndex >= 0 && existingMaterialIndex > oldIndex) {
  css = css.slice(0, oldIndex).trimEnd() + "\n" + css.slice(existingMaterialIndex);
}
const materialCss = `
${marker}
:root{--rc-blue:#4cc9f0;--rc-green:#52d273;--rc-amber:#ffb703;--rc-bg:#070a0f;--rc-panel:rgba(14,20,29,.72);--rc-line:rgba(255,255,255,.14)}
body{background:#070a0f!important}
.content{background:radial-gradient(circle at 20% 8%,rgba(76,201,240,.2),transparent 30%),radial-gradient(circle at 82% 86%,rgba(82,210,115,.18),transparent 26%),linear-gradient(135deg,#05070b 0%,#0b1017 46%,#111827 100%)!important;color:#eef6ff!important}
.content .box{background:transparent!important}
.content .box .controlButton{height:calc(118 * 100 / var(--base-rpx) * 1vmin)!important;padding:calc(14 * 100 / var(--base-rpx) * 1vmin) calc(30 * 100 / var(--base-rpx) * 1vmin)!important;background:linear-gradient(180deg,rgba(12,18,27,.9),rgba(12,18,27,.58))!important;border-bottom:1px solid rgba(255,255,255,.12)!important;box-shadow:0 calc(16 * 100 / var(--base-rpx) * 1vmin) calc(34 * 100 / var(--base-rpx) * 1vmin) rgba(0,0,0,.28)!important;backdrop-filter:blur(18px)!important}
.content .box .controlButton .left,.content .box .controlButton .center,.content .box .controlButton .right{border-radius:999px!important;background:linear-gradient(180deg,rgba(255,255,255,.16),rgba(255,255,255,.06))!important;border:1px solid rgba(255,255,255,.16)!important;box-shadow:inset 0 1px 0 rgba(255,255,255,.18),0 calc(8 * 100 / var(--base-rpx) * 1vmin) calc(18 * 100 / var(--base-rpx) * 1vmin) rgba(0,0,0,.26)!important;overflow:hidden!important}
.content .box .controlButton .center{min-width:calc(116 * 100 / var(--base-rpx) * 1vmin)!important;height:calc(54 * 100 / var(--base-rpx) * 1vmin)!important;padding:0 calc(28 * 100 / var(--base-rpx) * 1vmin)!important;display:flex!important;align-items:center!important;justify-content:center!important}
.content .box .controlButton .center .text{color:#f8fbff!important;font-weight:700!important;font-size:calc(24 * 100 / var(--base-rpx) * 1vmin)!important;line-height:1!important;letter-spacing:0!important;text-shadow:none!important}
.content .box .controlButton .icon,.content .box .controlButton .icon2{border-radius:999px!important;background:rgba(255,255,255,.09)!important;padding:calc(8 * 100 / var(--base-rpx) * 1vmin)!important;box-sizing:border-box!important;box-shadow:inset 0 1px 0 rgba(255,255,255,.18)!important}
.content .box .controlButton .left:active,.content .box .controlButton .center:active,.content .box .controlButton .right:active{transform:scale(.96)!important;background:rgba(76,201,240,.2)!important}
.controlArea{height:calc(590 * 100 / var(--base-rpx) * 1vmin)!important;padding:0 calc(48 * 100 / var(--base-rpx) * 1vmin) calc(16 * 100 / var(--base-rpx) * 1vmin)!important;box-sizing:border-box!important}
.controlArea .controlView2{height:100%!important;align-items:center!important;justify-content:space-between!important}
.controlArea .settings{background:linear-gradient(180deg,rgba(20,28,39,.86),rgba(12,18,27,.7))!important;border:1px solid rgba(255,255,255,.12)!important;border-radius:calc(36 * 100 / var(--base-rpx) * 1vmin)!important;box-shadow:0 calc(18 * 100 / var(--base-rpx) * 1vmin) calc(38 * 100 / var(--base-rpx) * 1vmin) rgba(0,0,0,.28)!important;backdrop-filter:blur(18px)!important}
.controlArea .settings .box{background:transparent!important;border:0!important}
.controlArea .settings .box .icon{border-radius:999px!important;background:rgba(255,255,255,.08)!important}
.movable .movableArea{background:radial-gradient(circle at 50% 50%,rgba(76,201,240,.16),transparent 28%),linear-gradient(180deg,rgba(255,255,255,.08),rgba(255,255,255,.025))!important;border:1px solid rgba(255,255,255,.12)!important;border-radius:999px!important;box-shadow:inset 0 1px 0 rgba(255,255,255,.15),0 calc(18 * 100 / var(--base-rpx) * 1vmin) calc(42 * 100 / var(--base-rpx) * 1vmin) rgba(0,0,0,.35)!important;overflow:hidden!important}
.movable .movableArea image{opacity:.9!important}
.movable .movableView{background:radial-gradient(circle at 36% 28%,rgba(255,255,255,.36),transparent 26%),linear-gradient(145deg,#4cc9f0,#52d273)!important;border:1px solid rgba(255,255,255,.36)!important;border-radius:999px!important;box-shadow:0 calc(14 * 100 / var(--base-rpx) * 1vmin) calc(30 * 100 / var(--base-rpx) * 1vmin) rgba(0,0,0,.38),inset 0 1px 0 rgba(255,255,255,.45)!important}
.movable .movableView image{display:none!important}
.content .electricity{background:rgba(255,255,255,.08)!important;border:1px solid rgba(255,255,255,.12)!important;border-radius:999px!important;box-shadow:none!important}
.content .choose-device,.content .dialog{background:rgba(8,13,20,.96)!important;border:1px solid rgba(255,255,255,.14)!important;border-radius:calc(22 * 100 / var(--base-rpx) * 1vmin)!important;box-shadow:0 calc(24 * 100 / var(--base-rpx) * 1vmin) calc(70 * 100 / var(--base-rpx) * 1vmin) rgba(0,0,0,.5)!important}
.content .choose-device .item,.content .dialog .btn{border-radius:calc(16 * 100 / var(--base-rpx) * 1vmin)!important;background:rgba(255,255,255,.08)!important;border:1px solid rgba(255,255,255,.1)!important;color:#f8fbff!important}
.content .choose-device .title,.content .dialog .title{color:#f8fbff!important;font-weight:700!important;letter-spacing:0!important}
.content .mask{background:rgba(0,0,0,.58)!important;backdrop-filter:blur(8px)!important}
.content .box .controlButton[data-v-080eb564]{height:calc(112 * 100 / var(--base-rpx) * 1vmin)!important;padding:calc(10 * 100 / var(--base-rpx) * 1vmin) calc(42 * 100 / var(--base-rpx) * 1vmin)!important;background:linear-gradient(180deg,rgba(9,14,22,.86),rgba(9,14,22,.38))!important;border-bottom:1px solid rgba(255,255,255,.1)!important;box-shadow:0 calc(14 * 100 / var(--base-rpx) * 1vmin) calc(30 * 100 / var(--base-rpx) * 1vmin) rgba(0,0,0,.24)!important}
.content .box .controlButton .left[data-v-080eb564],.content .box .controlButton .right[data-v-080eb564]{width:calc(96 * 100 / var(--base-rpx) * 1vmin)!important;height:calc(96 * 100 / var(--base-rpx) * 1vmin)!important;margin-left:0!important;margin-right:0!important;border-radius:999px!important;background:rgba(255,255,255,.07)!important;border:1px solid rgba(255,255,255,.12)!important}
.content .box .controlButton .center[data-v-080eb564]{position:relative!important;width:auto!important;min-width:calc(178 * 100 / var(--base-rpx) * 1vmin)!important;height:calc(62 * 100 / var(--base-rpx) * 1vmin)!important;margin-left:calc(-120 * 100 / var(--base-rpx) * 1vmin)!important;padding:0 calc(24 * 100 / var(--base-rpx) * 1vmin)!important;display:flex!important;align-items:center!important;justify-content:center!important;border-radius:999px!important;background:linear-gradient(180deg,rgba(255,255,255,.14),rgba(255,255,255,.055))!important;border:1px solid rgba(255,255,255,.18)!important;box-shadow:0 calc(10 * 100 / var(--base-rpx) * 1vmin) calc(18 * 100 / var(--base-rpx) * 1vmin) rgba(0,0,0,.25),inset 0 1px 0 rgba(255,255,255,.18)!important}
.content .box .controlButton .center .text[data-v-080eb564]{position:static!important;top:auto!important;left:auto!important;width:auto!important;z-index:auto!important;font-size:calc(28 * 100 / var(--base-rpx) * 1vmin)!important;font-weight:750!important;line-height:1!important;color:#f8fbff!important;letter-spacing:0!important}
.content .icon[data-v-080eb564],.content .icon2[data-v-080eb564]{width:calc(92 * 100 / var(--base-rpx) * 1vmin)!important;height:calc(92 * 100 / var(--base-rpx) * 1vmin)!important;border-radius:999px!important;background:rgba(255,255,255,.045)!important;box-shadow:0 calc(8 * 100 / var(--base-rpx) * 1vmin) calc(20 * 100 / var(--base-rpx) * 1vmin) rgba(0,0,0,.22)!important}
.content .icon2[data-v-080eb564]{width:calc(104 * 100 / var(--base-rpx) * 1vmin)!important;height:calc(104 * 100 / var(--base-rpx) * 1vmin)!important}
`;

const markerIndex = css.indexOf(marker);
if (markerIndex >= 0) {
  css = css.slice(0, markerIndex).trimEnd() + "\n" + materialCss.trimStart();
} else {
  css = css.trimEnd() + "\n" + materialCss.trimStart();
}
writeIfChanged(cssPath, css);

let viewBundle = read(viewBundlePath);
const viewMarker = "/* micro-rc-appview-m3 */";
const viewEndMarker = "/* /micro-rc-appview-m3 */";
const appViewCss = `${viewMarker}.content .box .controlButton{height:calc(110 * 100 / var(--base-rpx) * 1vmin)!important;padding:calc(8 * 100 / var(--base-rpx) * 1vmin) calc(42 * 100 / var(--base-rpx) * 1vmin)!important;background:linear-gradient(180deg,rgba(9,14,22,.9),rgba(9,14,22,.34))!important;border-bottom:1px solid rgba(255,255,255,.1)!important;box-shadow:0 calc(16 * 100 / var(--base-rpx) * 1vmin) calc(32 * 100 / var(--base-rpx) * 1vmin) rgba(0,0,0,.28)!important}.content .box .controlButton .left,.content .box .controlButton .right{width:calc(98 * 100 / var(--base-rpx) * 1vmin)!important;height:calc(98 * 100 / var(--base-rpx) * 1vmin)!important;margin-left:0!important;margin-right:0!important;border-radius:999px!important;background:rgba(255,255,255,.055)!important;border:1px solid rgba(255,255,255,.12)!important;box-shadow:0 calc(8 * 100 / var(--base-rpx) * 1vmin) calc(22 * 100 / var(--base-rpx) * 1vmin) rgba(0,0,0,.24)!important;overflow:hidden!important}.content .box .controlButton .center{width:auto!important;height:calc(98 * 100 / var(--base-rpx) * 1vmin)!important;margin-left:0!important;padding:0!important;display:flex!important;align-items:center!important;justify-content:center!important;gap:calc(14 * 100 / var(--base-rpx) * 1vmin)!important;background:transparent!important;border:0!important;box-shadow:none!important}.content .box .controlButton .center .text{display:none!important}.content .icon,.content .icon2{width:calc(96 * 100 / var(--base-rpx) * 1vmin)!important;height:calc(96 * 100 / var(--base-rpx) * 1vmin)!important;border-radius:999px!important}.content .icon2{width:calc(106 * 100 / var(--base-rpx) * 1vmin)!important;height:calc(106 * 100 / var(--base-rpx) * 1vmin)!important}.content .totalControl{height:calc(500 * 100 / var(--base-rpx) * 1vmin)!important}${viewEndMarker}`;
const viewStart = viewBundle.indexOf(viewMarker);
if (viewStart >= 0) {
  const viewEnd = viewBundle.indexOf(viewEndMarker, viewStart);
  if (viewEnd === -1) {
    throw new Error("Found app-view Material marker without end marker");
  }
  viewBundle = viewBundle.slice(0, viewStart) + appViewCss + viewBundle.slice(viewEnd + viewEndMarker.length);
} else {
  const appViewNeedle = ".content .box .policy{position:fixed;top:calc(140 * 100 / var(--base-rpx) * 1vmin);height:100vh}";
  viewBundle = replaceRequired(viewBundle, appViewNeedle, appViewNeedle + appViewCss, "app-view Material CSS");
}
writeIfChanged(viewBundlePath, viewBundle);

if (fs.existsSync(manifestPath)) {
  let xml = read(manifestPath);
  xml = xml.replace(/<appver>[^<]*<\/appver>/, "<appver>1.1.0</appver>");
  writeIfChanged(manifestPath, xml);
}

if (fs.existsSync(androidManifestPath)) {
  let androidManifest = read(androidManifestPath);
  androidManifest = androidManifest.replace(/<manifest\b([^>]*)>/, (match, attrs) => {
    const cleaned = attrs
      .replace(/\s+android:versionCode="[^"]*"/, "")
      .replace(/\s+android:versionName="[^"]*"/, "");
    return `<manifest${cleaned} android:versionCode="120" android:versionName="1.2.0">`;
  });
  writeIfChanged(androidManifestPath, androidManifest);
}

if (fs.existsSync(apktoolYmlPath)) {
  let yml = read(apktoolYmlPath);
  yml = yml.replace(/versionCode:\s*\d+/, "versionCode: 120");
  yml = yml.replace(/versionName:\s*[^\r\n]+/, "versionName: 1.2.0");
  writeIfChanged(apktoolYmlPath, yml);
}

if (fs.existsSync(appsManifestPath)) {
  let manifest = read(appsManifestPath);
  const named = manifest.replace(/"name"\s*:\s*"[^"]*"/, '"name":"HB Micro RC"');
  if (named === manifest && !manifest.includes('"name":"HB Micro RC"')) {
    throw new Error("Could not patch manifest name");
  }
  manifest = named;
  const versioned = manifest.replace(/"version"\s*:\s*\{\s*"name"\s*:\s*"[^"]*"\s*,\s*"code"\s*:\s*"[^"]*"\s*\}/, '"version":{"name":"1.1.0","code":"110"}');
  if (versioned === manifest && !manifest.includes('"version":{"name":"1.1.0","code":"110"}')) {
    throw new Error("Could not patch manifest version");
  }
  manifest = versioned;
  manifest = manifest.replace(/"aliasname"\s*:\s*"[^"]*"/, '"aliasname":"HB Micro RC"');
  writeIfChanged(appsManifestPath, manifest);
}

console.log("Material revamp complete: speed order is Low=10, Medium=01, High=00; default is High.");
