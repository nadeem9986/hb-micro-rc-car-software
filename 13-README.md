# HB Micro RC Car Software

A modernized Android controller APK for the HB micro RC car (`HB TOYS64`). The original uni-app (Vue) controller shipped with a Chinese UI; this project decodes it with apktool, replaces the interface with an English, dark Material-style cockpit, and re-signs the APK - while keeping the car's Bluetooth protocol byte-for-byte compatible.

## What changed vs the stock app

- Rebuilt the old Chinese UI into an English, modern dark cockpit (Material-style)
- Replaced the boxed `EXIT` graphic with a compact power icon
- Replaced legacy top-bar images with round Material-style line controls
- Preserved the working Bluetooth name/connection path for `HB TOYS64`
- Defaulted the controller to High mode
- Corrected speed mode mapping: Low sends `10`, Medium sends `01`, High sends `00`
- Set the remote command loop to `55 ms` for more responsive control

## Repository layout

- `apktool_out/` - apktool-decoded APK project with the patched web assets and Android metadata
- `scripts/material_revamp.js` - applies the JS/CSS/metadata patches idempotently (fails loudly if a pattern doesn't match)
- `scripts/create_material_assets.ps1` - regenerates the Material-style PNG assets (Windows/PowerShell)
- `build/` - APK build outputs are produced locally (see [BUILD.md](BUILD.md)) and are not committed; unsigned APKs and keystores stay out of git
- `BACKEND_FLOW.md` - the decoded BLE protocol contract: packet format, discovery/connection flow, frontend rules

Local analysis output, screenshots, tool downloads, original APK copies, built APKs, and signing keys are ignored by Git.

## Building

See [BUILD.md](BUILD.md) for the full decode -> patch -> rebuild -> sign pipeline.

## Protocol documentation

[BACKEND_FLOW.md](BACKEND_FLOW.md) documents everything decoded from the app: the 9-byte command packet, the 55 ms control loop, BLE service/characteristic discovery, throttle/steering byte mapping, and the contract any future UI redesign must respect.

## Legal note

This is an unofficial modification of a proprietary toy-car app, shared for education and personal interoperability with hardware you own. The original app and its assets belong to their respective owner; the patches, scripts, and documentation here are the original work of this repo's author. No original APK is redistributed beyond the rebuilt derivative in `build/`.
