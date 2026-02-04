#!/usr/bin/env swift

import Cocoa

struct MatrixConfig {
    static let message: String = {
        let raw = ProcessInfo.processInfo.environment["MATRIX_MESSAGE"] ?? ""
        return raw.trimmingCharacters(in: .whitespaces)
    }()
    static let duration = Double(ProcessInfo.processInfo.environment["MATRIX_DURATION"] ?? "8") ?? 8
    static let fontSize = CGFloat(Double(ProcessInfo.processInfo.environment["MATRIX_FONT_SIZE"] ?? "14") ?? 14)
    static let columnCount = Int(ProcessInfo.processInfo.environment["MATRIX_COLUMNS"] ?? "40") ?? 40
}

struct MatrixColumn {
    var y: CGFloat
    var speed: CGFloat
    var chars: [Character]
    let charset = Array("0123456789ABCDEFアイウエオカキクケコ")
}

class MatrixView: NSView {
    var columns: [MatrixColumn] = []
    var timer: Timer?
    let font = NSFont.monospacedSystemFont(ofSize: MatrixConfig.fontSize, weight: .regular)

    override init(frame: NSRect) {
        super.init(frame: frame)
        let h = frame.height > 0 ? frame.height : 800
        for _ in 0..<MatrixConfig.columnCount {
            var col = MatrixColumn(y: CGFloat.random(in: 0...(h + 200)), speed: CGFloat.random(in: 2...6), chars: [])
            for _ in 0..<Int.random(in: 8...20) {
                col.chars.append(col.charset.randomElement()!)
            }
            columns.append(col)
        }
    }
    required init?(coder: NSCoder) { fatalError() }

    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            for i in 0..<self.columns.count {
                self.columns[i].y += self.columns[i].speed
                if self.columns[i].y > self.bounds.height + 300 {
                    self.columns[i].y = -200
                    self.columns[i].chars = (0..<Int.random(in: 8...20)).map { _ in self.columns[i].charset.randomElement()! }
                }
            }
            self.setNeedsDisplay(self.bounds)
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    override func draw(_ dirtyRect: NSRect) {
        NSColor.black.setFill()
        dirtyRect.fill()
        let step = bounds.width / CGFloat(MatrixConfig.columnCount + 1)
        for (i, col) in columns.enumerated() {
            let x = step * CGFloat(i + 1)
            for (j, c) in col.chars.enumerated() {
                let alpha = 1.0 - CGFloat(j) / CGFloat(col.chars.count) * 0.8
                let attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: NSColor.green.withAlphaComponent(alpha)]
                let str = NSAttributedString(string: String(c), attributes: attrs)
                str.draw(at: NSPoint(x: x, y: bounds.height - (col.y + CGFloat(j) * font.pointSize)))
            }
        }
        if !MatrixConfig.message.isEmpty {
            let msgFont = NSFont.boldSystemFont(ofSize: 32)
            let attrs: [NSAttributedString.Key: Any] = [.font: msgFont, .foregroundColor: NSColor.green]
            let str = NSAttributedString(string: MatrixConfig.message, attributes: attrs)
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
    win.backgroundColor = .clear
    win.isOpaque = false
    win.hasShadow = false
    win.ignoresMouseEvents = true
    win.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
    let v = MatrixView(frame: r)
    win.contentView = v
    win.orderFrontRegardless()
    windows.append(win)
    v.start()
}
DispatchQueue.main.asyncAfter(deadline: .now() + MatrixConfig.duration) { NSApp.terminate(nil) }
app.run()
