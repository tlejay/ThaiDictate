import Cocoa
import Speech
import AVFoundation
import SwiftUI
import Translation

let DOUBLE_TAP_INTERVAL: TimeInterval = 0.4
let LOCALE_ID = "th-TH"

enum OutputLanguage: String {
    case thai
    case english
}

// MARK: - Live Caption Window

final class LiveCaptionWindow {
    private let panel: NSPanel
    private let label: NSTextField
    private let visualEffect: NSVisualEffectView

    init() {
        panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 520, height: 64),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.isFloatingPanel = true
        panel.level = .statusBar
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .ignoresCycle]
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = true
        panel.ignoresMouseEvents = true
        panel.hidesOnDeactivate = false

        visualEffect = NSVisualEffectView(frame: panel.contentView!.bounds)
        visualEffect.material = .hudWindow
        visualEffect.blendingMode = .behindWindow
        visualEffect.state = .active
        visualEffect.wantsLayer = true
        visualEffect.layer?.cornerRadius = 18
        visualEffect.layer?.masksToBounds = true
        visualEffect.autoresizingMask = [.width, .height]

        label = NSTextField(labelWithString: "")
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .white
        label.alignment = .center
        label.maximumNumberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        label.cell?.usesSingleLineMode = false

        visualEffect.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: visualEffect.leadingAnchor, constant: 24),
            label.trailingAnchor.constraint(equalTo: visualEffect.trailingAnchor, constant: -24),
            label.centerYAnchor.constraint(equalTo: visualEffect.centerYAnchor)
        ])

        panel.contentView = visualEffect
    }

    func show(text: String) {
        label.stringValue = text.isEmpty ? "🎙️ กำลังฟัง…" : text
        positionAtTopCenter()
        panel.orderFrontRegardless()
    }

    func update(text: String) {
        label.stringValue = text.isEmpty ? "🎙️ กำลังฟัง…" : text
    }

    func hide() {
        panel.orderOut(nil)
    }

    private func positionAtTopCenter() {
        guard let screen = NSScreen.main else { return }
        let visible = screen.visibleFrame
        let width: CGFloat = 520
        let height: CGFloat = 64
        let x = visible.midX - width / 2
        let y = visible.maxY - height - 24
        panel.setFrame(NSRect(x: x, y: y, width: width, height: height), display: true)
    }
}

// MARK: - Translation Manager (uses Apple Translation framework via hidden SwiftUI host)

final class TranslationManager: ObservableObject {
    @Published var pendingInput: String = ""
    @Published var configuration: TranslationSession.Configuration?

    private var hostingWindow: NSWindow?
    private var pendingCompletion: ((String?) -> Void)?

    init() {
        setupHostingWindow()
    }

    private func setupHostingWindow() {
        let view = TranslationHostView(manager: self)
        let hostingView = NSHostingView(rootView: view)
        let window = NSWindow(
            contentRect: NSRect(x: -1000, y: -1000, width: 1, height: 1),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        window.contentView = hostingView
        window.alphaValue = 0
        window.isReleasedWhenClosed = false
        window.ignoresMouseEvents = true
        window.orderFront(nil)
        hostingWindow = window
    }

    func translate(_ text: String, completion: @escaping (String?) -> Void) {
        pendingCompletion = completion
        pendingInput = text
        configuration = TranslationSession.Configuration(
            source: Locale.Language(identifier: "th"),
            target: Locale.Language(identifier: "en")
        )
    }

    func deliver(result: String?) {
        let cb = pendingCompletion
        pendingCompletion = nil
        cb?(result)
    }
}

struct TranslationHostView: View {
    @ObservedObject var manager: TranslationManager

    var body: some View {
        Color.clear
            .frame(width: 1, height: 1)
            .translationTask(manager.configuration) { session in
                let input = manager.pendingInput
                guard !input.isEmpty else { return }
                do {
                    let response = try await session.translate(input)
                    await MainActor.run {
                        manager.deliver(result: response.targetText)
                    }
                } catch {
                    print("Translation error: \(error)")
                    await MainActor.run {
                        manager.deliver(result: nil)
                    }
                }
            }
    }
}

// MARK: - App Coordinator

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

