#!/usr/bin/env swift

import Cocoa

struct ClapConfig {
    static let message: String = {
        let raw = ProcessInfo.processInfo.environment["CLAP_MESSAGE"] ?? "Well done!"
        return raw.trimmingCharacters(in: .whitespaces)
    }()
    static let duration = Double(ProcessInfo.processInfo.environment["CLAP_DURATION"] ?? "4") ?? 4
    static let fontSize = CGFloat(Double(ProcessInfo.processInfo.environment["CLAP_FONT_SIZE"] ?? "40") ?? 40)
    static let assetsDir: String = {
        if let d = ProcessInfo.processInfo.environment["CLAP_ASSETS_DIR"], !d.isEmpty { return d }
        return FileManager.default.currentDirectoryPath + "/assets"
    }()
}

class ClapView: NSView {
    var phase: CGFloat = 0
    var timer: Timer?

    override init(frame: NSRect) { super.init(frame: frame) }
    required init?(coder: NSCoder) { fatalError() }

    func start() {
        let path = (ClapConfig.assetsDir as NSString).appendingPathComponent("success.wav")
        if FileManager.default.fileExists(atPath: path), let s = NSSound(contentsOfFile: path, byReference: false) { s.play() }
        else { NSSound(named: "Hero")?.play() }
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
            self?.phase += 0.1
            self?.setNeedsDisplay(self?.bounds ?? .zero)
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    override func draw(_ dirtyRect: NSRect) {
        NSColor.clear.setFill()
        dirtyRect.fill()
        let centerX = bounds.midX
        let centerY = bounds.midY
        let sway = sin(phase) * 4
        let icon = "👏"
        let font = NSFont.systemFont(ofSize: 72)
        let iconStr = NSAttributedString(string: icon, attributes: [.font: font, .foregroundColor: NSColor.white])
        let iconSz = iconStr.size()
        iconStr.draw(at: NSPoint(x: centerX - iconSz.width / 2 + sway, y: centerY - iconSz.height / 2 + 30))
        let msgStr = NSAttributedString(string: ClapConfig.message, attributes: [.font: NSFont.boldSystemFont(ofSize: ClapConfig.fontSize), .foregroundColor: NSColor.white])
        let msgSz = msgStr.size()
        msgStr.draw(at: NSPoint(x: centerX - msgSz.width / 2, y: centerY - msgSz.height / 2 - 50))
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
    win.backgroundColor = NSColor.black.withAlphaComponent(0.4)
    win.isOpaque = false
    win.hasShadow = false
    win.ignoresMouseEvents = true
    win.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
    let v = ClapView(frame: r)
    win.contentView = v
    win.orderFrontRegardless()
    windows.append(win)
    v.start()
}
DispatchQueue.main.asyncAfter(deadline: .now() + ClapConfig.duration) { NSApp.terminate(nil) }
app.run()
