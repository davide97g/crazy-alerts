#!/usr/bin/env swift

import Cocoa

// MARK: - Configuration
struct SirenConfig {
    static let message: String = {
        let raw = ProcessInfo.processInfo.environment["SIREN_MESSAGE"] ?? "Alert"
        return raw.trimmingCharacters(in: .whitespaces)
    }()
    static let duration = Double(ProcessInfo.processInfo.environment["SIREN_DURATION"] ?? "10") ?? 10
    static let fontSize = CGFloat(Double(ProcessInfo.processInfo.environment["SIREN_FONT_SIZE"] ?? "48") ?? 48)

    static let assetsDir: String = {
        if let dir = ProcessInfo.processInfo.environment["SIREN_ASSETS_DIR"], !dir.isEmpty { return dir }
        return FileManager.default.currentDirectoryPath + "/assets"
    }()
}

private func sirenFont(size: CGFloat) -> NSFont {
    (NSFont(name: "Avenir Next Heavy", size: size)
        ?? NSFont(name: "Avenir-Heavy", size: size)
        ?? NSFont.boldSystemFont(ofSize: size))
}

// MARK: - Siren View (full-screen red pulse + message)
class SirenView: NSView {
    var phase: CGFloat = 0
    var timer: Timer?
    var alarmSound: NSSound?

    override init(frame: NSRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) { fatalError() }

    func startAnimation() {
        let soundPath = (SirenConfig.assetsDir as NSString).appendingPathComponent("alarm.wav")
        if FileManager.default.fileExists(atPath: soundPath), let sound = NSSound(contentsOfFile: soundPath, byReference: false) {
            alarmSound = sound
        } else {
            alarmSound = NSSound(named: "Glass")
        }
        alarmSound?.loops = true
        alarmSound?.play()

        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
            self?.phase += 0.12
            self?.setNeedsDisplay(self?.bounds ?? .zero)
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    override func draw(_ dirtyRect: NSRect) {
        let pulse = 0.4 + 0.6 * sin(phase)
        let red = NSColor.systemRed.withAlphaComponent(pulse * 0.85)
        red.setFill()
        dirtyRect.fill()

        guard !SirenConfig.message.isEmpty else { return }

        let font = sirenFont(size: SirenConfig.fontSize)
        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: NSColor.white,
        ]
        let str = NSAttributedString(string: SirenConfig.message, attributes: attrs)
        let size = str.size()
        let x = (bounds.width - size.width) / 2
        let y = (bounds.height - size.height) / 2
        str.draw(at: NSPoint(x: x, y: y))
    }
}

// MARK: - Main
let app = NSApplication.shared
app.setActivationPolicy(.accessory)

var windows: [NSWindow] = []
var sirenViews: [SirenView] = []

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
    window.backgroundColor = .clear
    window.isOpaque = false
    window.hasShadow = false
    window.ignoresMouseEvents = true
    window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

    let viewFrame = NSRect(x: 0, y: 0, width: screen.frame.width, height: screen.frame.height)
    let view = SirenView(frame: viewFrame)
    window.contentView = view
    window.orderFrontRegardless()
    windows.append(window)
    sirenViews.append(view)
    view.startAnimation()
}

DispatchQueue.main.asyncAfter(deadline: .now() + SirenConfig.duration) {
    sirenViews.forEach { $0.alarmSound?.stop() }
    NSApp.terminate(nil)
}

app.run()
