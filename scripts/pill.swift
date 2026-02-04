#!/usr/bin/env swift

import Cocoa

struct PillConfig {
    static let message: String = {
        let raw = ProcessInfo.processInfo.environment["PILL_MESSAGE"] ?? "Deploy started"
        return raw.trimmingCharacters(in: .whitespaces)
    }()
    static let duration = Double(ProcessInfo.processInfo.environment["PILL_DURATION"] ?? "5") ?? 5
    static let fontSize = CGFloat(Double(ProcessInfo.processInfo.environment["PILL_FONT_SIZE"] ?? "20") ?? 20)
}

class PillView: NSView {
    override init(frame: NSRect) { super.init(frame: frame) }
    required init?(coder: NSCoder) { fatalError() }

    override func draw(_ dirtyRect: NSRect) {
        NSColor.clear.setFill()
        dirtyRect.fill()
        let font = NSFont.systemFont(ofSize: PillConfig.fontSize)
        let attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: NSColor.white]
        let str = NSAttributedString(string: PillConfig.message, attributes: attrs)
        let sz = str.size()
        let padding: CGFloat = 24
        let pillW = sz.width + padding * 2
        let pillH = sz.height + padding
        let pillRect = NSRect(x: bounds.midX - pillW / 2, y: bounds.midY - pillH / 2, width: pillW, height: pillH)
        let path = NSBezierPath(roundedRect: pillRect, xRadius: pillH / 2, yRadius: pillH / 2)
        NSColor.black.withAlphaComponent(0.8).setFill()
        path.fill()
        str.draw(at: NSPoint(x: bounds.midX - sz.width / 2, y: bounds.midY - sz.height / 2 - 2))
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
    win.contentView = PillView(frame: r)
    win.orderFrontRegardless()
    windows.append(win)
}
DispatchQueue.main.asyncAfter(deadline: .now() + PillConfig.duration) { NSApp.terminate(nil) }
app.run()
