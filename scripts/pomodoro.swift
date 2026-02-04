#!/usr/bin/env swift

import Cocoa

struct PomodoroConfig {
    static let message: String = {
        let raw = ProcessInfo.processInfo.environment["POMODORO_MESSAGE"] ?? "Time for a break"
        return raw.trimmingCharacters(in: .whitespaces)
    }()
    static let duration = Double(ProcessInfo.processInfo.environment["POMODORO_DURATION"] ?? "8") ?? 8
    static let fontSize = CGFloat(Double(ProcessInfo.processInfo.environment["POMODORO_FONT_SIZE"] ?? "44") ?? 44)
    static let assetsDir: String = {
        if let d = ProcessInfo.processInfo.environment["POMODORO_ASSETS_DIR"], !d.isEmpty { return d }
        return FileManager.default.currentDirectoryPath + "/assets"
    }()
}

class PomodoroView: NSView {
    var phase: CGFloat = 0
    var timer: Timer?

    override init(frame: NSRect) { super.init(frame: frame) }
    required init?(coder: NSCoder) { fatalError() }

    func start() {
        let path = (PomodoroConfig.assetsDir as NSString).appendingPathComponent("success.wav")
        if FileManager.default.fileExists(atPath: path), let s = NSSound(contentsOfFile: path, byReference: false) { s.play() }
        else { NSSound(named: "Ping")?.play() }
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
            self?.phase += 0.05
            self?.setNeedsDisplay(self?.bounds ?? .zero)
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    override func draw(_ dirtyRect: NSRect) {
        NSColor.black.withAlphaComponent(0.5).setFill()
        dirtyRect.fill()
        let centerX = bounds.midX
        let centerY = bounds.midY
        let icon = "☕"
        let iconFont = NSFont.systemFont(ofSize: 64)
        let iconStr = NSAttributedString(string: icon, attributes: [.font: iconFont, .foregroundColor: NSColor.systemOrange])
        let iconSz = iconStr.size()
        iconStr.draw(at: NSPoint(x: centerX - iconSz.width / 2, y: centerY - iconSz.height / 2 + 40))
        let msgStr = NSAttributedString(string: PomodoroConfig.message, attributes: [.font: NSFont.boldSystemFont(ofSize: PomodoroConfig.fontSize), .foregroundColor: NSColor.white])
        let msgSz = msgStr.size()
        msgStr.draw(at: NSPoint(x: centerX - msgSz.width / 2, y: centerY - msgSz.height / 2 - 30))
    }
}

let app = NSApplication.shared
app.setActivationPolicy(.accessory)
var windows: [NSWindow] = []
for screen in NSScreen.screens {
    let r = NSRect(x: 0, y: 0, width: screen.frame.width, height: screen.frame.height)
    let win = NSWindow(contentRect: r, styleMask: .borderless, backing: .buffered, defer: false, screen: screen)
    win.setFrame(screen.frame, display: true)
    win.level = NSWindow.Level(rawValue: Int(CGShieldingWindowLevel()))
    win.backgroundColor = .clear
    win.isOpaque = false
    win.hasShadow = false
    win.ignoresMouseEvents = true
    win.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
    let v = PomodoroView(frame: r)
    win.contentView = v
    win.orderFrontRegardless()
    windows.append(win)
    v.start()
}
DispatchQueue.main.asyncAfter(deadline: .now() + PomodoroConfig.duration) { NSApp.terminate(nil) }
app.run()
