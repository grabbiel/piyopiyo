import SnapshotTesting
import SwiftUI
import XCTest

@testable import PiyoPiyoCore

final class SnapshotTests: XCTestCase {
  @MainActor func testEveryFormat() async throws {
    let bank = try Question.bundled()
    for format in QuestionFormat.allCases {
      let q = try XCTUnwrap(bank.first { $0.format == format })
      let content = ScrollView {
        VStack(alignment: .leading, spacing: T.lg) {
          Text(q.format.title).font(.caption).foregroundStyle(T.primary)
          Text(q.prompt).font(.title2.bold())
          if let context = q.context { Text(context).font(.body.monospaced()) }
          QuestionInput(question: q, answer: .constant([]))
          Spacer(minLength: 0)
        }.padding(T.lg)
      }.background(T.surface).foregroundStyle(T.ink).tint(T.primary).environment(
        \.colorScheme, .light
      ).environment(\.piyoAnimationsPaused, true)
      #if os(macOS)
        let view = NSHostingView(rootView: content.frame(width: 720, height: 900))
        view.frame = CGRect(x: 0, y: 0, width: 720, height: 900)
        _ = NSApplication.shared
        let window = NSWindow(
          contentRect: view.frame, styleMask: [.titled], backing: .buffered, defer: false)
        window.contentView = view
        window.orderFront(nil)
        try await Task.sleep(for: .milliseconds(100))
        assertSnapshot(
          of: view, as: .image(precision: 0.98), named: "mac-" + format.rawValue,
          record: ProcessInfo.processInfo.environment["RECORD_SNAPSHOTS"] == "1")
        window.orderOut(nil)
      #else
        let host = UIHostingController(rootView: content)
        let isPad = UIDevice.current.userInterfaceIdiom == .pad
        assertSnapshot(
          of: host,
          as: .image(
            on: isPad
              ? ViewImageConfig(
                safeArea: .init(top: 24, left: 0, bottom: 20, right: 0),
                size: CGSize(width: 744, height: 1133),
                traits: UITraitCollection(userInterfaceIdiom: .pad)) : .iPhone8(.portrait),
            precision: 0.98),
          named: (isPad ? "ipad-" : "iphone-") + format.rawValue,
          record: ProcessInfo.processInfo.environment["RECORD_SNAPSHOTS"] == "1")
      #endif
    }
  }
}
