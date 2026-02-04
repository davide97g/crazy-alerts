#!/usr/bin/env swift

import Cocoa

struct KlaxonConfig {
    static let message: String = {
        let raw = ProcessInfo.processInfo.environment["KLAXON_MESSAGE"] ?? ""
        return raw.trimmingCharacters(in: .whitespaces)
    }()
    static let duration = Double(ProcessInfo.processInfo.environment["KLAXON_DURATION"] ?? "6") ?? 6
    static let fontSize = CGFloat(Double(ProcessInfo.processInfo.environment["KLAXON_FONT_SIZE"] ?? "44") ?? 44)
    static let assetsDir: String = {
        if let d = ProcessInfo.processInfo.environment["KLAXON_ASSETS_DIR"], !d.isEmpty { return d }
        return FileManager.default.currentDirectoryPath + "/assets"
    }()
}

class KlaxonView: NSView {
    var phase: CGFloat = 0
    var timer: Timer?
    var beepSound: NSSound?
    var lastBeepTime: TimeInterval = 0

    override init(frame: NSRect) { super.init(frame: frame) }
    required init?(coder: NSCoder) { fatalError() }

    func start() {
        let path = (KlaxonConfig.assetsDir as NSString).appendingPathComponent("alarm.wav")
        if FileManager.default.fileExists(atPath: path), let s = NSSound(contentsOfFile: path, byReference: false) {
            beepSound = s
        } else {
            beepSound = NSSound(named: "Funk")
        }
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { [weak self] t in
            guard let self = self else { return }
            self.phase += 0.2
            let now = t.fireDate.timeIntervalSince1970
            if now - self.lastBeepTime >= 0.5 {
                self.beepSound?.stop()
                self.beepSound?.play()
                self.lastBeepTime = now
            }
            self.setNeedsDisplay(self.bounds)
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    override func draw(_ dirtyRect: NSRect) {
        let flash = sin(phase) > 0 ? NSColor.systemRed : NSColor.black
        flash.withAlphaComponent(0.9).setFill()
        dirtyRect.fill()
        if !KlaxonConfig.message.isEmpty {
            let font = NSFont.boldSystemFont(ofSize: KlaxonConfig.fontSize)
            let attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: NSColor.white]
            let str = NSAttributedString(string: KlaxonConfig.message, attributes: attrs)
            let sz = str.size()
            str.draw(at: NSPoint(x: (bounds.width - sz.width) / 2, y: (bounds.height - sz.height) / 2))
        }
    }
}

let app = NSApplication.shared
app.setActivationPolicy(.accessory)
var windows: [NSWindow] = []
var views: [KlaxonView] = []
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
    let v = KlaxonView(frame: r)
    win.contentView = v
    win.orderFrontRegardless()
    windows.append(win)
    views.append(v)
    v.start()
}
DispatchQueue.main.asyncAfter(deadline: .now() + KlaxonConfig.duration) {
    views.forEach { $0.beepSound?.stop() }
    NSApp.terminate(nil)
}
app.run()
