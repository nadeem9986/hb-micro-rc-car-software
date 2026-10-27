# HB Micro RC Car Software

A modernized Android controller APK for the HB micro RC car. The working Bluetooth behavior from the original app is preserved, the controller UI is converted to English, and the screen is rebuilt as a Material-style dark cockpit. The latest tested APK is included in the repo, so it can be installed without rebuilding.

## Demo

_Add a screenshot of the new controller screen here._

## Current APK

- Package: `com.JD.ZDFcar`
- Version: `1.1.0` / `110`
- App label: `Micro RC Car`
- Bluetooth target: `HB TOYS64`
- Latest signed APK: `build/micro-rc-car-modern-signed.apk`

## What changed

- Rebuilt the old Chinese UI into an English, modern dark controller screen
- Replaced the boxed `EXIT` graphic with a compact power icon
- Replaced legacy top-bar images with round Material-style line controls
- Preserved the working Bluetooth name/connection path for `HB TOYS64`
- Defaulted the controller to High mode
- Corrected speed mode mapping: Low sends `10`, Medium sends `01`, High sends `00`
- Set the remote command loop to `55 ms` for more responsive control

## Repository layout

- `apktool_out/` - apktool-decoded APK project with the patched web assets and Android metadata
- `scripts/material_revamp.js` - applies the final JS/CSS/metadata patches
- `scripts/create_material_assets.ps1` - regenerates the final Material-style PNG assets
- `build/micro-rc-car-modern-signed.apk` - latest signed APK to install

Local analysis output, screenshots, tool downloads, original APK copies, unsigned APKs, and signing keys are ignored by Git.

## What this demonstrates

Reverse-engineering and repackaging an Android APK: apktool decoding, asset and metadata patching, re-signing, and keeping a hardware protocol working while replacing the whole UI.
