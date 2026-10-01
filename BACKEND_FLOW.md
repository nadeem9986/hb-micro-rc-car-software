# Micro RC Car APK Backend Flow

This document describes the backend/control flow decoded from the APK. It is meant to be the contract for any future frontend redesign. The UI can change completely, but the Bluetooth discovery, connection flow, control values, send interval, and command packet format must stay compatible unless the car protocol is intentionally changed and tested.

Decoded source reference:

- `apktool_out/assets/apps/__UNI__FB0AA52/www/app-service.js`
- Decompiled component names found in the bundle include `App.vue`, `pages/remote/index.vue`, `components/remote/remote.vue`, `components/rocker-v/rocker-v.vue`, and `components/rocker-h/rocker-h.vue`.

## 1. High Level Architecture

The APK is a uni-app Android application. The Android shell starts the uni-app runtime, and the actual car logic is inside the bundled JavaScript.

Main responsibilities:

- App startup: force landscape mode, fullscreen layout, and basic Android location/Bluetooth checks.
- BLE discovery: scan for the car by name or show a selectable list of nearby devices.
- BLE connection: connect, discover service/characteristics, enable notify, and store the write characteristic.
- Control loop: send a control packet every 55 ms while BLE is connected.
- UI state: update throttle, steering, speed mode, light mode, and cruise mode values.

The key device name currently used by the app is:

```text
HB TOYS64
```

This name-finding logic is important because the car previously connected and worked through this path.

## 2. Global State Model

The app keeps Bluetooth and control state in global data plus page/component state.

Important global Bluetooth fields:

| Field | Meaning |
| --- | --- |
| `device` | Target BLE name. Current known value: `HB TOYS64`. |
| `Ble_on` | True when app considers BLE connected and ready to send. |
| `isFound` | True after a matching/selected BLE device is found. |
| `deviceId` | Active BLE device id used for writes. |
| `deviceIdA/B/C` | Stored ids when multiple matching devices are found. |
| `serviceId` | Discovered BLE service id used for writes. |
| `writeCharId` | Discovered writable BLE characteristic id. |
| `failedTime` | Write failure counter. If too high, the app closes BLE. |
| `isExchange` | Swaps throttle/steering control placement. |

Important remote-control fields:

| Field | Default/Range | Meaning |
| --- | --- | --- |
| `speedA` | `127`, range `0..255` | Throttle axis. Neutral is 127. |
| `speedB` | `127`, range `0..255` | Steering axis. Neutral is 127. |
| `speedC` | `127`, range `0..255` | Present in code, but not used in the normal remote packet. |
| `speedMode` | `"00"` default | Two-bit speed mode packed into the mode byte. |
| `cruiseMode` | `"0"` default | One-bit cruise flag packed into the mode byte. |
| `lightMode` | `"0"` default | One-bit light flag packed into the mode byte. |
| `is4Chan` | Boolean | Controls whether the second rocker is shown/used. |

## 3. Startup Flow

1. `onLaunch()` runs when the app starts.
2. The app locks orientation to landscape primary.
3. The app switches to fullscreen layout.
4. On Android, it checks whether location service is enabled. This matters because Android BLE scanning can fail when location is disabled.
5. The remote page initializes Bluetooth with `initBLE()`.
6. `initBLE()` calls `uni.openBluetoothAdapter()`.
7. On success, it starts the global BLE discovery path.
8. If the app is still not connected after about 16 seconds, the page-level manual discovery/list flow is started.

Failure behavior:

- If Bluetooth adapter opening fails, the app shows a toast telling the user to turn on Bluetooth and restart the app.
- If scanning times out, the app shows a modal telling the user to check that the car is powered on and, on Android, to enable GPS/location.

## 4. BLE Discovery Flow

There are two discovery paths.

### 4.1 Auto Discovery

The global discovery path searches for the configured target device name:

```text
HB TOYS64
```

When a match is found, it calls `connectBLE(...)` with the discovered device object(s).

This path should be preserved. The earlier working behavior depended on this name/path after the phone had been manually paired to the car.

### 4.2 Manual List Discovery

If auto discovery does not finish, the page-level flow starts scanning:

