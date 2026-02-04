#!/usr/bin/env swift

import Cocoa

struct StrobeConfig {
    static let message: String = {
        let raw = ProcessInfo.processInfo.environment["STROBE_MESSAGE"] ?? ""
        return raw.trimmingCharacters(in: .whitespaces)
    }()
    static let duration = Double(ProcessInfo.processInfo.environment["STROBE_DURATION"] ?? "5") ?? 5
    static let fontSize = CGFloat(Double(ProcessInfo.processInfo.environment["STROBE_FONT_SIZE"] ?? "40") ?? 40)
}

class StrobeView: NSView {
    var phase: CGFloat = 0
    var timer: Timer?

    override init(frame: NSRect) { super.init(frame: frame) }
    required init?(coder: NSCoder) { fatalError() }

    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 30.0, repeats: true) { [weak self] _ in
            self?.phase += 1
            self?.setNeedsDisplay(self?.bounds ?? .zero)
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    override func draw(_ dirtyRect: NSRect) {
        let cycle = Int(phase) % 4
        let color: NSColor = cycle == 0 || cycle == 1 ? NSColor.white : NSColor.systemRed
        color.withAlphaComponent(0.95).setFill()
        dirtyRect.fill()
        if !StrobeConfig.message.isEmpty {
            let attrs: [NSAttributedString.Key: Any] = [.font: NSFont.boldSystemFont(ofSize: StrobeConfig.fontSize), .foregroundColor: NSColor.black]
            let str = NSAttributedString(string: StrobeConfig.message, attributes: attrs)
            let sz = str.size()
            str.draw(at: NSPoint(x: (bounds.width - sz.width) / 2, y: (bounds.height - sz.height) / 2))
        }
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
    let v = StrobeView(frame: r)
    win.contentView = v
    win.orderFrontRegardless()
    windows.append(win)
    v.start()
}
DispatchQueue.main.asyncAfter(deadline: .now() + StrobeConfig.duration) { NSApp.terminate(nil) }
app.run()
