#!/usr/bin/env swift

import Cocoa

struct RocketConfig {
    static let message: String = {
        let raw = ProcessInfo.processInfo.environment["ROCKET_MESSAGE"] ?? "Liftoff!"
        return raw.trimmingCharacters(in: .whitespaces)
    }()
    static let duration = Double(ProcessInfo.processInfo.environment["ROCKET_DURATION"] ?? "5") ?? 5
    static let fontSize = CGFloat(Double(ProcessInfo.processInfo.environment["ROCKET_FONT_SIZE"] ?? "36") ?? 36)
    static let assetsDir: String = {
        if let d = ProcessInfo.processInfo.environment["ROCKET_ASSETS_DIR"], !d.isEmpty { return d }
        return FileManager.default.currentDirectoryPath + "/assets"
    }()
}

class RocketView: NSView {
    var y: CGFloat = 0
    var timer: Timer?
    var soundPlayed = false

    override init(frame: NSRect) { super.init(frame: frame) }
    required init?(coder: NSCoder) { fatalError() }

    func start() {
        y = -80
        if !soundPlayed {
            soundPlayed = true
            let path = (RocketConfig.assetsDir as NSString).appendingPathComponent("success.wav")
            if FileManager.default.fileExists(atPath: path), let s = NSSound(contentsOfFile: path, byReference: false) { s.play() }
            else { NSSound(named: "Hero")?.play() }
        }
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.y += 4
            self.setNeedsDisplay(self.bounds)
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    override func draw(_ dirtyRect: NSRect) {
        NSColor.clear.setFill()
        dirtyRect.fill()
        let centerX = bounds.midX
        let rocketY = y
        let icon = "🚀"
        let font = NSFont.systemFont(ofSize: 64)
        let iconStr = NSAttributedString(string: icon, attributes: [.font: font, .foregroundColor: NSColor.white])
        let iconSz = iconStr.size()
        iconStr.draw(at: NSPoint(x: centerX - iconSz.width / 2, y: rocketY))
        let msgFont = NSFont.boldSystemFont(ofSize: RocketConfig.fontSize)
        let msgStr = NSAttributedString(string: RocketConfig.message, attributes: [.font: msgFont, .foregroundColor: NSColor.white])
        let msgSz = msgStr.size()
        msgStr.draw(at: NSPoint(x: centerX - msgSz.width / 2, y: rocketY - iconSz.height - 16))
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
    win.backgroundColor = NSColor.black.withAlphaComponent(0.5)
    win.isOpaque = false
    win.hasShadow = false
    win.ignoresMouseEvents = true
    win.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
    let v = RocketView(frame: r)
    win.contentView = v
    win.orderFrontRegardless()
    windows.append(win)
    v.start()
}
DispatchQueue.main.asyncAfter(deadline: .now() + RocketConfig.duration) { NSApp.terminate(nil) }
app.run()
