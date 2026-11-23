import SwiftUI

struct DesignTokens: Decodable {
  struct Spacing: Decodable {
    let none: CGFloat
    let unit: CGFloat
    let scale: [CGFloat]
  }
  struct Motion: Decodable {
    struct Spring: Decodable {
      let damping: Double
      let response: Double
    }
    let spring: Spring
  }
  let color: [String: String]
  let spacing: Spacing
  let radius: [String: CGFloat]
  let motion: Motion
  let layout: [String: CGFloat]
  static let shared = try! JSONDecoder().decode(
    Self.self,
    from: Data(contentsOf: Bundle.module.url(forResource: "design-tokens", withExtension: "json")!))
}
enum T {
  static let clear = Color.clear
  static let none = DesignTokens.shared.spacing.none
  static let tokens = DesignTokens.shared
  static func color(_ key: String) -> Color {
    let value = tokens.color[key] ?? tokens.color["ink"]!
    let n = UInt64(value.dropFirst(), radix: 16)!
    return Color(
      red: Double((n >> 16) & 255) / 255, green: Double((n >> 8) & 255) / 255,
      blue: Double(n & 255) / 255)
  }
  static let primary = color("primary"), surface = color("surface"),
    background = color("background"), ink = color("ink"), muted = color("muted"),
    line = color("line"), yellow = color("accent_warm"), coral = color("accent_playful"),
    softGreen = color("soft_green"), softYellow = color("soft_yellow"), white = color("white")
  static let xxs = tokens.spacing.scale[0], xs = tokens.spacing.scale[1],
    sm = tokens.spacing.scale[2], md = tokens.spacing.scale[3], lg = tokens.spacing.scale[4],
    xl = tokens.spacing.scale[5], xxl = tokens.spacing.scale[6]
  static let card = tokens.radius["card"]!, button = tokens.radius["button"]!
  static func size(_ key: String) -> CGFloat { tokens.layout[key]! }
  static let spring = Animation.spring(
    response: tokens.motion.spring.response, dampingFraction: tokens.motion.spring.damping)
}
struct PiyoButton: ButtonStyle {
  var secondary = false
  func makeBody(configuration: Configuration) -> some View {
    configuration.label.font(.headline).padding(.horizontal, T.lg).frame(
      minHeight: T.size("buttonHeight")
    ).foregroundStyle(secondary ? T.primary : T.white).background(
      secondary ? T.softGreen : T.primary, in: RoundedRectangle(cornerRadius: T.button)
    ).opacity(configuration.isPressed ? 0.8 : 1).offset(y: configuration.isPressed ? T.xxs / 2 : 0)
  }
}
extension View {
  func piyoCard(_ color: Color = T.surface) -> some View {
    padding(T.lg).background(color, in: RoundedRectangle(cornerRadius: T.card)).overlay(
      RoundedRectangle(cornerRadius: T.card).stroke(T.line, lineWidth: 1))
  }
}
enum MascotState: String { case idle, thinking, celebrating, encouraging, sleepy }
struct PiyoMascot: View {
  var state: MascotState = .idle
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  var body: some View {
    TimelineView(.animation(minimumInterval: 1 / 20, paused: reduceMotion)) { timeline in
      let time = reduceMotion ? 0 : timeline.date.timeIntervalSinceReferenceDate
      Canvas { context, size in
        let w = size.width
        let h = size.height
        let bob = sin(time * 2) * h * 0.025
        func ellipse(
          _ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat, _ color: Color
        ) {
          context.fill(
            Path(ellipseIn: CGRect(x: x * w, y: y * h + bob, width: width * w, height: height * h)),
            with: .color(color))
        }
        ellipse(0.2, 0.84, 0.6, 0.06, T.ink.opacity(0.09))
        ellipse(0.16, 0.20, 0.68, 0.64, T.yellow)
        ellipse(0.21, 0.44, 0.58, 0.37, T.softYellow)
        let wing = state == .celebrating ? CGFloat(sin(time * 10)) * 0.05 : 0
        ellipse(0.07, 0.44 + wing, 0.18, 0.29, T.yellow)
        ellipse(0.75, 0.44 - wing, 0.18, 0.29, T.yellow)
        ellipse(0.34, 0.8, 0.13, 0.055, T.coral)
        ellipse(0.55, 0.8, 0.13, 0.055, T.coral)
        var feather = Path()
        feather.move(to: CGPoint(x: w * 0.47, y: h * 0.25 + bob))
        feather.addQuadCurve(
          to: CGPoint(x: w * 0.59, y: h * 0.08 + bob),
          control: CGPoint(x: w * 0.31, y: h * 0.03 + bob))
        context.stroke(
          feather, with: .color(T.primary),
          style: StrokeStyle(lineWidth: w * 0.035, lineCap: .round))
        let blink =
          state == .sleepy || (!reduceMotion && time.truncatingRemainder(dividingBy: 5) < 0.16)
        for x in [CGFloat(0.35), 0.62] { ellipse(x, 0.43, 0.045, blink ? 0.012 : 0.065, T.ink) }
        ellipse(0.27, 0.53, 0.11, 0.045, T.coral.opacity(0.55))
        ellipse(0.65, 0.53, 0.11, 0.045, T.coral.opacity(0.55))
        var beak = Path()
        beak.move(to: CGPoint(x: w * 0.46, y: h * 0.53 + bob))
        beak.addLine(to: CGPoint(x: w * 0.56, y: h * 0.53 + bob))
        beak.addLine(to: CGPoint(x: w * 0.51, y: h * 0.60 + bob))
        beak.closeSubpath()
        context.fill(beak, with: .color(T.coral))
        if state == .celebrating {
          for i in 0..<8 {
            let angle = Double(i) * Double.pi / 4
            let x = 0.5 + cos(angle) * 0.44
            let y = 0.45 + sin(angle) * 0.4
            ellipse(x, y, 0.025, 0.04, i.isMultiple(of: 2) ? T.primary : T.coral)
          }
        }
        if state == .thinking {
          context.draw(
            Text("?").font(.title.bold()).foregroundColor(T.primary),
            at: CGPoint(x: w * 0.85, y: h * 0.15))
        }
      }.rotationEffect(.degrees(state == .thinking ? -8 : 0))
    }.accessibilityElement(children: .ignore).accessibilityLabel(
      "Piyo, your \(state.rawValue) learning companion")
  }
}

private struct AnimationsPausedKey: EnvironmentKey { static let defaultValue = false }
extension EnvironmentValues {
  var piyoAnimationsPaused: Bool {
    get { self[AnimationsPausedKey.self] }
    set { self[AnimationsPausedKey.self] = newValue }
  }
}
