import CoreGraphics
import ImageIO
import UniformTypeIdentifiers
import Foundation

// Platform-size packaging only; preserve the generated illustration and alpha.
let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let source = root.appendingPathComponent("SourcesDesk/Branding/sources-icon-master.png")
let output = root.appendingPathComponent("SourcesDesk/Branding/SourcesIcon.iconset")
guard let input = CGImageSourceCreateWithURL(source as CFURL, nil),
      let image = CGImageSourceCreateImageAtIndex(input, 0, nil) else { fatalError("Missing Sources artwork") }
try FileManager.default.createDirectory(at: output, withIntermediateDirectories: true)
for size in [16, 32, 128, 256, 512] {
    for scale in [1, 2] {
        let pixels = size * scale
        let name = "icon_\(size)x\(size)" + (scale == 2 ? "@2x" : "") + ".png"
        guard let context = CGContext(data: nil, width: pixels, height: pixels, bitsPerComponent: 8,
                                      bytesPerRow: pixels * 4, space: CGColorSpace(name: CGColorSpace.sRGB)!,
                                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { fatalError("Bitmap creation failed") }
        context.interpolationQuality = .high
        context.draw(image, in: CGRect(x: 0, y: 0, width: pixels, height: pixels))
        guard let bitmap = context.makeImage(),
              let destination = CGImageDestinationCreateWithURL(output.appendingPathComponent(name) as CFURL, UTType.png.identifier as CFString, 1, nil) else { fatalError("PNG creation failed") }
        CGImageDestinationAddImage(destination, bitmap, nil)
        guard CGImageDestinationFinalize(destination) else { fatalError("PNG write failed") }
    }
}
print("Packaged 10 Sources icon sizes with transparency.")
