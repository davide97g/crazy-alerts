#!/usr/bin/env swift

import Cocoa

struct ReminderConfig {
    static let message: String = {
        let raw = ProcessInfo.processInfo.environment["REMINDER_MESSAGE"] ?? "Stand up"
        return raw.trimmingCharacters(in: .whitespaces)
    }()
    static let duration = Double(ProcessInfo.processInfo.environment["REMINDER_DURATION"] ?? "6") ?? 6
    static let fontSize = CGFloat(Double(ProcessInfo.processInfo.environment["REMINDER_FONT_SIZE"] ?? "56") ?? 56)
    static let assetsDir: String = {
        if let d = ProcessInfo.processInfo.environment["REMINDER_ASSETS_DIR"], !d.isEmpty { return d }
        return FileManager.default.currentDirectoryPath + "/assets"
    }()
}

class ReminderView: NSView {
    override init(frame: NSRect) { super.init(frame: frame) }
    required init?(coder: NSCoder) { fatalError() }

    override func draw(_ dirtyRect: NSRect) {
        NSColor.black.withAlphaComponent(0.55).setFill()
        dirtyRect.fill()
        let font = NSFont.boldSystemFont(ofSize: ReminderConfig.fontSize)
        let attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: NSColor.white]
        let str = NSAttributedString(string: ReminderConfig.message, attributes: attrs)
        let sz = str.size()
        str.draw(at: NSPoint(x: (bounds.width - sz.width) / 2, y: (bounds.height - sz.height) / 2))
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
    let v = ReminderView(frame: r)
    win.contentView = v
    win.orderFrontRegardless()
    windows.append(win)
}
let sound: NSSound? = {
    let path = (ReminderConfig.assetsDir as NSString).appendingPathComponent("success.wav")
    if FileManager.default.fileExists(atPath: path), let s = NSSound(contentsOfFile: path, byReference: false) { return s }
    return NSSound(named: "Ping")
}()
sound?.play()
DispatchQueue.main.asyncAfter(deadline: .now() + ReminderConfig.duration) { NSApp.terminate(nil) }
app.run()
