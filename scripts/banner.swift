#!/usr/bin/env swift

import Cocoa

struct BannerConfig {
    static let message: String = {
        let raw = ProcessInfo.processInfo.environment["BANNER_MESSAGE"] ?? "Build in progress..."
        return raw.trimmingCharacters(in: .whitespaces)
    }()
    static let duration = Double(ProcessInfo.processInfo.environment["BANNER_DURATION"] ?? "10") ?? 10
    static let speed: CGFloat = CGFloat(Double(ProcessInfo.processInfo.environment["BANNER_SPEED"] ?? "80") ?? 80)
    static let position: String = ProcessInfo.processInfo.environment["BANNER_POSITION"] ?? "bottom"
    static let fontSize = CGFloat(Double(ProcessInfo.processInfo.environment["BANNER_FONT_SIZE"] ?? "24") ?? 24)
}

class BannerView: NSView {
    var offset: CGFloat = 0
    var timer: Timer?
    var textWidth: CGFloat = 0

    override init(frame: NSRect) { super.init(frame: frame) }
    required init?(coder: NSCoder) { fatalError() }

    func start() {
        let font = NSFont.monospacedSystemFont(ofSize: BannerConfig.fontSize, weight: .medium)
        let attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: NSColor.white]
        let str = NSAttributedString(string: BannerConfig.message + "    ", attributes: attrs)
        textWidth = str.size().width
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
            self?.offset += BannerConfig.speed / 60.0
            if self?.offset ?? 0 >= self?.textWidth ?? 0 { self?.offset = 0 }
            self?.setNeedsDisplay(self?.bounds ?? .zero)
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    override func draw(_ dirtyRect: NSRect) {
        NSColor.clear.setFill()
        dirtyRect.fill()
        let font = NSFont.monospacedSystemFont(ofSize: BannerConfig.fontSize, weight: .medium)
        let attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: NSColor.white]
        let text = BannerConfig.message + "    " + BannerConfig.message + "    "
        let str = NSAttributedString(string: text, attributes: attrs)
        let y: CGFloat = BannerConfig.position == "top" ? bounds.height - 50 : 30
        let barHeight: CGFloat = 44
        let barRect = NSRect(x: 0, y: y - barHeight / 2, width: bounds.width, height: barHeight)
        NSColor.black.withAlphaComponent(0.75).setFill()
        NSBezierPath(rect: barRect).fill()
        let drawRect = NSRect(x: -offset, y: y - font.pointSize / 2 - 4, width: str.size().width + bounds.width, height: barHeight + 20)
        str.draw(in: drawRect)
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
    let v = BannerView(frame: r)
    win.contentView = v
    win.orderFrontRegardless()
    windows.append(win)
    v.start()
}
DispatchQueue.main.asyncAfter(deadline: .now() + BannerConfig.duration) { NSApp.terminate(nil) }
app.run()
