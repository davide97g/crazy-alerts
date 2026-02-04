#!/usr/bin/env swift

import Cocoa

struct DNDConfig {
    static let message: String = {
        let raw = ProcessInfo.processInfo.environment["DND_MESSAGE"] ?? "Do not disturb"
        return raw.trimmingCharacters(in: .whitespaces)
    }()
    static let duration = Double(ProcessInfo.processInfo.environment["DND_DURATION"] ?? "0") ?? 0
    static let fontSize = CGFloat(Double(ProcessInfo.processInfo.environment["DND_FONT_SIZE"] ?? "48") ?? 48)
}

class DNDView: NSView {
    override init(frame: NSRect) { super.init(frame: frame) }
    required init?(coder: NSCoder) { fatalError() }

    override func draw(_ dirtyRect: NSRect) {
        NSColor.black.withAlphaComponent(0.6).setFill()
        dirtyRect.fill()
        let font = NSFont.boldSystemFont(ofSize: DNDConfig.fontSize)
        let attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: NSColor.white]
        let str = NSAttributedString(string: DNDConfig.message, attributes: attrs)
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
    win.contentView = DNDView(frame: r)
    win.orderFrontRegardless()
    windows.append(win)
}
let duration = DNDConfig.duration > 0 ? DNDConfig.duration : 999999
DispatchQueue.main.asyncAfter(deadline: .now() + duration) { NSApp.terminate(nil) }
app.run()
