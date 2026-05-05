import AppKit
import CoreGraphics

func renderIcon(size: CGFloat) -> NSImage {
    let image = NSImage(size: NSSize(width: size, height: size))
    image.lockFocus()

    guard let ctx = NSGraphicsContext.current?.cgContext else {
        image.unlockFocus()
        return image
    }

    let rect = CGRect(x: 0, y: 0, width: size, height: size)

    let inset = size * 0.05
    let bgRect = rect.insetBy(dx: inset, dy: inset)
    let cornerRadius = bgRect.width * 0.225
    let bgPath = CGPath(roundedRect: bgRect,
                        cornerWidth: cornerRadius,
                        cornerHeight: cornerRadius,
                        transform: nil)

    ctx.saveGState()
    ctx.addPath(bgPath)
    ctx.clip()

    let colors = [
        NSColor(red: 0.45, green: 0.04, blue: 0.72, alpha: 1.0).cgColor,
        NSColor(red: 0.97, green: 0.14, blue: 0.52, alpha: 1.0).cgColor
    ]
    let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                              colors: colors as CFArray,
                              locations: [0.0, 1.0])!
    ctx.drawLinearGradient(gradient,
                           start: CGPoint(x: 0, y: size),
                           end: CGPoint(x: size, y: 0),
                           options: [])

    ctx.setFillColor(NSColor.white.withAlphaComponent(0.06).cgColor)
    ctx.fill(CGRect(x: bgRect.minX, y: bgRect.midY, width: bgRect.width, height: bgRect.height / 2))

    ctx.restoreGState()

    let micPointSize = size * 0.55
    let symbolConfig = NSImage.SymbolConfiguration(pointSize: micPointSize, weight: .bold)
    if let symbol = NSImage(systemSymbolName: "mic.fill", accessibilityDescription: nil)?
        .withSymbolConfiguration(symbolConfig) {
        let tinted = NSImage(size: symbol.size)
        tinted.lockFocus()
        symbol.draw(at: .zero, from: NSRect(origin: .zero, size: symbol.size), operation: .sourceOver, fraction: 1.0)
        NSColor.white.set()
        let symbolRect = NSRect(origin: .zero, size: symbol.size)
        symbolRect.fill(using: .sourceIn)
        tinted.unlockFocus()

        let drawX = (size - tinted.size.width) / 2
        let drawY = (size - tinted.size.height) / 2 - size * 0.02
        tinted.draw(at: NSPoint(x: drawX, y: drawY),
                    from: NSRect(origin: .zero, size: tinted.size),
                    operation: .sourceOver,
                    fraction: 1.0)
    }

    let fontSize = size * 0.13
    let font = NSFont.systemFont(ofSize: fontSize, weight: .heavy)
    let attrs: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: NSColor.white.withAlphaComponent(0.95)
    ]
    let text = NSAttributedString(string: "TH", attributes: attrs)
    let textSize = text.size()

    let badgePadX = size * 0.04
    let badgePadY = size * 0.015
    let badgeWidth = textSize.width + badgePadX * 2
    let badgeHeight = textSize.height + badgePadY * 2
    let badgeMargin = inset + size * 0.03
    let badgeX = size - badgeWidth - badgeMargin
    let badgeY = size - badgeHeight - badgeMargin

    let badgeRect = CGRect(x: badgeX, y: badgeY, width: badgeWidth, height: badgeHeight)
    ctx.setFillColor(NSColor.black.withAlphaComponent(0.32).cgColor)
    let badgePath = CGPath(roundedRect: badgeRect,
                           cornerWidth: badgeHeight / 2,
                           cornerHeight: badgeHeight / 2,
                           transform: nil)
    ctx.addPath(badgePath)
    ctx.fillPath()

    text.draw(at: NSPoint(x: badgeX + (badgeWidth - textSize.width) / 2,
                          y: badgeY + (badgeHeight - textSize.height) / 2 - size * 0.005))

    image.unlockFocus()
    return image
}

func savePNG(image: NSImage, path: String) {
    guard let tiff = image.tiffRepresentation,
          let rep = NSBitmapImageRep(data: tiff),
          let png = rep.representation(using: .png, properties: [:]) else {
        print("Failed to encode \(path)")
        return
    }
    do {
        try png.write(to: URL(fileURLWithPath: path))
    } catch {
        print("Failed to write \(path): \(error)")
    }
}

let sizes: [(Int, String)] = [
    (16, "icon_16x16.png"),
    (32, "icon_16x16@2x.png"),
    (32, "icon_32x32.png"),
    (64, "icon_32x32@2x.png"),
    (128, "icon_128x128.png"),
    (256, "icon_128x128@2x.png"),
    (256, "icon_256x256.png"),
    (512, "icon_256x256@2x.png"),
    (512, "icon_512x512.png"),
    (1024, "icon_512x512@2x.png")
]

let outputDir = "AppIcon.iconset"
try? FileManager.default.removeItem(atPath: outputDir)
try? FileManager.default.createDirectory(atPath: outputDir, withIntermediateDirectories: true)

for (size, filename) in sizes {
    let image = renderIcon(size: CGFloat(size))
    savePNG(image: image, path: "\(outputDir)/\(filename)")
    print("✓ \(filename) (\(size)x\(size))")
}

print("\nDone.")
