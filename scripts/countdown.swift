#!/usr/bin/env swift

import Cocoa

// MARK: - Configuration
struct CountdownConfig {
    static let start: Int = {
        let raw = ProcessInfo.processInfo.environment["COUNTDOWN_START"] ?? "5"
        return Int(raw) ?? 5
    }()
    static let message: String = {
        let raw = ProcessInfo.processInfo.environment["COUNTDOWN_MESSAGE"] ?? ""
        return raw.trimmingCharacters(in: .whitespaces)
    }()
    static let durationAfterZero: Double = {
        let raw = ProcessInfo.processInfo.environment["COUNTDOWN_DURATION_AFTER_ZERO"] ?? "2"
        return Double(raw) ?? 2
    }()
    static let soundAtZero: Bool = {
        let raw = ProcessInfo.processInfo.environment["COUNTDOWN_SOUND_AT_ZERO"] ?? "1"
        return (raw as NSString).boolValue
    }()
    static let fontSize: CGFloat = {
        let raw = ProcessInfo.processInfo.environment["COUNTDOWN_FONT_SIZE"] ?? "160"
        return CGFloat(Double(raw) ?? 160)
    }()

    static let assetsDir: String = {
        if let dir = ProcessInfo.processInfo.environment["COUNTDOWN_ASSETS_DIR"], !dir.isEmpty { return dir }
        return FileManager.default.currentDirectoryPath + "/assets"
    }()
}

private func countdownFont(size: CGFloat) -> NSFont {
    (NSFont(name: "Avenir Next Heavy", size: size)
        ?? NSFont(name: "Avenir-Heavy", size: size)
        ?? NSFont.boldSystemFont(ofSize: size))
}

// MARK: - Countdown View
class CountdownView: NSView {
    var current: Int
    var timer: Timer?
    var phase: CGFloat = 0
    var zeroSoundPlayed = false

    init(frame: NSRect, start: Int) {
        self.current = start
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) { fatalError() }

    func startCountdown() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.current -= 1
            if self.current < 0 {
                self.timer?.invalidate()
                self.timer = nil
                if CountdownConfig.soundAtZero, !self.zeroSoundPlayed {
                    self.zeroSoundPlayed = true
                    let s: NSSound? = {
                        let wav = (CountdownConfig.assetsDir as NSString).appendingPathComponent("success.wav")
                        if FileManager.default.fileExists(atPath: wav), let s = NSSound(contentsOfFile: wav, byReference: false) {
                            return s
                        }
                        return NSSound(named: "Hero")
                    }()
                    s?.play()
                }
            }
            self.setNeedsDisplay(self.bounds)
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    override func draw(_ dirtyRect: NSRect) {
        NSColor.clear.setFill()
        dirtyRect.fill()

        let font = countdownFont(size: CountdownConfig.fontSize)
        let displayText: String
        if current >= 0 {
            displayText = "\(current)"
        } else {
            displayText = "Go!"
        }

        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: NSColor.white,
        ]
        let str = NSAttributedString(string: displayText, attributes: attrs)
        let size = str.size()
        let x = (bounds.width - size.width) / 2
        let y = (bounds.height - size.height) / 2
        str.draw(at: NSPoint(x: x, y: y))

        if !CountdownConfig.message.isEmpty, current >= 0 {
            let msgFont = countdownFont(size: 28)
            let msgAttrs: [NSAttributedString.Key: Any] = [
                .font: msgFont,
                .foregroundColor: NSColor.white.withAlphaComponent(0.9),
            ]
            let msgStr = NSAttributedString(string: CountdownConfig.message, attributes: msgAttrs)
            let msgSize = msgStr.size()
            let msgX = (bounds.width - msgSize.width) / 2
            let msgY = y - msgSize.height - 20
            msgStr.draw(at: NSPoint(x: msgX, y: msgY))
        }
    }
}

// MARK: - Main
let app = NSApplication.shared
app.setActivationPolicy(.accessory)

var windows: [NSWindow] = []
let startVal = max(0, CountdownConfig.start)
let totalSeconds = Double(startVal) + CountdownConfig.durationAfterZero + 1

for screen in NSScreen.screens {
    let localContentRect = NSRect(x: 0, y: 0, width: screen.frame.width, height: screen.frame.height)
    let window = NSWindow(
        contentRect: localContentRect,
        styleMask: .borderless,
        backing: .buffered,
        defer: false,
        screen: screen
    )
    window.setFrame(screen.frame, display: true)
    window.level = NSWindow.Level(rawValue: Int(CGShieldingWindowLevel()))
    window.backgroundColor = NSColor.black.withAlphaComponent(0.75)
    window.isOpaque = false
    window.hasShadow = false
    window.ignoresMouseEvents = true
    window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

    let viewFrame = NSRect(x: 0, y: 0, width: screen.frame.width, height: screen.frame.height)
    let view = CountdownView(frame: viewFrame, start: startVal)
    window.contentView = view
    window.orderFrontRegardless()
    windows.append(window)
    view.startCountdown()
}

DispatchQueue.main.asyncAfter(deadline: .now() + totalSeconds) {
    NSApp.terminate(nil)
}

app.run()
