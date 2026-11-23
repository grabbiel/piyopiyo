// swift-tools-version: 5.10
import PackageDescription
let package = Package(name: "SourcesDesk", platforms: [.macOS(.v14)], products: [.executable(name: "SourcesDesk", targets: ["SourcesDesk"])], targets: [.executableTarget(name: "SourcesDesk", resources: [.process("Resources")])])
