#!/usr/bin/env swift

import Cocoa

struct DangerConfig {
    static let message: String = {
        let raw = ProcessInfo.processInfo.environment["DANGER_MESSAGE"] ?? "Danger"
        return raw.trimmingCharacters(in: .whitespaces)
    }()
    static let duration = Double(ProcessInfo.processInfo.environment["DANGER_DURATION"] ?? "8") ?? 8
    static let fontSize = CGFloat(Double(ProcessInfo.processInfo.environment["DANGER_FONT_SIZE"] ?? "52") ?? 52)
    static let icon: String = ProcessInfo.processInfo.environment["DANGER_ICON"] ?? "⚠️"
    static let assetsDir: String = {
        if let d = ProcessInfo.processInfo.environment["DANGER_ASSETS_DIR"], !d.isEmpty { return d }
        return FileManager.default.currentDirectoryPath + "/assets"
    }()
}

class DangerView: NSView {
    var phase: CGFloat = 0
    var timer: Timer?
    var alarmSound: NSSound?

    override init(frame: NSRect) { super.init(frame: frame) }
    required init?(coder: NSCoder) { fatalError() }

    func start() {
        let path = (DangerConfig.assetsDir as NSString).appendingPathComponent("alarm.wav")
        if FileManager.default.fileExists(atPath: path), let s = NSSound(contentsOfFile: path, byReference: false) {
            alarmSound = s
        } else {
            alarmSound = NSSound(named: "Glass")
        }
        alarmSound?.loops = true
        alarmSound?.play()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
            self?.phase += 0.08
            self?.setNeedsDisplay(self?.bounds ?? .zero)
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    override func draw(_ dirtyRect: NSRect) {
        NSColor.black.withAlphaComponent(0.85).setFill()
        dirtyRect.fill()
        let pulse = 0.8 + 0.2 * sin(phase)
        let font = NSFont.boldSystemFont(ofSize: DangerConfig.fontSize)
        let iconSize: CGFloat = 80
        let iconStr = NSAttributedString(string: DangerConfig.icon, attributes: [.font: NSFont.systemFont(ofSize: iconSize), .foregroundColor: NSColor.systemYellow.withAlphaComponent(pulse)])
        let iconSz = iconStr.size()
        iconStr.draw(at: NSPoint(x: (bounds.width - iconSz.width) / 2, y: bounds.midY - iconSz.height / 2 + 50))
        let msgStr = NSAttributedString(string: DangerConfig.message, attributes: [.font: font, .foregroundColor: NSColor.white])
        let msgSz = msgStr.size()
        msgStr.draw(at: NSPoint(x: (bounds.width - msgSz.width) / 2, y: bounds.midY - msgSz.height / 2 - 30))
    }
}

let app = NSApplication.shared
app.setActivationPolicy(.accessory)
var windows: [NSWindow] = []
var views: [DangerView] = []
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
    let v = DangerView(frame: r)
    win.contentView = v
    win.orderFrontRegardless()
    windows.append(win)
    views.append(v)
    v.start()
}
DispatchQueue.main.asyncAfter(deadline: .now() + DangerConfig.duration) {
    views.forEach { $0.alarmSound?.stop() }
    NSApp.terminate(nil)
}
app.run()
