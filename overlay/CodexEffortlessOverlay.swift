import AppKit
import CoreGraphics

final class BarView: NSView {
    var effort = "Auto"
    var model = "Current"
    var context = "20%"

    override func draw(_ dirtyRect: NSRect) {
        let bounds = NSInsetRect(self.bounds, 1, 1)
        let path = NSBezierPath(roundedRect: bounds, xRadius: 18, yRadius: 18)
        NSColor(calibratedWhite: 0.075, alpha: 0.98).setFill(); path.fill()
        NSColor(calibratedWhite: 0.20, alpha: 1).setStroke(); path.lineWidth = 1; path.stroke()

        let dot = NSColor(calibratedWhite: 0.20, alpha: 0.22)
        for x in stride(from: 28.0, through: bounds.width - 28, by: 24) {
            for y in stride(from: 14.0, through: bounds.height - 14, by: 20) {
                dot.setFill(); NSBezierPath(ovalIn: NSRect(x: x, y: y, width: 2, height: 2)).fill()
            }
        }

        let accent = NSColor(calibratedRed: 0.66, green: 0.60, blue: 1, alpha: 1)
        draw("✦", at: NSPoint(x: 28, y: 20), size: 23, color: accent, weight: .regular)
        draw(effort, at: NSPoint(x: 70, y: 22), size: 21, color: .white, weight: .semibold)
        draw("·", at: NSPoint(x: 122, y: 22), size: 21, color: .gray, weight: .regular)
        draw(model, at: NSPoint(x: 142, y: 22), size: 21, color: .systemGray, weight: .regular)

        let ring = NSBezierPath(ovalIn: NSRect(x: 280, y: 19, width: 27, height: 27))
        NSColor(calibratedWhite: 0.27, alpha: 1).setStroke(); ring.lineWidth = 5; ring.stroke()
        draw(context, at: NSPoint(x: 324, y: 22), size: 21, color: .white, weight: .regular)

        let toggle = NSBezierPath(roundedRect: NSRect(x: bounds.width - 455, y: 20, width: 48, height: 28), xRadius: 14, yRadius: 14)
        accent.setFill(); toggle.fill()
        NSColor.white.setFill(); NSBezierPath(ovalIn: NSRect(x: bounds.width - 431, y: 23, width: 22, height: 22)).fill()
        draw("Auto", at: NSPoint(x: bounds.width - 392, y: 23), size: 21, color: .white, weight: .regular)
        draw("Compact", at: NSPoint(x: bounds.width - 260, y: 23), size: 21, color: .systemGray, weight: .regular)
        draw("⚙", at: NSPoint(x: bounds.width - 74, y: 19), size: 25, color: .white, weight: .regular)
    }

    private func draw(_ text: String, at point: NSPoint, size: CGFloat, color: NSColor, weight: NSFont.Weight) {
        let font = NSFont.systemFont(ofSize: size, weight: weight)
        text.draw(at: point, withAttributes: [.font: font, .foregroundColor: color])
    }
}

final class Delegate: NSObject, NSApplicationDelegate {
    private let panel = NSPanel(contentRect: .zero, styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: true)
    private let bar = BarView(frame: .zero)
    private var timer: Timer?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        panel.level = .floating
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = false
        panel.ignoresMouseEvents = true
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.contentView = bar
        timer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { [weak self] _ in self?.reposition() }
        reposition()
    }

    private func reposition() {
        guard let frame = hostFrame() else { panel.orderOut(nil); return }
        let height: CGFloat = 70
        let margin: CGFloat = 20
        let width = max(520, frame.width - margin * 2)
        let screenHeight = NSScreen.screens.first(where: { $0.frame.contains(NSPoint(x: frame.midX, y: 0)) })?.frame.height ?? NSScreen.main?.frame.height ?? 0
        let bottom = screenHeight - frame.maxY
        panel.setFrame(NSRect(x: frame.minX + margin, y: bottom + 96, width: width, height: height), display: true)
        panel.orderFrontRegardless()
        bar.needsDisplay = true
    }

    private func hostFrame() -> CGRect? {
        let apps = NSWorkspace.shared.runningApplications.filter {
            let name = ($0.localizedName ?? "").lowercased()
            return name.contains("chatgpt") || name.contains("codex")
        }
        let app = apps.first(where: { $0.isActive }) ?? apps.first
        guard let pid = app?.processIdentifier else { return nil }
        let list = CGWindowListCopyWindowInfo([.optionOnScreenOnly, .excludeDesktopElements], kCGNullWindowID) as? [[String: Any]] ?? []
        for info in list where (info[kCGWindowOwnerPID as String] as? Int) == Int(pid) && (info[kCGWindowLayer as String] as? Int) == 0 {
            guard let value = info[kCGWindowBounds as String] as? [String: CGFloat], let rect = CGRect(dictionaryRepresentation: value as CFDictionary) else { continue }
            return rect
        }
        return nil
    }
}

let app = NSApplication.shared
let delegate = Delegate()
app.delegate = delegate
app.run()
