#!/usr/bin/env swift

import Cocoa

struct ExplosionConfig {
    static let message: String = {
        let raw = ProcessInfo.processInfo.environment["EXPLOSION_MESSAGE"] ?? ""
        return raw.trimmingCharacters(in: .whitespaces)
    }()
    static let duration = Double(ProcessInfo.processInfo.environment["EXPLOSION_DURATION"] ?? "4") ?? 4
    static let particleCount = Int(ProcessInfo.processInfo.environment["EXPLOSION_PARTICLE_COUNT"] ?? "60") ?? 60
    static let fontSize = CGFloat(Double(ProcessInfo.processInfo.environment["EXPLOSION_FONT_SIZE"] ?? "28") ?? 28)
}

class ExplosionParticle {
    var x: CGFloat
    var y: CGFloat
    var vx: CGFloat
    var vy: CGFloat
    var size: CGFloat
    var alpha: CGFloat
    var color: NSColor
    init(x: CGFloat, y: CGFloat) {
        self.x = x
        self.y = y
        let angle = CGFloat.random(in: 0...(2 * .pi))
        let speed = CGFloat.random(in: 8...25)
        self.vx = cos(angle) * speed
        self.vy = sin(angle) * speed
        self.size = CGFloat.random(in: 4...16)
        self.alpha = 1.0
        self.color = [NSColor.systemOrange, .systemYellow, .systemRed, .white].randomElement()!
    }
    func update() {
        x += vx
        y += vy
        vx *= 0.96
        vy *= 0.96
        alpha -= 0.02
    }
    var isAlive: Bool { alpha > 0 }
}

class ExplosionView: NSView {
    var particles: [ExplosionParticle] = []
    var timer: Timer?
    var soundPlayed = false

    override init(frame: NSRect) {
        super.init(frame: frame)
        let cx = frame.midX
        let cy = frame.midY
        for _ in 0..<ExplosionConfig.particleCount {
            particles.append(ExplosionParticle(x: cx, y: cy))
        }
    }
    required init?(coder: NSCoder) { fatalError() }

    func start() {
        if !soundPlayed {
            soundPlayed = true
            NSSound(named: "Hero")?.play()
        }
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
            self?.particles.removeAll { !$0.isAlive }
            for p in self?.particles ?? [] { p.update() }
            self?.setNeedsDisplay(self?.bounds ?? .zero)
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    override func draw(_ dirtyRect: NSRect) {
        NSColor.clear.setFill()
        dirtyRect.fill()
        let ctx = NSGraphicsContext.current?.cgContext
        for p in particles {
            ctx?.setFillColor(p.color.withAlphaComponent(p.alpha).cgColor)
            ctx?.fill(CGRect(x: p.x - p.size/2, y: bounds.height - p.y - p.size/2, width: p.size, height: p.size))
        }
        if !ExplosionConfig.message.isEmpty {
            let attrs: [NSAttributedString.Key: Any] = [.font: NSFont.boldSystemFont(ofSize: ExplosionConfig.fontSize), .foregroundColor: NSColor.white]
            let str = NSAttributedString(string: ExplosionConfig.message, attributes: attrs)
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
    win.backgroundColor = NSColor.black.withAlphaComponent(0.3)
    win.isOpaque = false
    win.hasShadow = false
    win.ignoresMouseEvents = true
    win.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
    let v = ExplosionView(frame: r)
    win.contentView = v
    win.orderFrontRegardless()
    windows.append(win)
    v.start()
}
DispatchQueue.main.asyncAfter(deadline: .now() + ExplosionConfig.duration) { NSApp.terminate(nil) }
app.run()
