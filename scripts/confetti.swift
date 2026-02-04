#!/usr/bin/env swift

import Cocoa

// MARK: - Configuration (from environment variables)
struct Config {
    static let particleCount = Int(ProcessInfo.processInfo.environment["CONFETTI_PARTICLE_COUNT"] ?? "300") ?? 300
    static let duration = Double(ProcessInfo.processInfo.environment["CONFETTI_DURATION"] ?? "6") ?? 6
    static let gravity = CGFloat(Double(ProcessInfo.processInfo.environment["CONFETTI_GRAVITY"] ?? "0.5") ?? 0.5)
    static let velocity = CGFloat(Double(ProcessInfo.processInfo.environment["CONFETTI_VELOCITY"] ?? "20") ?? 20)
    static let sizeMin = CGFloat(Double(ProcessInfo.processInfo.environment["CONFETTI_SIZE_MIN"] ?? "8") ?? 8)
    static let sizeMax = CGFloat(Double(ProcessInfo.processInfo.environment["CONFETTI_SIZE_MAX"] ?? "16") ?? 16)
    static let spawnRate = Int(ProcessInfo.processInfo.environment["CONFETTI_SPAWN_RATE"] ?? "30") ?? 30

    static let assetsDir: String = {
        if let dir = ProcessInfo.processInfo.environment["CONFETTI_ASSETS_DIR"], !dir.isEmpty { return dir }
        return FileManager.default.currentDirectoryPath + "/assets"
    }()
}

// MARK: - Particle
class Particle {
    var x, y, vx, vy: CGFloat
    var rotation, rotationSpeed: CGFloat
    var size: CGFloat
    var color: NSColor
    var alpha: CGFloat = 1.0
    
    static let colors: [NSColor] = [
        .systemRed, .systemOrange, .systemYellow, .systemGreen,
        .systemBlue, .systemPurple, .systemPink, .cyan, .magenta, .white
    ]
    
    init(x: CGFloat, y: CGFloat) {
        self.x = x
        self.y = y
        self.vx = CGFloat.random(in: -12...12)
        self.vy = CGFloat.random(in: -Config.velocity...(-Config.velocity * 0.25))
        self.rotation = CGFloat.random(in: 0...360)
        self.rotationSpeed = CGFloat.random(in: -10...10)
        self.size = CGFloat.random(in: Config.sizeMin...Config.sizeMax)
        self.color = Particle.colors.randomElement()!
    }
    
    func update() {
        vy += Config.gravity
        x += vx
        y += vy
        rotation += rotationSpeed
        alpha -= 0.008
        vx *= 0.99
    }
    
    var isAlive: Bool { alpha > 0 }
}

// MARK: - Confetti View
class ConfettiView: NSView {
    var particles: [Particle] = []
    var spawnCount = 0
    var timer: Timer?
    var isDone = false
    
    override init(frame: NSRect) {
        super.init(frame: frame)
        spawnBurst()
        startTimer()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func spawnBurst() {
        guard spawnCount < Config.particleCount else { return }
        for _ in 0..<Config.spawnRate {
            let x = CGFloat.random(in: 0...bounds.width)
            let y = CGFloat.random(in: -50...50)
            particles.append(Particle(x: x, y: y))
        }
        spawnCount += Config.spawnRate
        if spawnCount < Config.particleCount {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
                self?.spawnBurst()
            }
        }
    }
    
    /// Use a per-view timer so each screen animates independently (CVDisplayLink callback is global, so only one screen would animate).
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
            self?.setNeedsDisplay(self?.bounds ?? .zero)
        }
        RunLoop.main.add(timer!, forMode: .common)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        NSColor.clear.setFill()
        dirtyRect.fill()
        
        particles.removeAll { !$0.isAlive || $0.y > bounds.height + 100 }
        
        for p in particles {
            p.update()
            
            let ctx = NSGraphicsContext.current!.cgContext
            ctx.saveGState()
            ctx.translateBy(x: p.x, y: bounds.height - p.y)
            ctx.rotate(by: p.rotation * .pi / 180)
            ctx.setFillColor(p.color.withAlphaComponent(p.alpha).cgColor)
            ctx.fill(CGRect(x: -p.size/2, y: -p.size/4, width: p.size, height: p.size/2))
            ctx.restoreGState()
        }
        
        if !isDone, particles.isEmpty, spawnCount >= Config.particleCount {
            isDone = true
            timer?.invalidate()
            timer = nil
            // App exit is handled by the duration timeout so all screens keep animating until then
        }
    }
}

// MARK: - Main
let app = NSApplication.shared
app.setActivationPolicy(.accessory)

// Keep references so windows stay alive
var windows: [NSWindow] = []

for screen in NSScreen.screens {
    // Use LOCAL coordinates (0,0,w,h) for contentRect so the window is created at the
    // bottom-left of THIS screen. Passing screen.frame (global coords) for a secondary
    // screen can be interpreted in screen-local space, placing the window off to the right.
    let localContentRect = NSRect(x: 0, y: 0, width: screen.frame.width, height: screen.frame.height)
    let window = NSWindow(
        contentRect: localContentRect,
        styleMask: .borderless,
        backing: .buffered,
        defer: false,
        screen: screen
    )
    // Force the window to the correct global frame for this screen (full screen on this display)
    window.setFrame(screen.frame, display: true)
    window.level = NSWindow.Level(rawValue: Int(CGShieldingWindowLevel()))
    window.backgroundColor = .clear
    window.isOpaque = false
    window.hasShadow = false
    window.ignoresMouseEvents = true
    window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
    let viewFrame = NSRect(x: 0, y: 0, width: screen.frame.width, height: screen.frame.height)
    window.contentView = ConfettiView(frame: viewFrame)
    window.orderFrontRegardless()
    windows.append(window)
}

// Success sound (play once at start; optional custom file in assets)
let successSound: NSSound? = {
    let wav = (Config.assetsDir as NSString).appendingPathComponent("success.wav")
    if FileManager.default.fileExists(atPath: wav), let s = NSSound(contentsOfFile: wav, byReference: false) {
        return s
    }
    return NSSound(named: "Hero")
}()
successSound?.play()

// Auto-close safety
DispatchQueue.main.asyncAfter(deadline: .now() + Config.duration) {
    successSound?.stop()
    NSApp.terminate(nil)
}

app.run()