1. Calls `uni.startBluetoothDevicesDiscovery({ allowDuplicatesKey: false, interval: 0 })`.
2. Shows a loading message: "Searching for devices".
3. Repeatedly calls `uni.getBluetoothDevices()`.
4. Builds a visible list from each device's `name` or `localName`.
5. Ignores empty names.
6. Lets the user choose a listed device.
7. On selection, filters matching devices with non-zero RSSI.
8. Calls `connectBLE(...)`.

Timeout:

- After about 15 seconds, scanning is stopped and a "Device search timed out" modal is shown.

## 5. BLE Connection Flow

The connection flow is:

```text
connectBLE()
  -> createBLE(deviceId)
  -> getBLEServiceId(deviceId)
  -> getBLECharacterId(deviceId, services)
  -> recvBLECharacterNotice(deviceId, serviceId, notifyCharId)
  -> Ble_on = true
  -> start 55 ms send loop
```

### 5.1 `connectBLE(devices, showLoading)`

Responsibilities:

- Marks a device as found.
- Stops BLE discovery.
- Stores discovered `deviceId` values.
- If multiple devices are passed, stores them as `deviceIdA`, `deviceIdB`, and `deviceIdC`, then chooses `deviceIdA`.
- Calls `createBLE(deviceId)`.

### 5.2 `createBLE(deviceId)`

Responsibilities:

- Waits about 1 second.
- Calls `uni.createBLEConnection({ deviceId, setTimeout: 5000 })`.
- On success, waits about 1 second and calls `getBLEServiceId(deviceId)`.
- On failure, hides loading and logs the error.

Note: the decoded code uses `setTimeout` in the connection object. That may be a uni-app compatibility detail or a mistake in the original app, but it is what the APK currently contains.

### 5.3 `getBLEServiceId(deviceId)`

Responsibilities:

- Calls `uni.getBLEDeviceServices({ deviceId })`.
- If no services are found, closes the BLE connection.
- Otherwise passes the service list to `getBLECharacterId(...)`.

### 5.4 `getBLECharacterId(deviceId, services)`

Responsibilities:

- Iterates primary services only.
- For each primary service, calls `uni.getBLEDeviceCharacteristics(...)`.
- The app expects a primary service with exactly two characteristics.
- If a characteristic has `notify`, it enables notifications.
- If a characteristic has `write`, it stores:
  - `deviceId`
  - `serviceId`
  - `writeCharId`

Important limitation:

- There is no hardcoded service UUID or write characteristic UUID.
- The app discovers whichever primary service has the expected two-characteristic shape.
- If the car firmware exposes a different BLE shape, the app may connect at Android level but still fail to control the car.

### 5.5 `recvBLECharacterNotice(...)`

Responsibilities:

- Calls `uni.notifyBLECharacteristicValueChange({ state: true })`.
- On success, if `writeCharId` exists:
  - hides loading
  - sets `Ble_on = true`
  - emits `uni.$emit("ble", true)`
  - clears exchange/reconnect state

The notification callback is registered, but the decoded APK does not appear to process incoming values. Control is write-only in practice.

## 6. BLE Write Flow

All control packets are sent through:

```text
sendBLECharacterNotice(deviceId, serviceId, writeCharId, hexString)
```

Behavior:

1. Takes a hex string packet.
2. Splits it into byte pairs.
3. Converts the bytes into a `Uint8Array`.
4. Calls `uni.writeBLECharacteristicValue(...)`.
5. On success, resets `failedTime` to `0`.
6. On failure, increases `failedTime` by `70`.
7. If `failedTime >= 1750`, closes BLE and clears the send timer.

This means about 25 consecutive write failures can force disconnect:

```text
1750 / 70 = 25
```

## 7. Control Loop

The remote component watches `ble_on`.

When `ble_on` becomes true:

1. Waits about 200 ms.
2. Sends one packet immediately.
3. Clears any old send timer.
4. Starts a new timer that calls `sendOrder()` every 55 ms.

When `ble_on` becomes false:

- Clears the send timer.

Any frontend redesign should not create a second independent send loop. It should update state values only, and let the existing loop send packets.

## 8. Throttle And Steering Mapping

