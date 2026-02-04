#!/usr/bin/env swift

import Cocoa
import ImageIO

// MARK: - Configuration (from environment variables)
struct AmbulanceConfig {
    static let message: String = {
        let raw = ProcessInfo.processInfo.environment["AMBULANCE_MESSAGE"] ?? "Test CNT-T5431 failed"
        return raw.replacingOccurrences(of: "🚨", with: "").trimmingCharacters(in: .whitespaces)
    }()
    static let duration = Double(ProcessInfo.processInfo.environment["AMBULANCE_DURATION"] ?? "14") ?? 14
    static let fontSize = CGFloat(Double(ProcessInfo.processInfo.environment["AMBULANCE_FONT_SIZE"] ?? "20") ?? 20)
    static let borderInset = CGFloat(Double(ProcessInfo.processInfo.environment["AMBULANCE_BORDER_INSET"] ?? "12") ?? 12)

    /// Assets directory: env AMBULANCE_ASSETS_DIR, or ./assets relative to current directory
    static let assetsDir: String = {
        if let dir = ProcessInfo.processInfo.environment["AMBULANCE_ASSETS_DIR"], !dir.isEmpty { return dir }
        return FileManager.default.currentDirectoryPath + "/assets"
    }()
}

// MARK: - Animated GIF (frame-by-frame via ImageIO)
final class AnimatedGIF {
    private var frames: [NSImage] = []
    private var frameDelays: [TimeInterval] = []
    private var currentFrameIndex: Int = 0
    private var accumulatedTime: TimeInterval = 0
    var displaySize: NSSize = NSSize(width: 28, height: 28)

    static func load(path: String) -> AnimatedGIF? {
        let url = URL(fileURLWithPath: path)
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else { return nil }
        let count = CGImageSourceGetCount(source)
        guard count > 0 else { return nil }
        let gif = AnimatedGIF()
        for i in 0..<count {
            guard let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) else { continue }
            gif.frames.append(NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height)))
            let delay = Self.frameDelay(at: i, source: source)
            gif.frameDelays.append(delay)
        }
        if gif.frames.isEmpty { return nil }
        return gif
    }

    private static func frameDelay(at index: Int, source: CGImageSource) -> TimeInterval {
        guard let props = CGImageSourceCopyPropertiesAtIndex(source, index, nil) as? [String: Any],
              let gifProps = props[kCGImagePropertyGIFDictionary as String] as? [String: Any] else {
            return 0.1
        }
        if let unclamped = gifProps[kCGImagePropertyGIFUnclampedDelayTime as String] as? Double, unclamped > 0 {
            return unclamped
        }
        if let delay = gifProps[kCGImagePropertyGIFDelayTime as String] as? Double {
            return delay > 0 ? delay : 0.1
        }
        return 0.1
    }

    func advance(delta: TimeInterval) {
        guard frames.count > 1, frameDelays.count == frames.count else { return }
        accumulatedTime += delta
        let delay = frameDelays[currentFrameIndex]
        if accumulatedTime >= delay {
            accumulatedTime -= delay
            currentFrameIndex = (currentFrameIndex + 1) % frames.count
        }
    }

    var currentImage: NSImage? {
        guard currentFrameIndex < frames.count else { return frames.first }
        return frames[currentFrameIndex]
    }
}

/// Prefer a cooler font; fallback to system bold.
private func ambulanceFont(size: CGFloat) -> NSFont {
    (NSFont(name: "Avenir Next Medium", size: size)
        ?? NSFont(name: "Avenir-Medium", size: size)
        ?? NSFont(name: "Helvetica Neue", size: size))
        ?? NSFont.boldSystemFont(ofSize: size)
}

// MARK: - Ambulance View (emoji + red text + siren image + screen border + alarm sound)
class AmbulanceView: NSView {
    var contentWidth: CGFloat = 0
    var textWidth: CGFloat = 0
    var currentX: CGFloat = 0
    var speed: CGFloat = 0
    var timer: Timer?
    var pulsePhase: CGFloat = 0
    let message: String
    var attributedLine: NSAttributedString?
    var outlineLine: NSAttributedString?
    var sirenGIF: AnimatedGIF?
    let sirenGap: CGFloat = 6
    let sirenDisplaySize = NSSize(width: 28, height: 28)
    var alarmSound: NSSound?

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
        attributedLine = line

