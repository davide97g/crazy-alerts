#!/usr/bin/env swift

import Cocoa

// MARK: - Configuration
struct FireConfig {
    static let message: String = {
        let raw = ProcessInfo.processInfo.environment["FIRE_MESSAGE"] ?? "Everything's on fire"
        return raw.trimmingCharacters(in: .whitespaces)
    }()
    static let duration = Double(ProcessInfo.processInfo.environment["FIRE_DURATION"] ?? "8") ?? 8
    static let particleCount = Int(ProcessInfo.processInfo.environment["FIRE_PARTICLE_COUNT"] ?? "80") ?? 80
    static let fontSize = CGFloat(Double(ProcessInfo.processInfo.environment["FIRE_FONT_SIZE"] ?? "36") ?? 36)

    static let assetsDir: String = {
        if let dir = ProcessInfo.processInfo.environment["FIRE_ASSETS_DIR"], !dir.isEmpty { return dir }
        return FileManager.default.currentDirectoryPath + "/assets"
    }()
}

private func fireFont(size: CGFloat) -> NSFont {
    (NSFont(name: "Avenir Next Heavy", size: size)
        ?? NSFont(name: "Avenir-Heavy", size: size)
        ?? NSFont.boldSystemFont(ofSize: size))
}

// MARK: - Flame particle
class FlameParticle {
    var x: CGFloat
    var y: CGFloat
    var vx: CGFloat
    var vy: CGFloat
    var size: CGFloat
    var alpha: CGFloat
    var hue: CGFloat
    var phase: CGFloat

    init(width: CGFloat, height: CGFloat) {
        self.x = CGFloat.random(in: 0...width)
        self.y = CGFloat.random(in: -20...height * 0.3)
        self.vx = CGFloat.random(in: -2...2)
        self.vy = CGFloat.random(in: 2...8)
        self.size = CGFloat.random(in: 8...40)
        self.alpha = CGFloat.random(in: 0.5...1.0)
        self.hue = CGFloat.random(in: 0.0...0.12)
        self.phase = CGFloat.random(in: 0...(.pi * 2))
    }

    func update() {
        x += vx
        y += vy
        vy *= 0.98
        vx *= 0.99
        alpha -= 0.008
        phase += 0.1
    }

    var isAlive: Bool { alpha > 0 && y < 10000 }
}

// MARK: - Fire View
class FireView: NSView {
    var particles: [FlameParticle] = []
    var timer: Timer?
    var phase: CGFloat = 0
    var spawnCounter = 0

    override init(frame: NSRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) { fatalError() }

    func startAnimation() {
        for _ in 0..<min(FireConfig.particleCount, 30) {
            particles.append(FlameParticle(width: bounds.width, height: bounds.height))
        }
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.phase += 0.06
            self.particles.removeAll { !$0.isAlive }
            while self.particles.count < FireConfig.particleCount, self.spawnCounter % 3 == 0 {
                self.particles.append(FlameParticle(width: self.bounds.width, height: self.bounds.height))
            }
            self.spawnCounter += 1
            for p in self.particles { p.update() }
            self.setNeedsDisplay(self.bounds)
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    override func draw(_ dirtyRect: NSRect) {
        let gradientPhase = sin(phase) * 0.02
        let colors = [
            NSColor(calibratedHue: 0.0 + gradientPhase, saturation: 0.9, brightness: 1.0, alpha: 0.95),
            NSColor(calibratedHue: 0.08 + gradientPhase, saturation: 0.85, brightness: 0.95, alpha: 0.9),
            NSColor(calibratedHue: 0.12, saturation: 0.8, brightness: 0.6, alpha: 0.85),
            NSColor.black.withAlphaComponent(0.3),
        ]
        let gradient = NSGradient(colors: colors)!
        gradient.draw(in: bounds, angle: 270)

        let ctx = NSGraphicsContext.current?.cgContext
        for p in particles {
            ctx?.saveGState()
            let rect = CGRect(x: p.x - p.size / 2, y: bounds.height - p.y - p.size / 2, width: p.size, height: p.size)
            let flicker = 0.8 + 0.2 * sin(p.phase)
            let c = NSColor(calibratedHue: p.hue, saturation: 0.9, brightness: flicker, alpha: p.alpha)
            c.setFill()
            NSBezierPath(ovalIn: rect).fill()
            ctx?.restoreGState()
        }

        guard !FireConfig.message.isEmpty else { return }

        let font = fireFont(size: FireConfig.fontSize)
        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: NSColor.white,
        ]
        let str = NSAttributedString(string: FireConfig.message, attributes: attrs)
        let size = str.size()
        let x = (bounds.width - size.width) / 2
        let y = (bounds.height - size.height) / 2
        str.draw(at: NSPoint(x: x, y: y))
    }
}

// MARK: - Main
let app = NSApplication.shared
app.setActivationPolicy(.accessory)

var windows: [NSWindow] = []

for screen in NSScreen.screens {
    let localContentRect = NSRect(x: 0, y: 0, width: screen.frame.width, height: screen.frame.height)
    let window = NSWindow(
        contentRect: localContentRect,
        styleMask: .borderless,
        backing: .buffered,
        defer: false,
        screen: screen
    )
    window.setFrame(screen.frame, display: true)
    window.level = NSWindow.Level(rawValue: Int(CGShieldingWindowLevel()))
    window.backgroundColor = .clear
    window.isOpaque = false
    window.hasShadow = false
    window.ignoresMouseEvents = true
    window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

    let viewFrame = NSRect(x: 0, y: 0, width: screen.frame.width, height: screen.frame.height)
    let view = FireView(frame: viewFrame)
    window.contentView = view
    window.orderFrontRegardless()
    windows.append(window)
    view.startAnimation()
}

DispatchQueue.main.asyncAfter(deadline: .now() + FireConfig.duration) {
    NSApp.terminate(nil)
}

app.run()
