# Build pipeline

How the patched APK is produced from the original app.

## Tools

- apktool (tested with 3.0.3)
- Node.js (any recent LTS) - for `scripts/material_revamp.js`
- PowerShell - only if regenerating image assets (`scripts/create_material_assets.ps1`)
- Android SDK build-tools - `zipalign` and `apksigner`
- Java 11+
- The original `ZDFcar.apk` and a signing keystore (both gitignored, keep them private)

## Steps

1. Decode the original APK:

   ```
   apktool d ZDFcar.apk -o apktool_out
   ```

2. Apply the patches (JS, CSS, metadata, version bump). The scripts are idempotent and throw if a pattern does not match, so they are safe to re-run:

   ```
   node scripts/material_revamp.js
   node scripts/translate_strings.js
   ```

   `translate_strings.js` replaces every Chinese (CJK) user-facing string in the decoded app with English: the uni-app zh locale tables (copied from the en table), the iOS Bluetooth permission text, framework console/error messages, and all smali string literals via `scripts/smali_translations_part1.js` / `smali_translations_part2.js`. It throws if a CJK string has no dictionary entry, so new strings can never slip through untranslated.

3. (Optional) Regenerate the Material-style image assets:

   ```
   powershell scripts/create_material_assets.ps1
   ```

4. Rebuild the APK:

   ```
   apktool b apktool_out -o build/micro-rc-car-modern-unsigned.apk
   ```

5. Align and sign (keystore is local-only, never committed):

   ```
   zipalign -f 4 build/micro-rc-car-modern-unsigned.apk build/micro-rc-car-modern-aligned.apk
   apksigner sign --ks <your-keystore> --out build/micro-rc-car-modern-signed.apk build/micro-rc-car-modern-aligned.apk
   ```

6. Install on the phone (uninstall any older signature first):

   ```
   adb install -r build/micro-rc-car-modern-signed.apk
   ```

## Rules

- Never commit the original APK, unsigned/aligned APKs, `.idsig` files, or keystores (already in `.gitignore`).
- Do not hand-edit `view.css` / `app-view.js` patches directly - change `scripts/material_revamp.js` and re-run it, so the patches stay reproducible.
- Same rule for translations: never translate strings by editing `apktool_out` directly - add the entry to the smali dictionary scripts and re-run `node scripts/translate_strings.js`.
- Regex character classes in `PatternsCompat.smali` / `FindAddress.smali`, the core-js whitespace list in `__uniappes6.js`, and the identifier regex in `view.umd.min.js` contain CJK code points on purpose - they are functional code, not text, and must stay.
- Keep the BLE contract in `BACKEND_FLOW.md` intact: device name `HB TOYS64`, 9-byte packet, 55 ms send loop.
