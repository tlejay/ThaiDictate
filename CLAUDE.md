# ThaiDictate — Mac Menu Bar App

แปลงเสียงเป็นข้อความภาษาไทย โดย **lock locale = th-TH** เสมอ ไม่ขึ้นกับ keyboard input source ปัจจุบัน
รวมถึงโหมด TH→EN ที่แปลผลลัพธ์เป็นอังกฤษด้วย Apple Translation framework (offline)

## Architecture

- Menu bar app (`LSUIElement = true`, no dock icon)
- Hotkey: `Control` 2 ครั้งภายใน 0.4s ผ่าน `NSEvent.addGlobalMonitorForEvents`
- Speech: `SFSpeechRecognizer(locale: "th-TH")` + `requiresOnDeviceRecognition` ถ้ารองรับ
- Live caption: `NSPanel` (nonactivatingPanel) + `NSVisualEffectView` (HUD blur) ลอยกลางจอ
- Translation: hidden `NSHostingView` ขนาด 1×1 px มุมจอ → SwiftUI `.translationTask` → `TranslationSession`
- Output: clipboard + simulate `Cmd+V` ด้วย `CGEvent.post(tap: .cghidEventTap)`

## Tech

- Swift 6 + AppKit + ส่วนเล็กๆ ของ SwiftUI (สำหรับ Translation framework เท่านั้น)
- Frameworks: Cocoa, Speech, AVFoundation, SwiftUI, Translation, ApplicationServices, UserNotifications
- Build: single `swiftc` command (ดู `build.sh`) — no Xcode project, no SPM
- Bundle ID: `com.madebytle.thaidictate`
- Min macOS: 14.4 (Translation framework)

## Files

| File | Purpose |
|------|---------|
| `main.swift` | Source code ทั้งหมดของ app อยู่ในไฟล์เดียว |
| `generate_icon.swift` | Render `AppIcon.iconset/` ทุกขนาดด้วย CoreGraphics + SF Symbol |
| `AppIcon.icns` | Compiled icon (commit ไว้ในซอร์ส) |
| `Info.plist` | Bundle metadata + permission usage descriptions |
| `build.sh` | Compile → bundle → ad-hoc sign |

`AppIcon.iconset/` และ `ThaiDictate.app/` อยู่ใน `.gitignore`

## Build & Run

```bash
./build.sh
open ThaiDictate.app
```

## Required permissions (first run)

ต้องเปิดใน **System Settings → Privacy & Security**:

1. **Microphone** — auto prompt
2. **Speech Recognition** — auto prompt
3. **Input Monitoring** — manual add (สำหรับดักจับ Control 2 ครั้ง)
4. **Accessibility** — manual add (สำหรับ simulate Cmd+V)

หมายเหตุ: ad-hoc signed builds เปลี่ยน cdhash ทุก build → macOS อาจ revoke permissions
หาก hotkey หรือ paste หยุดทำงานหลัง rebuild ให้ลบ ThaiDictate.app ออกจาก list แล้ว add ใหม่

## Known limitations

- Apple ASR ภาษาไทยยังไม่แม่นเท่า OpenAI Whisper
- Clipboard hack สำหรับ insert text → ถ้า clipboard เดิมเป็น image จะกู้กลับไม่ได้ (กู้คืนเฉพาะ string)
- `SFSpeechRecognizer` มี bug: เมื่อใช้ `shouldReportPartialResults=true` + `requiresOnDeviceRecognition=true`
  → callback `isFinal=true` บางทีไม่ยิง → workaround คือเก็บ `latestPartialText` แล้ว paste ทันทีตอนหยุด
- Translation framework ค้างถ้า language pack ยังไม่โหลด → workaround คือ 8s timeout + fallback paste ภาษาไทย

## Future ideas

- Whisper backend (whisper.cpp / WhisperKit) เพื่อความแม่นที่สูงขึ้น
- Configurable hotkey
- Auto-launch on login
- เพิ่มภาษาเป้าหมายอื่น (TH→JP, TH→ZH ฯลฯ)
- Sound feedback
- Notarize + DMG release
