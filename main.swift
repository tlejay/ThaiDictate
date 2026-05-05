import Cocoa
import Speech
import AVFoundation

let DOUBLE_TAP_INTERVAL: TimeInterval = 0.4
let LOCALE_ID = "th-TH"

class AppCoordinator: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var globalMonitor: Any?

    private var lastControlDownAt: Date?
    private var wasControlPressed = false

    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: LOCALE_ID))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private var isRecording = false
    private var savedClipboard: String?

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenuBar()
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                if status != .authorized {
                    self.showAlert(
                        title: "ต้องอนุญาต Speech Recognition",
                        message: "เปิด System Settings → Privacy & Security → Speech Recognition แล้วเปิดให้ ThaiDictate"
                    )
                }
            }
        }
        startMonitoringHotkey()
    }

    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        updateStatusIcon()

        let menu = NSMenu()
        let toggleItem = NSMenuItem(title: "เริ่ม / หยุดบันทึก  (กด Control 2 ครั้ง)",
                                    action: #selector(toggle),
                                    keyEquivalent: "")
        toggleItem.target = self
        menu.addItem(toggleItem)
        menu.addItem(NSMenuItem.separator())

        let langItem = NSMenuItem(title: "ภาษา: ไทย (บังคับเสมอ)", action: nil, keyEquivalent: "")
        langItem.isEnabled = false
        menu.addItem(langItem)

        let onDeviceText = recognizer.supportsOnDeviceRecognition
            ? "โหมด: On-device (offline) ✅"
            : "โหมด: Cloud (ส่งเสียงไป Apple) ☁️"
        let modeItem = NSMenuItem(title: onDeviceText, action: nil, keyEquivalent: "")
        modeItem.isEnabled = false
        menu.addItem(modeItem)

        menu.addItem(NSMenuItem.separator())
        let quitItem = NSMenuItem(title: "ออกจากโปรแกรม", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    private func updateStatusIcon() {
        guard let button = statusItem.button else { return }
        button.title = isRecording ? "🔴 ฟัง…" : "🎙️ ไทย"
    }

    private func startMonitoringHotkey() {
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: .flagsChanged) { [weak self] event in
            self?.handleFlagsChanged(event)
        }
        if globalMonitor == nil {
            print("Could not register global monitor (Input Monitoring permission required).")
        }
    }

    private func handleFlagsChanged(_ event: NSEvent) {
        let isControlNow = event.modifierFlags.contains(.control)

        if isControlNow && !wasControlPressed {
            let now = Date()
            if let last = lastControlDownAt, now.timeIntervalSince(last) < DOUBLE_TAP_INTERVAL {
                lastControlDownAt = nil
                DispatchQueue.main.async { [weak self] in
                    self?.toggle()
                }
            } else {
                lastControlDownAt = now
            }
        }
        wasControlPressed = isControlNow
    }

    @objc private func toggle() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }

    private func startRecording() {
        recognitionTask?.cancel()
        recognitionTask = nil

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = false
        if recognizer.supportsOnDeviceRecognition {
            request.requiresOnDeviceRecognition = true
        }
        recognitionRequest = request

        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)

        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
            request.append(buffer)
        }

        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print("Audio engine failed: \(error)")
            showAlert(title: "เปิดไมค์ไม่ได้", message: "\(error.localizedDescription)")
            return
        }

        recognitionTask = recognizer.recognitionTask(with: request) { [weak self] result, error in
            guard let self = self else { return }
            if let result = result, result.isFinal {
                let text = result.bestTranscription.formattedString
                DispatchQueue.main.async {
                    self.insertText(text)
                    self.cleanupAudio()
                }
            } else if let error = error {
                let nserr = error as NSError
                if nserr.code != 203 && nserr.code != 216 {
                    print("Recognition error: \(error)")
                }
                DispatchQueue.main.async {
                    self.cleanupAudio()
                }
            }
        }

        isRecording = true
        updateStatusIcon()
    }

    private func stopRecording() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        isRecording = false
        updateStatusIcon()
    }

    private func cleanupAudio() {
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest = nil
        recognitionTask = nil
        if isRecording {
            isRecording = false
            updateStatusIcon()
        }
    }

    private func insertText(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let pb = NSPasteboard.general
        savedClipboard = pb.string(forType: .string)
        pb.clearContents()
        pb.setString(trimmed, forType: .string)

        let src = CGEventSource(stateID: .combinedSessionState)
        let vKey: CGKeyCode = 9
        let down = CGEvent(keyboardEventSource: src, virtualKey: vKey, keyDown: true)
        let up = CGEvent(keyboardEventSource: src, virtualKey: vKey, keyDown: false)
        down?.flags = .maskCommand
        up?.flags = .maskCommand

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            down?.post(tap: .cghidEventTap)
            up?.post(tap: .cghidEventTap)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
            guard let self = self else { return }
            if let old = self.savedClipboard {
                pb.clearContents()
                pb.setString(old, forType: .string)
            }
            self.savedClipboard = nil
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }
}

let app = NSApplication.shared
let delegate = AppCoordinator()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
