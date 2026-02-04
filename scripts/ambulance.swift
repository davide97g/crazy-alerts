#!/usr/bin/env swift

import Cocoa

// MARK: - Configuration (from environment variables)
struct AmbulanceConfig {
    static let message: String = {
        let raw = ProcessInfo.processInfo.environment["AMBULANCE_MESSAGE"] ?? "Test CNT-T5431 failed"
        return raw.replacingOccurrences(of: "🚨", with: "").trimmingCharacters(in: .whitespaces)
    }()
    static let duration = Double(ProcessInfo.processInfo.environment["AMBULANCE_DURATION"] ?? "14") ?? 14
    static let fontSize = CGFloat(Double(ProcessInfo.processInfo.environment["AMBULANCE_FONT_SIZE"] ?? "20") ?? 20)
    static let borderInset = CGFloat(Double(ProcessInfo.processInfo.environment["AMBULANCE_BORDER_INSET"] ?? "12") ?? 12)
}

/// Prefer a cooler font; fallback to system bold.
private func ambulanceFont(size: CGFloat) -> NSFont {
    (NSFont(name: "Avenir Next Medium", size: size)
        ?? NSFont(name: "Avenir-Medium", size: size)
        ?? NSFont(name: "Helvetica Neue", size: size))
        ?? NSFont.boldSystemFont(ofSize: size)
}

// MARK: - Ambulance View (emoji + red text + siren + screen border)
class AmbulanceView: NSView {
    var contentWidth: CGFloat = 0
    var currentX: CGFloat = 0
    var speed: CGFloat = 0
    var timer: Timer?
    var pulsePhase: CGFloat = 0
    let message: String
    var attributedLine: NSAttributedString?
    /// Same content as attributedLine but all black, for outline/stroke
    var outlineLine: NSAttributedString?

    init(frame: NSRect, message: String) {
        self.message = message
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) { fatalError() }

    func startAnimation() {
        let font = ambulanceFont(size: AmbulanceConfig.fontSize)
        let white = NSColor.white
        let red = NSColor.systemRed
        let black = NSColor.black

        let line = NSMutableAttributedString()
        line.append(NSAttributedString(string: "🚑 ", attributes: [.font: font, .foregroundColor: white]))
        line.append(NSAttributedString(string: message, attributes: [.font: font, .foregroundColor: red]))
        line.append(NSAttributedString(string: " 🚨", attributes: [.font: font, .foregroundColor: white]))
        attributedLine = line

        let outline = NSMutableAttributedString()
        outline.append(NSAttributedString(string: "🚑 ", attributes: [.font: font, .foregroundColor: black]))
        outline.append(NSAttributedString(string: message, attributes: [.font: font, .foregroundColor: black]))
        outline.append(NSAttributedString(string: " 🚨", attributes: [.font: font, .foregroundColor: black]))
        outlineLine = outline

        contentWidth = line.size().width

        let totalDistance = bounds.width + contentWidth * 2
        speed = totalDistance / CGFloat(AmbulanceConfig.duration * 60)
        currentX = bounds.width + contentWidth

        startTimer()
    }

    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    func tick() {
        currentX -= speed
        pulsePhase += 0.14
        setNeedsDisplay(bounds)
    }

    override func draw(_ dirtyRect: NSRect) {
        NSColor.clear.setFill()
        dirtyRect.fill()

        drawGlowingScreenBorder()

        guard let line = attributedLine, let outline = outlineLine, contentWidth > 0 else { return }

        let bottomMargin: CGFloat = 28
        let baselineY = bottomMargin
        let drawRect = NSRect(x: currentX, y: baselineY, width: contentWidth, height: line.size().height)

        let strokeOffset: CGFloat = 1
        let offsets: [(CGFloat, CGFloat)] = [
            (-strokeOffset, 0), (strokeOffset, 0), (0, -strokeOffset), (0, strokeOffset),
            (-strokeOffset, -strokeOffset), (-strokeOffset, strokeOffset), (strokeOffset, -strokeOffset), (strokeOffset, strokeOffset),
        ]
        for (dx, dy) in offsets {
            let strokeRect = NSRect(x: drawRect.minX + dx, y: drawRect.minY + dy, width: drawRect.width, height: drawRect.height)
            outline.draw(in: strokeRect)
        }

        let ctx = NSGraphicsContext.current?.cgContext
        ctx?.saveGState()
        let glow = NSShadow()
        glow.shadowColor = NSColor.systemRed.withAlphaComponent(0.9)
        glow.shadowOffset = NSSize(width: 0, height: 0)
        glow.shadowBlurRadius = 16
        glow.set()
        line.draw(in: drawRect)
        ctx?.restoreGState()
    }

    private func drawGlowingScreenBorder() {
        let inset = AmbulanceConfig.borderInset
        let borderRect = bounds.insetBy(dx: inset, dy: inset)
        let path = NSBezierPath(rect: borderRect)
        path.lineWidth = 1

        let pulse = 0.5 + 0.5 * sin(pulsePhase)
        let ctx = NSGraphicsContext.current?.cgContext

        ctx?.saveGState()
        let shadow = NSShadow()
        shadow.shadowColor = NSColor.systemRed.withAlphaComponent(0.7 * pulse)
        shadow.shadowOffset = NSSize(width: 0, height: 0)
        shadow.shadowBlurRadius = 12 + 6 * pulse
        shadow.set()
        NSColor.systemRed.withAlphaComponent(0.9 * pulse).setStroke()
        path.stroke()
        ctx?.restoreGState()

        let glowLayers: [(width: CGFloat, alpha: CGFloat)] = [
            (20, 0.12 * pulse),
            (14, 0.22 * pulse),
            (8, 0.4 * pulse),
            (3, 0.7 * pulse),
        ]
        for layer in glowLayers {
            path.lineWidth = layer.width
            NSColor.systemRed.withAlphaComponent(layer.alpha).setStroke()
            path.stroke()
        }
        path.lineWidth = 1.5
        NSColor.systemRed.withAlphaComponent(pulse).setStroke()
        path.stroke()
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
    let view = AmbulanceView(frame: viewFrame, message: AmbulanceConfig.message)
    window.contentView = view
    window.orderFrontRegardless()
    windows.append(window)

    view.startAnimation()
}

DispatchQueue.main.asyncAfter(deadline: .now() + AmbulanceConfig.duration) { NSApp.terminate(nil) }

app.run()
