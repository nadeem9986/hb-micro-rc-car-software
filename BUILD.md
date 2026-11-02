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

2. Apply the patches (JS, CSS, metadata, version bump). The script is idempotent and throws if a pattern does not match, so it is safe to re-run:

   ```
   node scripts/material_revamp.js
   ```

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
- Keep the BLE contract in `BACKEND_FLOW.md` intact: device name `HB TOYS64`, 9-byte packet, 55 ms send loop.
