import AppKit

// Code-native ScreenBridge mark: a display and phone joined by a bright bridge.
let size = NSSize(width: 1024, height: 1024)
let image = NSImage(size: size)
image.lockFocus()
NSGradient(starting: NSColor(red: 0.025, green: 0.09, blue: 0.2, alpha: 1),
           ending: NSColor(red: 0.08, green: 0.25, blue: 0.46, alpha: 1))!
    .draw(in: NSBezierPath(rect: NSRect(origin: .zero, size: size)), angle: 45)
let screen = NSBezierPath(roundedRect: NSRect(x: 155, y: 340, width: 620, height: 450), xRadius: 52, yRadius: 52)
NSColor.white.setStroke()
screen.lineWidth = 30
screen.stroke()
let stand = NSBezierPath()
stand.move(to: NSPoint(x: 465, y: 340))
stand.line(to: NSPoint(x: 465, y: 235))
stand.move(to: NSPoint(x: 350, y: 235))
stand.line(to: NSPoint(x: 550, y: 235))
stand.lineWidth = 30
stand.lineCapStyle = .round
stand.stroke()
let phoneRect = NSRect(x: 640, y: 150, width: 225, height: 395)
let phone = NSBezierPath(roundedRect: phoneRect, xRadius: 38, yRadius: 38)
NSColor(red: 0.025, green: 0.1, blue: 0.22, alpha: 1).setFill()
phone.fill()
NSColor.white.setStroke()
phone.lineWidth = 26
phone.stroke()
let bridge = NSBezierPath()
bridge.move(to: NSPoint(x: 300, y: 505))
bridge.line(to: NSPoint(x: 410, y: 630))
bridge.line(to: NSPoint(x: 515, y: 500))
bridge.line(to: NSPoint(x: 750, y: 365))
bridge.lineWidth = 42
bridge.lineCapStyle = .round
bridge.lineJoinStyle = .round
NSColor(red: 0.18, green: 0.9, blue: 0.86, alpha: 1).setStroke()
bridge.stroke()
NSColor(red: 0.18, green: 0.9, blue: 0.86, alpha: 1).setFill()
NSBezierPath(ovalIn: NSRect(x: 718, y: 333, width: 64, height: 64)).fill()
image.unlockFocus()
// App icons must be opaque RGB, including their encoded pixel format.
let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: 1024, pixelsHigh: 1024,
                              bitsPerSample: 8, samplesPerPixel: 3, hasAlpha: false,
                              isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
image.draw(in: NSRect(origin: .zero, size: size))
NSGraphicsContext.restoreGraphicsState()
try bitmap.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: CommandLine.arguments[1]))
