// swift-tools-version: 5.10
import PackageDescription
let package = Package(
 name: "PiyoPiyoCore",
 platforms: [.iOS(.v17), .macOS(.v14)],
 products: [.library(name: "PiyoPiyoCore", targets: ["PiyoPiyoCore"])],
 dependencies: [.package(url:"https://github.com/pointfreeco/swift-snapshot-testing",exact:"1.19.7")],
 targets: [
  .systemLibrary(name: "CSQLite", pkgConfig: "sqlite3"),
  .target(name: "PiyoPiyoCore", dependencies: ["CSQLite"], resources: [.process("Resources")]),
  .testTarget(name: "PiyoPiyoCoreTests", dependencies: ["PiyoPiyoCore",.product(name:"SnapshotTesting",package:"swift-snapshot-testing")], exclude: ["__Snapshots__"])
 ])