        let outline = NSMutableAttributedString()
        outline.append(NSAttributedString(string: "🚑 ", attributes: [.font: font, .foregroundColor: black]))
        outline.append(NSAttributedString(string: message, attributes: [.font: font, .foregroundColor: black]))
        outlineLine = outline

        textWidth = line.size().width
        let sirenWidth = sirenGap + sirenDisplaySize.width
        contentWidth = textWidth + sirenWidth

        let sirenPath = (AmbulanceConfig.assetsDir as NSString).appendingPathComponent("alert.gif")
        sirenGIF = AnimatedGIF.load(path: sirenPath)
        sirenGIF?.displaySize = sirenDisplaySize

        let totalDistance = bounds.width + contentWidth * 2
        speed = totalDistance / CGFloat(AmbulanceConfig.duration * 60)
        currentX = bounds.width + contentWidth

        startAlarmSound()
        startTimer()
    }

    static var sharedAlarmSound: NSSound?

    private func startAlarmSound() {
        let soundPath = (AmbulanceConfig.assetsDir as NSString).appendingPathComponent("alarm.wav")
        if FileManager.default.fileExists(atPath: soundPath), let sound = NSSound(contentsOfFile: soundPath, byReference: false) {
            alarmSound = sound
        } else {
            alarmSound = NSSound(named: "Glass")
        }
        alarmSound?.loops = true
        alarmSound?.play()
        AmbulanceView.sharedAlarmSound = alarmSound
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
        sirenGIF?.advance(delta: 1.0 / 60.0)
        setNeedsDisplay(bounds)
    }

    override func draw(_ dirtyRect: NSRect) {
        NSColor.clear.setFill()
        dirtyRect.fill()

        drawGlowingScreenBorder()

        guard let line = attributedLine, let outline = outlineLine, contentWidth > 0 else { return }

        let bottomMargin: CGFloat = 28
        let baselineY = bottomMargin
        let lineHeight = line.size().height
        let textDrawRect = NSRect(x: currentX, y: baselineY, width: textWidth, height: lineHeight)

        let strokeOffset: CGFloat = 1
        let offsets: [(CGFloat, CGFloat)] = [
            (-strokeOffset, 0), (strokeOffset, 0), (0, -strokeOffset), (0, strokeOffset),
            (-strokeOffset, -strokeOffset), (-strokeOffset, strokeOffset), (strokeOffset, -strokeOffset), (strokeOffset, strokeOffset),
        ]
        for (dx, dy) in offsets {
            let strokeRect = NSRect(x: textDrawRect.minX + dx, y: textDrawRect.minY + dy, width: textDrawRect.width, height: textDrawRect.height)
            outline.draw(in: strokeRect)
        }

        let ctx = NSGraphicsContext.current?.cgContext
        ctx?.saveGState()
        let glow = NSShadow()
        glow.shadowColor = NSColor.systemRed.withAlphaComponent(0.9)
        glow.shadowOffset = NSSize(width: 0, height: 0)
        glow.shadowBlurRadius = 16
        glow.set()
        line.draw(in: textDrawRect)
        ctx?.restoreGState()

        let sirenY = baselineY + (lineHeight - sirenDisplaySize.height) / 2
        let scrollingSirenRect = NSRect(x: currentX + textWidth + sirenGap, y: sirenY, width: sirenDisplaySize.width, height: sirenDisplaySize.height)
        drawSiren(in: scrollingSirenRect)

        let topRightInset: CGFloat = 24
        let cornerSirenRect = NSRect(x: bounds.maxX - sirenDisplaySize.width - topRightInset, y: bounds.maxY - sirenDisplaySize.height - topRightInset, width: sirenDisplaySize.width, height: sirenDisplaySize.height)
        drawSiren(in: cornerSirenRect)
    }

    private func drawSiren(in rect: NSRect) {
        guard let gif = sirenGIF, let image = gif.currentImage else { return }
        image.draw(in: rect, from: NSRect(origin: .zero, size: image.size), operation: .sourceOver, fraction: 1)
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

DispatchQueue.main.asyncAfter(deadline: .now() + AmbulanceConfig.duration) {
    AmbulanceView.sharedAlarmSound?.stop()
    NSApp.terminate(nil)
}

app.run()
