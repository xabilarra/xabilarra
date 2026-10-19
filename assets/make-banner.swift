// Generates assets/banner.jpg for the GitHub profile README.
// Usage: swift assets/make-banner.swift assets/banner.jpg
import AppKit

let size = NSSize(width: 2400, height: 700)
let rep = NSBitmapImageRep(
    bitmapDataPlanes: nil, pixelsWide: Int(size.width), pixelsHigh: Int(size.height), bitsPerSample: 8,
    samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
NSGraphicsContext.saveGraphicsState()
let base = NSGraphicsContext(bitmapImageRep: rep)!
base.cgContext.translateBy(x: 0, y: size.height)
base.cgContext.scaleBy(x: 1, y: -1)
NSGraphicsContext.current = NSGraphicsContext(cgContext: base.cgContext, flipped: true)

func color(_ hex: UInt32, _ alpha: CGFloat = 1) -> NSColor {
    NSColor(calibratedRed: CGFloat((hex >> 16) & 0xFF) / 255, green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255, alpha: alpha)
}
func text(_ s: String, _ x: CGFloat, _ y: CGFloat, _ font: NSFont, _ c: NSColor) {
    NSAttributedString(string: s, attributes: [.font: font, .foregroundColor: c]).draw(at: NSPoint(x: x, y: y))
}

// Background: near-black to deep violet, with a faint dot grid.
NSGradient(starting: color(0x0D0D14), ending: color(0x2E1A57))!.draw(in: NSRect(origin: .zero, size: size), angle: -25)
color(0xFFFFFF, 0.05).setFill()
for x in stride(from: CGFloat(20), to: size.width, by: 44) {
    for y in stride(from: CGFloat(20), to: size.height, by: 44) {
        NSBezierPath(ovalIn: NSRect(x: x, y: y, width: 3, height: 3)).fill()
    }
}
// Accent glow behind the name.
let glow = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
    colors: [color(0x8B5CF6, 0.32).cgColor, color(0x8B5CF6, 0).cgColor] as CFArray, locations: [0, 1])!
base.cgContext.drawRadialGradient(glow, startCenter: CGPoint(x: 480, y: 330), startRadius: 0,
    endCenter: CGPoint(x: 480, y: 330), endRadius: 760, options: [])

text("Xabi Larrañaga", 130, 170, .systemFont(ofSize: 132, weight: .bold), .white)
text("Sistemas a medida para crecer sin caos.", 136, 350, .systemFont(ofSize: 54, weight: .medium), color(0xFFFFFF, 0.88))
text("Ingeniero de software navarro · Fundador y director técnico de ImpulsoXL", 138, 450,
     .systemFont(ofSize: 32, weight: .regular), color(0xFFFFFF, 0.6))

// Terminal card.
let card = NSRect(x: 1450, y: 120, width: 830, height: 460)
let shadow = NSShadow(); shadow.shadowBlurRadius = 40; shadow.shadowOffset = NSSize(width: 0, height: -10)
shadow.shadowColor = color(0x000000, 0.5)
NSGraphicsContext.saveGraphicsState(); shadow.set()
color(0x14141F).setFill(); NSBezierPath(roundedRect: card, xRadius: 28, yRadius: 28).fill()
NSGraphicsContext.restoreGraphicsState()
color(0xFFFFFF, 0.08).setStroke()
let border = NSBezierPath(roundedRect: card.insetBy(dx: 1, dy: 1), xRadius: 27, yRadius: 27); border.lineWidth = 2; border.stroke()
for (i, dot) in [0xFF5F57, 0xFEBC2E, 0x28C840].enumerated() {
    color(UInt32(dot)).setFill()
    NSBezierPath(ovalIn: NSRect(x: card.minX + 34 + CGFloat(i) * 34, y: card.minY + 30, width: 20, height: 20)).fill()
}
let mono = NSFont.monospacedSystemFont(ofSize: 30, weight: .regular)
let monoBold = NSFont.monospacedSystemFont(ofSize: 30, weight: .semibold)
let lines: [(String, String)] = [
    ("$ whoami", ""), ("", "xabi · producto, marketing y código"),
    ("$ stack", ""), ("", "TypeScript · Next.js · Supabase · Swift"),
    ("$ filosofia", ""), ("", "conceptos > código · tú diriges a la IA"),
]
var y = card.minY + 92
for (prompt, output) in lines {
    if !prompt.isEmpty { text(prompt, card.minX + 40, y, monoBold, color(0x4ADE80)) }
    if !output.isEmpty { text(output, card.minX + 40, y, mono, color(0xE5E7EB)) }
    y += prompt.isEmpty ? 64 : 48
}

NSGraphicsContext.restoreGraphicsState()
let out = URL(fileURLWithPath: CommandLine.arguments[1])
try! rep.representation(using: .jpeg, properties: [.compressionFactor: 0.88])!.write(to: out)
print("Wrote \(out.path)")