The app uses byte values centered at neutral:

```text
0     = maximum reverse / left side
127   = neutral
255   = maximum forward / right side
```

Main axes:

| Axis | State field | Meaning |
| --- | --- | --- |
| Throttle | `speedA` | Forward/backward control. |
| Steering | `speedB` | Left/right control. |

Touch release behavior:

- Throttle rocker release sets `speedA = 127`.
- Steering rocker release sets `speedB = 127`.
- The vertical rocker also emits `speedC = 127`, but the normal remote packet does not use `speedC`.

Touch movement behavior:

- The rocker has a dead zone of about 15 px.
- It calculates a proportional value based on touch distance from center.
- It clamps the output to the `0..255` byte range.
- Forward/backward moves `speedA` around neutral 127.
- Left/right moves `speedB` around neutral 127.

Exchange behavior:

- `isExchange = false`: left rocker is throttle, right rocker is steering.
- `isExchange = true`: the app swaps the control placement.

For a drift car frontend, the safest mapping is:

| UI Control | Backend value |
| --- | --- |
| Throttle up/forward | Increase `speedA` above 127. |
| Throttle down/reverse/brake | Decrease `speedA` below 127. |
| Throttle released | Set `speedA = 127`. |
| Steering right | Increase `speedB` above 127. |
| Steering left | Decrease `speedB` below 127. |
| Steering released | Set `speedB = 127`. |

## 9. Command Packet Format

The normal remote-control packet is built in `sendOrder()`.

Packet construction:

```text
modeBits = "0000" + speedMode + cruiseMode + lightMode
modeByte = binary(modeBits)
checksum = 255 - lowByte(speedA + speedB + modeByte)
packet = speedA + speedB + 00 00 00 00 + modeByte + 00 + checksum
```

Packet length:

```text
9 bytes / 18 hex characters
```

Byte layout:

| Byte | Value | Meaning |
| --- | --- | --- |
| 0 | `speedA` | Throttle byte. |
| 1 | `speedB` | Steering byte. |
| 2 | `00` | Reserved/unused in current remote packet. |
| 3 | `00` | Reserved/unused in current remote packet. |
| 4 | `00` | Reserved/unused in current remote packet. |
| 5 | `00` | Reserved/unused in current remote packet. |
| 6 | `modeByte` | Packed speed/cruise/light bits. |
| 7 | `00` | Reserved/unused. |
| 8 | `checksum` | Inverse low-byte checksum. |

Example neutral packet with default modes:

```text
speedA = 127 = 7f
speedB = 127 = 7f
modeByte = 00
sum = 0x7f + 0x7f + 0x00 = 0xfe
checksum = 0xff - 0xfe = 0x01

packet = 7f 7f 00 00 00 00 00 00 01
```

Example full-forward neutral-steering packet with default modes:

```text
speedA = 255 = ff
speedB = 127 = 7f
modeByte = 00
sum low byte = 0x7e
checksum = 0xff - 0x7e = 0x81

packet = ff 7f 00 00 00 00 00 00 81
```

## 10. Mode Byte

Mode byte bit construction:

```text
0000 SS C L
```

Where:

| Bits | Field | Meaning |
| --- | --- | --- |
| `SS` | `speedMode` | Two-bit speed mode. |
| `C` | `cruiseMode` | Cruise mode flag. |
| `L` | `lightMode` | Light mode flag. |

Known speed mode values in the current patched bundle:

| UI label | `speedMode` bits | Notes |
| --- | --- | --- |
| Low | `"10"` | Current label mapping says Low. Hardware meaning still needs physical confirmation. |
| Medium | `"01"` | Current label mapping says Medium. |
| High | `"00"` | Current label mapping says High/default. |

Important:

- The car's real firmware behavior decides what these bits mean.
- If the car still feels full throttle, the issue may not be packet frequency. The protocol already supports analog bytes `0..255`, but the firmware may ignore intermediate throttle values, or the current speed mode may change how it interprets them.

## 11. Light And Cruise Behavior

Light button:

```text
press/start: lightMode = "1"
release/end: after about 500 ms, lightMode = "0"
```

Cruise button:

```text
press/start: cruiseMode = "1"
release/end: after about 500 ms, cruiseMode = "0"
```

