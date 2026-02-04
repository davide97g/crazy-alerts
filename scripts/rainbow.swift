#!/usr/bin/env swift

import Cocoa

struct RainbowConfig {
    static let message: String = {
        let raw = ProcessInfo.processInfo.environment["RAINBOW_MESSAGE"] ?? "All green"
        return raw.trimmingCharacters(in: .whitespaces)
    }()
    static let duration = Double(ProcessInfo.processInfo.environment["RAINBOW_DURATION"] ?? "6") ?? 6
    static let fontSize = CGFloat(Double(ProcessInfo.processInfo.environment["RAINBOW_FONT_SIZE"] ?? "42") ?? 42)
}

class RainbowView: NSView {
    var phase: CGFloat = 0
    var timer: Timer?

    override init(frame: NSRect) { super.init(frame: frame) }
    required init?(coder: NSCoder) { fatalError() }

    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
            self?.phase += 0.015
            self?.setNeedsDisplay(self?.bounds ?? .zero)
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    override func draw(_ dirtyRect: NSRect) {
        let hue = (phase.truncatingRemainder(dividingBy: 1.0) + 1.0).truncatingRemainder(dividingBy: 1.0)
        let colors = (0..<7).map { i in
            NSColor(calibratedHue: hue + CGFloat(i) / 7.0, saturation: 0.85, brightness: 0.95, alpha: 0.9)
        }
        guard let grad = NSGradient(colors: colors) else { return }
        grad.draw(in: bounds, angle: 90 + sin(phase * 2) * 5)
        if !RainbowConfig.message.isEmpty {
            let attrs: [NSAttributedString.Key: Any] = [.font: NSFont.boldSystemFont(ofSize: RainbowConfig.fontSize), .foregroundColor: NSColor.white]
            let str = NSAttributedString(string: RainbowConfig.message, attributes: attrs)
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
    let v = RainbowView(frame: r)
    win.contentView = v
    win.orderFrontRegardless()
    windows.append(win)
    v.start()
}
DispatchQueue.main.asyncAfter(deadline: .now() + RainbowConfig.duration) { NSApp.terminate(nil) }
app.run()
