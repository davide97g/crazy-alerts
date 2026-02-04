#!/usr/bin/env swift

import Cocoa

// MARK: - Configuration
struct CheckmarkConfig {
    static let message: String = {
        let raw = ProcessInfo.processInfo.environment["CHECKMARK_MESSAGE"] ?? "Done"
        return raw.trimmingCharacters(in: .whitespaces)
    }()
    static let duration = Double(ProcessInfo.processInfo.environment["CHECKMARK_DURATION"] ?? "4") ?? 4
    static let fontSize = CGFloat(Double(ProcessInfo.processInfo.environment["CHECKMARK_FONT_SIZE"] ?? "32") ?? 32)

    static let assetsDir: String = {
        if let dir = ProcessInfo.processInfo.environment["CHECKMARK_ASSETS_DIR"], !dir.isEmpty { return dir }
        return FileManager.default.currentDirectoryPath + "/assets"
    }()
}

private func checkmarkFont(size: CGFloat) -> NSFont {
    (NSFont(name: "Avenir Next Medium", size: size)
        ?? NSFont(name: "Avenir-Medium", size: size)
        ?? NSFont.systemFont(ofSize: size))
}

// MARK: - Checkmark View (big green check + optional message)
class CheckmarkView: NSView {
    var timer: Timer?
    var phase: CGFloat = 0

    override init(frame: NSRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) { fatalError() }

    func startAnimation() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
            self?.phase += 0.08
            self?.setNeedsDisplay(self?.bounds ?? .zero)
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    override func draw(_ dirtyRect: NSRect) {
        NSColor.clear.setFill()
        dirtyRect.fill()

        let centerX = bounds.midX
        let centerY = bounds.midY
        let checkSize: CGFloat = 120
        let lineWidth: CGFloat = 14
        let inset = checkSize * 0.15

        let cardPadding: CGFloat = 48
        let msgHeight: CGFloat = !CheckmarkConfig.message.isEmpty ? CheckmarkConfig.fontSize + 16 : 0
        let cardWidth = max(280, checkSize + cardPadding * 2)
        let cardHeight = checkSize + msgHeight + cardPadding * 2
        let cardRect = NSRect(
            x: centerX - cardWidth / 2,
            y: centerY - cardHeight / 2,
            width: cardWidth,
            height: cardHeight
        )
        let cardPath = NSBezierPath(roundedRect: cardRect, xRadius: 20, yRadius: 20)
        NSColor.black.withAlphaComponent(0.72).setFill()
        cardPath.fill()

        let checkCenterY = centerY + (msgHeight > 0 ? 14 : 0)
        let path = NSBezierPath()
        path.lineWidth = lineWidth
        path.lineCapStyle = .round
        path.lineJoinStyle = .round

        let pulse = 0.85 + 0.15 * sin(phase)
        let green = NSColor.systemGreen.withAlphaComponent(pulse)
        green.setStroke()

        // Previous left tick: left (at center height) -> vertex (bend). New right tick: vertex -> top-right.
        let leftX = centerX - checkSize / 2
        let leftY = checkCenterY
        let cornerX = centerX - checkSize / 6
        let cornerY = checkCenterY - checkSize / 4
        let rightX = centerX + checkSize * 0.48
        let rightY = checkCenterY + checkSize * 0.28

        path.move(to: NSPoint(x: leftX, y: leftY))
        path.line(to: NSPoint(x: cornerX, y: cornerY))
        path.line(to: NSPoint(x: rightX, y: rightY))
        path.stroke()

        guard !CheckmarkConfig.message.isEmpty else { return }

        let font = checkmarkFont(size: CheckmarkConfig.fontSize)
        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: NSColor.white,
        ]
        let str = NSAttributedString(string: CheckmarkConfig.message, attributes: attrs)
        let strSize = str.size()
        let strX = (bounds.width - strSize.width) / 2
        let strY = checkCenterY - checkSize / 2 - strSize.height - 20
        str.draw(at: NSPoint(x: strX, y: strY))
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
    let view = CheckmarkView(frame: viewFrame)
    window.contentView = view
    window.orderFrontRegardless()
    windows.append(window)
    view.startAnimation()
}

let successSound: NSSound? = {
    let wav = (CheckmarkConfig.assetsDir as NSString).appendingPathComponent("success.wav")
    if FileManager.default.fileExists(atPath: wav), let s = NSSound(contentsOfFile: wav, byReference: false) {
        return s
    }
    return NSSound(named: "Hero")
}()
successSound?.play()

DispatchQueue.main.asyncAfter(deadline: .now() + CheckmarkConfig.duration) {
    NSApp.terminate(nil)
}

app.run()
