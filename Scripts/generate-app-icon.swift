import AppKit
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

// Decode and render through an explicit RGB context; AppKit's 24-bit bitmap
// graphics context can fail to draw and silently produce an all-black icon.
let source = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
    .deletingLastPathComponent().appendingPathComponent("Design/AIIconSource.png")
guard let artwork = NSBitmapImageRep(data: try Data(contentsOf: source))?.cgImage,
      let space = CGColorSpace(name: CGColorSpace.sRGB),
      let context = CGContext(data: nil, width: 1024, height: 1024, bitsPerComponent: 8,
                              bytesPerRow: 0, space: space,
                              bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue) else {
    fatalError("Cannot decode or render AI icon artwork")
}
context.interpolationQuality = .high
context.draw(artwork, in: CGRect(x: 0, y: 0, width: 1024, height: 1024))
guard let icon = context.makeImage(),
      let destination = CGImageDestinationCreateWithURL(URL(fileURLWithPath: CommandLine.arguments[1]) as CFURL,
                                                       UTType.png.identifier as CFString, 1, nil) else {
    fatalError("Cannot create app icon PNG")
}
CGImageDestinationAddImage(destination, icon, nil)
guard CGImageDestinationFinalize(destination) else { fatalError("Cannot save app icon PNG") }
