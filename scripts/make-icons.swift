import CoreGraphics
import ImageIO
import UniformTypeIdentifiers
import Foundation
// Deterministic platform-size packaging of the approved original illustration.
let source = URL(fileURLWithPath: "artifacts/branding/piyopiyo-icon-master.png")
let directory = URL(fileURLWithPath: "PiyoPiyo/App/Assets.xcassets/AppIcon.appiconset", isDirectory: true)
guard let imageSource = CGImageSourceCreateWithURL(source as CFURL, nil), let artwork = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else { fatalError("Missing PiyoPiyo icon master") }
try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
func render(_ pixels: Int, filename: String) throws {
  guard let context = CGContext(data: nil, width: pixels, height: pixels, bitsPerComponent: 8, bytesPerRow: pixels * 4, space: CGColorSpace(name: CGColorSpace.sRGB)!, bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue) else { fatalError("Cannot create icon bitmap") }
  context.interpolationQuality = .high
  context.draw(artwork, in: CGRect(x: 0, y: 0, width: pixels, height: pixels))
  let url = directory.appendingPathComponent(filename)
  guard let result = context.makeImage(), let output = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil) else { fatalError("Cannot create PNG output") }
  CGImageDestinationAddImage(output, result, nil)
  guard CGImageDestinationFinalize(output) else { fatalError("Cannot save icon") }
}
var images: [[String:String]] = []
for size in [16,32,128,256,512] { for scale in [1,2] {
  let name="mac-\(size)@\(scale)x.png"; try render(size*scale,filename:name)
  images.append(["idiom":"mac","size":"\(size)x\(size)","scale":"\(scale)x","filename":name])
} }
try render(1024,filename:"ios-1024.png")
images.append(["idiom":"universal","platform":"ios","size":"1024x1024","filename":"ios-1024.png"])
let data=try JSONSerialization.data(withJSONObject:["images":images,"info":["author":"xcode","version":1]],options:[.prettyPrinted,.sortedKeys])
try data.write(to:directory.appendingPathComponent("Contents.json"))
print("Packaged 11 opaque app icons from the original chick illustration.")
