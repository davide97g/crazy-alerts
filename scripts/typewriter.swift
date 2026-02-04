#!/usr/bin/env swift

import Cocoa

struct TypewriterConfig {
    static let message: String = {
        let raw = ProcessInfo.processInfo.environment["TYPEWRITER_MESSAGE"] ?? "Done."
        return raw.trimmingCharacters(in: .whitespaces)
    }()
    static let duration: Double = {
        let raw = ProcessInfo.processInfo.environment["TYPEWRITER_DURATION"] ?? "2"
        return Double(raw) ?? 2
    }()
    static let charDelay: Double = {
        let raw = ProcessInfo.processInfo.environment["TYPEWRITER_CHAR_DELAY"] ?? "0.06"
        return Double(raw) ?? 0.06
    }()
    static let fontSize = CGFloat(Double(ProcessInfo.processInfo.environment["TYPEWRITER_FONT_SIZE"] ?? "28") ?? 28)
    static let assetsDir: String = {
        if let d = ProcessInfo.processInfo.environment["TYPEWRITER_ASSETS_DIR"], !d.isEmpty { return d }
        return FileManager.default.currentDirectoryPath + "/assets"
    }()
}

class TypewriterView: NSView {
    var visibleCount = 0
    var timer: Timer?
    var showCursor = true
    var cursorTimer: Timer?
    var beepPlayed = false

    override init(frame: NSRect) { super.init(frame: frame) }
    required init?(coder: NSCoder) { fatalError() }

    func start() {
        let chars = Array(TypewriterConfig.message)
        guard !chars.isEmpty else {
            DispatchQueue.main.asyncAfter(deadline: .now() + TypewriterConfig.duration) { NSApp.terminate(nil) }
            return
        }
        var delay: TimeInterval = 0
        for i in 0..<chars.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                self?.visibleCount = i + 1
                self?.setNeedsDisplay(self?.bounds ?? .zero)
            }
            delay += TypewriterConfig.charDelay
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            if self?.beepPlayed == false {
                self?.beepPlayed = true
                let path = (TypewriterConfig.assetsDir as NSString).appendingPathComponent("success.wav")
                if FileManager.default.fileExists(atPath: path), let s = NSSound(contentsOfFile: path, byReference: false) { s.play() }
                else { NSSound(named: "Tink")?.play() }
            }
        }
        cursorTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.showCursor.toggle()
            self?.setNeedsDisplay(self?.bounds ?? .zero)
        }
        RunLoop.main.add(cursorTimer!, forMode: .common)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay + TypewriterConfig.duration) {
            NSApp.terminate(nil)
        }
    }

    override func draw(_ dirtyRect: NSRect) {
        NSColor.black.withAlphaComponent(0.7).setFill()
        dirtyRect.fill()
        let font = NSFont.monospacedSystemFont(ofSize: TypewriterConfig.fontSize, weight: .regular)
        let attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: NSColor.green]
        let visible = String(TypewriterConfig.message.prefix(visibleCount))
        let str = NSAttributedString(string: visible, attributes: attrs)
        let sz = str.size()
        let x: CGFloat = 60
        let y = bounds.midY - sz.height / 2
        str.draw(at: NSPoint(x: x, y: y))
        if showCursor {
            let cursorX = x + sz.width + 2
            NSColor.green.setFill()
            NSRect(x: cursorX, y: y, width: font.pointSize * 0.6, height: sz.height).fill()
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
    let v = TypewriterView(frame: r)
    win.contentView = v
    win.orderFrontRegardless()
    windows.append(win)
    v.start()
}
app.run()
