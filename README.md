# ThaiDictate 🎙️

**Mac menu bar app สำหรับพิมพ์ภาษาไทยด้วยเสียง — บังคับเป็นภาษาไทยเสมอ**

แก้ปัญหา macOS Dictation ที่เลือกภาษาตาม keyboard input source — ของเดิมต้องสลับคีย์บอร์ดเป็นไทยก่อนทุกครั้ง  
ตัวนี้ **ไม่ว่าคีย์บอร์ดจะเป็นภาษาอะไร พูดแล้วได้ภาษาไทยเสมอ**

> สร้างเป็นโปรเจค vibe coding ส่วนตัว — แชร์ฟรี เอาไปใช้ ดัดแปลง แจกต่อได้เลย

---

## ✨ Features

- 🎯 **Lock เป็นภาษาไทย 100%** — ไม่สนใจ keyboard input source ปัจจุบัน
- ⌨️ **Hotkey: กด `Control` 2 ครั้ง** เปิด/ปิดไมค์ (เหมือน macOS Dictation ของเดิม)
- 💬 **Live caption** ขึ้นกลางจอด้านบนระหว่างพูด เห็นคำที่ฟังได้แบบ real-time
- 🌐 **โหมดพูดไทย → พิมพ์อังกฤษ** ใช้ Apple Translation framework (offline)
- 📋 **วางข้อความอัตโนมัติ** ลงในช่องที่ cursor อยู่ (Notes, Slack, Browser, ทุกที่)
- 🪶 **Menu bar app เบาๆ** — ไม่กิน dock, ไม่กิน RAM
- 🔒 **On-device mode** ถ้า macOS ของคุณมี Thai offline model (ไม่ส่งเสียงออกเครื่อง)
- 💯 **Open source** — Swift ไฟล์เดียว อ่านง่าย ดัดแปลงเองได้

---

## 📋 Requirements

