# ThaiDictate — Mac Menu Bar App

แปลงเสียงเป็นข้อความภาษาไทย โดยใช้ Apple Speech Recognition แต่ **บังคับ locale = th-TH** เสมอ
ไม่สนใจว่าคีย์บอร์ดปัจจุบันจะเป็นภาษาอะไร

## How it works

- Menu bar app (ไม่มี dock icon)
- ดักจับการกด `Control` 2 ครั้ง (ภายใน 0.4 วินาที) เป็นทริกเกอร์ start/stop
- เมื่อ start → เปิดไมค์ + ส่งเสียงเข้า `SFSpeechRecognizer(locale: "th-TH")`
- เมื่อ stop → รอผลลัพธ์ → copy ไปที่ clipboard → simulate `Cmd+V` → restore clipboard เดิม

## Tech

- Swift 6 + AppKit (no SwiftUI, no Xcode project)
- Frameworks: Cocoa, Speech, AVFoundation
- Build: single `swiftc` command (ดู `build.sh`)
- Bundle ID: `com.madebytle.thaidictate`

## Files

| File | Purpose |
|------|---------|
| `main.swift` | โค้ดทั้งหมดของ app อยู่ในไฟล์เดียว |
| `Info.plist` | Bundle metadata + permission usage descriptions |
| `build.sh` | Compile + create `.app` bundle + ad-hoc sign |
| `ThaiDictate.app` | App ที่ build แล้ว (gitignore ได้) |

## Build & Run

```bash
./build.sh
open ThaiDictate.app
```

## Required permissions (ครั้งแรกใช้)

ต้องเปิด 4 อย่างใน **System Settings → Privacy & Security**:

1. **Microphone** — ป๊อปอัพอัตโนมัติเมื่อ start recording ครั้งแรก
2. **Speech Recognition** — ป๊อปอัพอัตโนมัติเมื่อเปิด app
3. **Input Monitoring** — *ต้องเพิ่มเอง* เพื่อให้ดักจับ Control 2 ครั้งได้
4. **Accessibility** — *ต้องเพิ่มเอง* เพื่อให้ simulate Cmd+V ได้

วิธีเพิ่ม Input Monitoring / Accessibility:
- เปิด System Settings → Privacy & Security → Input Monitoring (หรือ Accessibility)
- คลิก `+` → เลือกไฟล์ `ThaiDictate.app` → เปิดสวิตช์

หลังเพิ่ม permission แต่ละครั้ง อาจต้อง quit app แล้วเปิดใหม่

## Limitations & known issues

- Apple Speech Recognition ภาษาไทยไม่แม่นเท่า OpenAI Whisper — ถ้าต้องการความแม่นสูงกว่า ลอง integrate Whisper แทน
- ไม่มี on-device mode (`requiresOnDeviceRecognition = false`) → ส่งเสียงไป Apple servers
- ใช้ clipboard hack สำหรับ insert text → ถ้า clipboard เดิมเป็น image จะหาย (กู้คืนเฉพาะ string)
- ไม่มี waveform visualization / countdown UI

## Future ideas

- เปลี่ยน backend เป็น Whisper (local via `whisper.cpp` หรือ OpenAI API)
- เพิ่ม config UI สำหรับเลือก hotkey
- Auto-launch on login
- Streaming partial results