    private let captionWindow = LiveCaptionWindow()
    private let translationManager = TranslationManager()

    private var outputLanguage: OutputLanguage = .thai
    private var thaiToThaiItem: NSMenuItem!
    private var thaiToEnglishItem: NSMenuItem!

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

        let outputHeader = NSMenuItem(title: "ผลลัพธ์ออกมาเป็น:", action: nil, keyEquivalent: "")
        outputHeader.isEnabled = false
        menu.addItem(outputHeader)

        thaiToThaiItem = NSMenuItem(title: "  ไทย (พูดไทย → พิมพ์ไทย)",
                                    action: #selector(setThaiOutput),
                                    keyEquivalent: "")
        thaiToThaiItem.target = self
        menu.addItem(thaiToThaiItem)

        thaiToEnglishItem = NSMenuItem(title: "  อังกฤษ (พูดไทย → พิมพ์อังกฤษ)",
                                       action: #selector(setEnglishOutput),
                                       keyEquivalent: "")
        thaiToEnglishItem.target = self
        menu.addItem(thaiToEnglishItem)
        updateOutputCheckmarks()

        menu.addItem(NSMenuItem.separator())

        let onDeviceText = recognizer.supportsOnDeviceRecognition
            ? "Speech: On-device ✅"
            : "Speech: Cloud ☁️"
        let modeItem = NSMenuItem(title: onDeviceText, action: nil, keyEquivalent: "")
        modeItem.isEnabled = false
        menu.addItem(modeItem)

        menu.addItem(NSMenuItem.separator())
        let quitItem = NSMenuItem(title: "ออกจากโปรแกรม", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    private func updateOutputCheckmarks() {
        thaiToThaiItem.state = (outputLanguage == .thai) ? .on : .off
        thaiToEnglishItem.state = (outputLanguage == .english) ? .on : .off
    }

    @objc private func setThaiOutput() {
        outputLanguage = .thai
        updateOutputCheckmarks()
        updateStatusIcon()
    }

    @objc private func setEnglishOutput() {
        outputLanguage = .english
        updateOutputCheckmarks()
        updateStatusIcon()
    }

    private func updateStatusIcon() {
        guard let button = statusItem.button else { return }
        if isRecording {
            button.title = "🔴 ฟัง…"
        } else {
            button.title = outputLanguage == .english ? "🎙️ TH→EN" : "🎙️ ไทย"
        }
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
        request.shouldReportPartialResults = true
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

            if let result = result {
                let text = result.bestTranscription.formattedString
                if result.isFinal {
                    DispatchQueue.main.async {
                        self.handleFinalResult(thaiText: text)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.captionWindow.update(text: text)
                    }
                }
            } else if let error = error {
                let nserr = error as NSError
                if nserr.code != 203 && nserr.code != 216 {
                    print("Recognition error: \(error)")
                }
                DispatchQueue.main.async {
                    self.captionWindow.hide()
                    self.cleanupAudio()
                }
            }
        }

        isRecording = true
        updateStatusIcon()
        captionWindow.show(text: "")
    }

    private func handleFinalResult(thaiText: String) {
        let trimmed = thaiText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            captionWindow.hide()
            cleanupAudio()
            return
        }

        switch outputLanguage {
        case .thai:
            captionWindow.hide()
            insertText(trimmed)
            cleanupAudio()
        case .english:
            captionWindow.update(text: "🌐 กำลังแปล…")
            translationManager.translate(trimmed) { [weak self] english in
                guard let self = self else { return }
                let textToInsert = english ?? trimmed
                self.captionWindow.hide()
                self.insertText(textToInsert)
                self.cleanupAudio()
            }
        }
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