- macOS **14.4 (Sonoma) ขึ้นไป** — แนะนำ macOS 26 (Tahoe) สำหรับโหมด TH→EN ที่ดีที่สุด
- Apple Silicon หรือ Intel Mac
- ไมโครโฟน (built-in หรือ external)
- ต่อ internet ครั้งแรก (เพื่อให้ macOS โหลด offline models — ดู [section ข้างล่าง](#-ดาวน์โหลด-offline-models-แนะนำ--ทำก่อนใช้))

---

## 🛠 Installation

### ทางที่ 1: Build จาก source (แนะนำ)

```bash
git clone https://github.com/tlejay/ThaiDictate.git
cd ThaiDictate
./build.sh
open ThaiDictate.app
```

ต้องมี **Xcode Command Line Tools** ก่อน:
```bash
xcode-select --install
```

### ทางที่ 2: ดาวน์โหลด build แล้ว

ดูที่ [Releases](../../releases) → ดาวน์โหลด `ThaiDictate.app.zip` ล่าสุด → unzip → ลากเข้า Applications

> ⚠️ ครั้งแรก macOS จะเตือนว่า "ไม่รู้จักผู้พัฒนา" — ไป System Settings → Privacy & Security → กดปุ่ม **Open Anyway**

---

## 📥 ดาวน์โหลด Offline Models (แนะนำ — ทำก่อนใช้)

> ⚠️ ไฟล์เหล่านี้ **ไม่ได้รวมมาใน app/repo นี้** เพราะเป็น model ของ Apple เอง  
> ต้องให้ macOS ดาวน์โหลดให้จาก Apple servers ฟรี (เปิดเครื่องทิ้งไว้ ต่อ Wi-Fi)

### 1. Thai Speech Recognition Model (~1-2 GB)
ทำให้ภาษาไทยทำงาน **offline** ได้ + แม่นขึ้น (Apple's Enhanced Dictation)

1. เปิด **System Settings → Keyboard**
2. ในส่วน **Dictation** → คลิก **Edit** ตรงข้าง Languages
3. ติ๊ก ✅ **Thai (Thailand)**
4. กด **OK**
5. **เปิดเครื่องทิ้งไว้ + ต่อ Wi-Fi** ~30 นาที - 2 ชม. → macOS จะโหลดให้เองใน background

✅ **เช็คว่าโหลดเสร็จยัง:** เปิด ThaiDictate → คลิกที่ 🎙️ ที่ menu bar → ดูบรรทัด `Speech:`
- `On-device ✅` = พร้อมใช้ offline แล้ว 🎉
- `Cloud ☁️` = ยังไม่โหลดเสร็จ / macOS ยังไม่รองรับ (เครื่องจะส่งเสียงไป Apple servers แทน)

### 2. Thai → English Translation Model (~50 MB)
จำเป็นถ้าจะใช้โหมด **"พูดไทย → พิมพ์อังกฤษ"** แบบ offline

วิธีโหลด:
- โหลดอัตโนมัติครั้งแรกที่กดใช้โหมด TH→EN ใน ThaiDictate (จะมี popup ของ macOS เด้งให้ Allow)
- หรือ pre-download ผ่านแอป **Translate** ของ Apple → Settings → Downloaded Languages → เพิ่ม Thai

หลังโหลดเสร็จ → แปลภาษาทำงาน offline 100%

> 💡 ถ้าไม่ต้องการ offline mode ก็ใช้งาน app นี้ได้ตามปกติเลย — แค่จะส่งเสียง/ข้อความผ่าน Apple servers แทน (เร็วเหมือนกัน, ฟรีเหมือนกัน)

---

## 🔑 Permissions (ครั้งแรกใช้งาน)

ต้องเปิด **4 อย่าง** ใน System Settings → Privacy & Security:

| Permission | จะเด้งเอง? | เพื่ออะไร |
|------------|-----------|----------|
| **Microphone** | ✅ เด้งเอง | รับเสียงจากไมค์ |
| **Speech Recognition** | ✅ เด้งเอง | แปลงเสียงเป็นข้อความ |
| **Input Monitoring** | ❌ ต้องเพิ่มเอง | ดักจับการกด Control 2 ครั้ง |
| **Accessibility** | ❌ ต้องเพิ่มเอง | วางข้อความลงช่องที่ cursor อยู่ |

**วิธีเพิ่ม Input Monitoring / Accessibility ด้วยตัวเอง:**
1. เปิด **System Settings → Privacy & Security**
2. คลิก **Input Monitoring** (หรือ **Accessibility**)
3. กดปุ่ม **`+`** → เลือก **`ThaiDictate.app`** → Open
4. เปิดสวิตช์ ON
5. ทำซ้ำกับอีกอันหนึ่ง

หลังเปิด permissions ครบ → quit แล้วเปิด app ใหม่ 1 รอบ

---

## 🎙 วิธีใช้

1. คลิกที่ช่อง textfield ไหนก็ได้ (Notes, Slack, Chrome, Cursor, Notion, ฯลฯ)
2. **กด `Control` 2 ครั้งติดกัน** → menu bar เปลี่ยนเป็น 🔴 ฟัง… + กล่อง caption ขึ้นกลางจอด้านบน
3. **พูดภาษาไทย** → เห็นคำที่ฟังได้แบบ real-time ในกล่อง caption
4. **กด `Control` 2 ครั้งอีกครั้ง** → ข้อความวางลงในช่องอัตโนมัติ ✨

### 🌐 โหมดพูดไทย → พิมพ์อังกฤษ
1. คลิกไอคอน 🎙️ ที่ menu bar
2. เลือก **"อังกฤษ (พูดไทย → พิมพ์อังกฤษ)"**
3. ใช้ hotkey เหมือนเดิม → พูดไทย → ข้อความที่วางจะเป็น English

> ⚠️ ครั้งแรกที่ใช้โหมดนี้: macOS อาจมี popup ขออนุญาตโหลด Thai-English translation model ~50MB → กด **Allow / Download**

---

## 🐛 Troubleshooting

### กด Control 2 ครั้งแล้วไม่ทำงาน
- เช็คว่าเปิด **Input Monitoring** ให้ ThaiDictate.app แล้วหรือยัง
- Quit แล้วเปิด app ใหม่หลังเปิด permission

### ข้อความไม่ถูกวางลงในช่อง
- เช็คว่าเปิด **Accessibility** ให้ ThaiDictate.app แล้วหรือยัง
- ตรวจสอบว่ามีช่อง text field active อยู่จริง

### พูดแล้วไม่ขึ้นอะไร
- เช็ค menu bar ว่าเปลี่ยนเป็น 🔴 ฟัง… จริงมั้ย
- เช็ค Microphone permission
- ลองพูดดังๆ ใกล้ไมค์ขึ้น

### Apple Speech แปลงผิดเยอะ
- น่าเสียดาย Apple ASR ภาษาไทยยังไม่แม่นเท่า OpenAI Whisper
- ถ้าต้องการความแม่นสูงกว่า → ดู [Future Ideas](#-future-ideas) ข้างล่าง

### ปิด app ไม่ได้ / หายจาก menu bar
```bash
pkill -f ThaiDictate
```

---

## 🏗 Tech Stack

- **Swift 6** + AppKit + SwiftUI (สำหรับ Translation framework เท่านั้น)
- Apple's **Speech framework** (`SFSpeechRecognizer` locked to `th-TH`)
- Apple's **Translation framework** (TH→EN offline translation)
- **AVFoundation** สำหรับรับเสียงจากไมค์
- **NSEvent global monitor** สำหรับดักจับ Control 2 ครั้ง
- **NSPanel + NSVisualEffectView** สำหรับ Live Caption HUD
- **CGEvent** สำหรับ simulate Cmd+V
- ทั้งหมดอยู่ใน **`main.swift` ไฟล์เดียว** — อ่านง่าย, hack ได้

---

## 📁 Project Structure

```
ThaiDictate/
├── main.swift            # Source code ทั้งหมด อยู่ในไฟล์เดียว
├── generate_icon.swift   # Render app icon ทุกขนาดจาก SF Symbol
├── AppIcon.icns          # Icon ที่ render แล้ว (commit ไว้)
├── Info.plist            # App metadata + permission descriptions
├── build.sh              # Compile + bundle + ad-hoc sign
├── README.md             # คุณกำลังอ่านอยู่
└── LICENSE               # MIT
```

---

## 🚀 Future Ideas

อยากช่วยพัฒนาต่อ? PR welcome! ไอเดียที่อยากได้:

- [ ] **Whisper backend** — ใช้ OpenAI Whisper (local via `whisper.cpp` หรือ WhisperKit) เพื่อความแม่นที่สูงขึ้น
- [ ] **Configurable hotkey** — ให้ผู้ใช้เลือก hotkey เองได้
- [ ] **Auto-launch on login** — เปิดเองตอนเปิดเครื่อง
- [ ] **เพิ่มภาษาเป้าหมายอื่น** — เช่น TH→JP, TH→ZH (Apple Translation รองรับ)
- [ ] **Sound feedback** — เสียงปี๊บตอนเริ่ม/หยุดบันทึก
- [ ] **Notarize + DMG release** — เพื่อให้ดาวน์โหลดและติดตั้งง่ายโดยไม่ต้อง build เอง

---

## 📝 License

MIT — เอาไปใช้ ดัดแปลง แจก ขายได้ตามสบาย ขอแค่ keep credit ไว้ ดู [LICENSE](LICENSE)

---

## 🙏 Credits

สร้างโดย **Tle** ด้วย Claude Code

ส่วนหนึ่งของ **[madebytle.com](https://madebytle.com)**

ถ้าใช้แล้วชอบ บอกต่อเพื่อนหน่อย 💚