So these are pulse-style controls in the decoded app, not permanent toggles in the packet layer.

## 12. Frontend Contract

A redesigned frontend should treat the backend like this:

1. Keep the target device name `HB TOYS64` unless testing proves the car advertises a different name.
2. Use the existing Bluetooth startup/discovery/connect flow.
3. Do not hardcode a new service UUID unless a BLE scanner confirms the car's real UUIDs.
4. Do not change `sendBLECharacterNotice(...)` packet conversion.
5. Do not add a second timer; the backend already sends every 55 ms while connected.
6. Frontend controls should only update:
   - `speedA`
   - `speedB`
   - `speedMode`
   - `lightMode`
   - `cruiseMode`
   - `isExchange`, if control swapping is still wanted
7. On touch release, always return the axis to neutral `127`.
8. After releasing both controls, make sure at least one neutral packet is sent.
9. Avoid Chinese strings completely in the frontend and any new docs/assets.

Minimum required UI controls:

| UI feature | Backend action |
| --- | --- |
| Connect button | Start/open BLE adapter and begin discovery. |
| Disconnect button | Close current BLE connection and clear send timer. |
| Throttle control | Write proportional value to `speedA`. |
| Steering control | Write proportional value to `speedB`. |
| Speed selector | Set `speedMode` bits. |
| Light control | Pulse `lightMode`. |
| Cruise control | Pulse or toggle `cruiseMode`, depending on desired UX. |
| Status display | Reflect `Ble_on`, battery if later decoded, and signal if later implemented. |

## 13. PWM / Hobby Grade Notes

The decoded app already sends analog-looking control bytes:

```text
speedA: 0..255
speedB: 0..255
neutral: 127
```

That means frontend-side PWM/hobby-grade behavior should first be implemented as input shaping:

- throttle curve
- steering curve
- dead zone
- expo curve
- ramp-up/ramp-down smoothing
- per-speed-mode output caps

However, if the car firmware treats any non-neutral throttle value as full throttle, frontend smoothing alone cannot create true proportional motor control. In that case the firmware or receiver protocol would need another command format or another mode bit.

Recommended diagnostic before changing protocol:

1. Send fixed throttle values while steering remains neutral:
   - `speedA = 135`
   - `speedA = 150`
   - `speedA = 180`
   - `speedA = 220`
   - `speedA = 255`
2. Keep `speedB = 127`.
3. Test each `speedMode` value:
   - `"00"`
   - `"01"`
   - `"10"`
4. Record whether wheel speed changes gradually or jumps to full.

If every non-neutral value gives full throttle, the APK is sending valid analog bytes but the car is behaving like a digital throttle receiver.

## 14. Backend Risks And Open Questions

Known risks:

- Service/characteristic discovery is heuristic. It depends on finding a primary service with exactly two characteristics.
- No incoming BLE telemetry is processed in the decoded app, so battery/signal UI may be cosmetic unless another protocol message is decoded.
- `speedC` exists in rocker state but is not used in the normal remote packet.
- `is4Chan` affects whether the second rocker appears, but the normal packet only sends two axis bytes.
- The speed mode labels may not match the hardware meaning without physical testing.

Open questions for the next implementation:

- Does the car respond proportionally to intermediate `speedA` values?
- Which `speedMode` bit pattern gives maximum real speed on this drift car?
- Does the car have any real battery/signal telemetry over notify, or are those UI-only?
- Should the new UI expose beginner/normal/drift throttle curves instead of the old 1/2/3 labels?
- Should cruise mode remain a pulse, or become a frontend-held state that repeatedly sends `cruiseMode = "1"` while active?

## 15. Recommended Next Frontend Plan

Before designing visuals, lock this backend contract:

1. Keep `HB TOYS64` discovery.
2. Keep the 9-byte packet format.
3. Keep the 55 ms send loop.
4. Build a clean frontend around two analog controls:
   - left control: throttle/brake/reverse
   - right control: steering
5. Add tuning controls that only shape `speedA` and `speedB` before packets are sent.
6. Run physical tests for each speed mode and throttle curve.
7. Only after that, finalize the visual UI.

