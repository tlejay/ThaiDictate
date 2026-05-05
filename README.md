# ThaiDictate 🎙️

**Mac menu bar app สำหรับพิมพ์ภาษาไทยด้วยเสียง — บังคับเป็นภาษาไทยเสมอ**

แก้ปัญหา macOS Dictation ที่เลือกภาษาตาม keyboard input source — ของเดิมต้องสลับคีย์บอร์ดเป็นไทยก่อนทุกครั้ง  
ตัวนี้ **ไม่ว่าคีย์บอร์ดจะเป็นภาษาอะไร พูดแล้วได้ภาษาไทยเสมอ**

> สร้างเป็นโปรเจค vibe coding ส่วนตัว — แชร์ฟรี เอาไปใช้ ดัดแปลง แจกต่อได้เลย

---

## ✨ Features

- 🎯 **Lock เป็นภาษาไทย 100%** — ไม่สนใจ keyboard input source ปัจจุบัน
- ⌨️ **Hotkey: กด `Control` 2 ครั้ง** เปิด/ปิดไมค์ (เหมือน macOS Dictation ของเดิม)
- 📋 **วางข้อความอัตโนมัติ** ลงในช่องที่ cursor อยู่ (Notes, Slack, Browser, ทุกที่)
- 🪶 **Menu bar app เบาๆ** — ไม่กิน dock, ไม่กิน RAM
- 🔒 **On-device mode** ถ้า macOS ของคุณมี Thai offline model (ส่งข้อมูลออกน้อยลง)
- 💯 **Open source** — Swift ไฟล์เดียว อ่านง่าย ดัดแปลงเองได้

---

## 📋 Requirements

- macOS **13 (Ventura) ขึ้นไป** — แนะนำ macOS 26 (Tahoe)
- Apple Silicon หรือ Intel Mac
- ไมโครโฟน (built-in หรือ external)
- ต่อ internet (ถ้าเครื่องยังไม่มี on-device Thai model)

---

## 🛠 Installation

### ทางที่ 1: Build จาก source (แนะนำ)

```bash
git clone https://github.com/<your-username>/ThaiDictate.git
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
2. **กด `Control` 2 ครั้งติดกัน** → menu bar เปลี่ยนเป็น 🔴 ฟัง…
3. **พูดภาษาไทย**
4. **กด `Control` 2 ครั้งอีกครั้ง** → ข้อความวางลงในช่องอัตโนมัติ ✨

> 💡 ถ้าต้องการเปิด/ปิดจากเมนูแทน hotkey → คลิกไอคอน 🎙️ ไทย ที่ menu bar

---

## 🧠 On-device vs Cloud Mode

ดูได้จากเมนู (คลิกที่ 🎙️ ไทย):

- **On-device (offline) ✅** — macOS มี Thai model แล้ว ทำงาน offline ได้ ไม่ส่งเสียงออกเครื่อง
- **Cloud (ส่งเสียงไป Apple) ☁️** — ยังไม่มี Thai offline model ส่งเสียงไปประมวลผลที่ Apple servers

**ทำให้ Mac โหลด Thai offline model:**
1. System Settings → Keyboard → Dictation → Languages
2. ต้องมี **Thai (Thailand)** อยู่ในลิสต์
3. เปิด Mac ทิ้งไว้ ต่อ Wi-Fi → macOS จะดาวน์โหลดเองใน background
4. รอประมาณ 30 นาที - 2 ชม. (ขึ้นกับเน็ตและความว่างของเครื่อง)

> ⚠️ macOS รุ่นเก่ายังไม่รองรับ Thai offline — ของจะตกไปใช้ Cloud mode อัตโนมัติ

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

- **Swift 6** + AppKit (no SwiftUI, no Xcode project, no dependencies)
- Apple's **Speech framework** (`SFSpeechRecognizer` locked to `th-TH`)
- **AVFoundation** สำหรับรับเสียงจากไมค์
- **NSEvent global monitor** สำหรับดักจับ Control 2 ครั้ง
- **CGEvent** สำหรับ simulate Cmd+V
- ทั้งหมดอยู่ใน **`main.swift` ไฟล์เดียว** — อ่านง่าย, hack ได้

---

## 📁 Project Structure

```
ThaiDictate/
├── main.swift          # Source code ทั้งหมด อยู่ในไฟล์เดียว
├── Info.plist          # App metadata + permission descriptions
├── build.sh            # Compile + bundle + ad-hoc sign
├── README.md           # คุณกำลังอ่านอยู่
└── LICENSE             # MIT
```

---

## 🚀 Future Ideas

อยากช่วยพัฒนาต่อ? PR welcome! ไอเดียที่อยากได้:

- [ ] **Whisper backend** — ใช้ OpenAI Whisper (local via `whisper.cpp` หรือ API) เพื่อความแม่นที่สูงขึ้น
- [ ] **Configurable hotkey** — ให้ผู้ใช้เลือก hotkey เองได้
- [ ] **Auto-launch on login** — เปิดเองตอนเปิดเครื่อง
- [ ] **Streaming partial results** — แสดงข้อความ live ระหว่างพูด
- [ ] **Multi-language toggle** — สลับ TH ↔ EN จากเมนู (ไม่ต้องเข้า System Settings)
- [ ] **Sound feedback** — เสียงปี๊บตอนเริ่ม/หยุดบันทึก
- [ ] **Notarize + DMG release** — เพื่อให้ดาวน์โหลดและติดตั้งง่ายโดยไม่ต้อง build เอง

---

## 📝 License

MIT — เอาไปใช้ ดัดแปลง แจก ขายได้ตามสบาย ขอแค่ keep credit ไว้ ดู [LICENSE](LICENSE)

---

## 🙏 Credits

สร้างโดย **Tle (Jakapong)** ด้วย Claude Code (vibe coding)

ส่วนหนึ่งของ **[madebytle.com](https://madebytle.com)** — รวมผลงานจากการสร้าง Tech Product

ถ้าใช้แล้วชอบ บอกต่อเพื่อนหน่อย 💚
