import SceneKit
import SpriteKit
import SwiftUI

protocol QuestionRenderable: View { var question: Question { get } }
struct QuestionInput: View {
  let question: Question
  @Binding var answer: [String]
  @ViewBuilder var body: some View {
    switch question.format {
    case .multipleChoice: MultipleChoiceQuestion(question: question, answer: $answer)
    case .multipleSelect: MultipleSelectQuestion(question: question, answer: $answer)
    case .trueFalse: TrueFalseQuestion(question: question, answer: $answer)
    case .fillBlank: FillBlankQuestion(question: question, answer: $answer)
    case .shortAnswer: ShortAnswerQuestion(question: question, answer: $answer)
    case .matching: MatchingQuestion(question: question, answer: $answer)
    case .categorization: CategorizationQuestion(question: question, answer: $answer)
    case .ordering: OrderingQuestion(question: question, answer: $answer)
    case .dropdown: DropdownQuestion(question: question, answer: $answer)
    case .numeric: NumericQuestion(question: question, answer: $answer)
    case .visual: VisualQuestion(question: question, answer: $answer)
    case .dragDrop: DragDropQuestion(question: question, answer: $answer)
    case .audio: AudioQuestion(question: question, answer: $answer)
    case .game2D, .game3D:
      switch question.game?.template {
      case "falling_blocks": Game2DQuestion(question: question, answer: $answer)
      case "system_architecture": Game3DQuestion(question: question, answer: $answer)
      default:
        if question.format == .game2D {
          Game2DQuestion(question: question, answer: $answer)
        } else {
          Game3DQuestion(question: question, answer: $answer)
        }
      }
    case .live: LiveQuestion(question: question, answer: $answer)
    case .homework: HomeworkQuestion(question: question, answer: $answer)
    case .collaborative: CollaborativeQuestion(question: question, answer: $answer)
    }
  }
}
private func slot(_ values: Binding<[String]>, _ index: Int) -> Binding<String> {
  Binding(
    get: { values.wrappedValue.indices.contains(index) ? values.wrappedValue[index] : "" },
    set: { value in
      var copy = values.wrappedValue
      while copy.count <= index { copy.append("") }
      copy[index] = value
      values.wrappedValue = copy
    })
}
struct Choices: View {
  let options: [String]
  @Binding var answer: [String]
  var multiple = false
  var body: some View {
    VStack(spacing: T.sm) {
      ForEach(Array(options.enumerated()), id: \.offset) { index, option in
        Button {
          if multiple {
            if answer.contains(option) {
              answer.removeAll { $0 == option }
            } else {
              answer.append(option)
            }
          } else {
            answer = [option]
          }
        } label: {
          HStack(spacing: T.md) {
            Text(String(UnicodeScalar(65 + index)!)).font(.subheadline.bold()).frame(
              width: T.xl, height: T.xl
            ).background(
              answer.contains(option) ? T.primary : T.background,
              in: RoundedRectangle(cornerRadius: T.xs)
            ).foregroundStyle(answer.contains(option) ? T.white : T.muted)
            Text(option).multilineTextAlignment(.leading).frame(
              maxWidth: .infinity, alignment: .leading)
            Image(systemName: answer.contains(option) ? "checkmark.circle.fill" : "circle")
              .foregroundStyle(answer.contains(option) ? T.primary : T.line)
          }.padding(T.md).background(
            answer.contains(option) ? T.softGreen : T.surface,
            in: RoundedRectangle(cornerRadius: T.button)
          ).overlay(
            RoundedRectangle(cornerRadius: T.button).stroke(
              answer.contains(option) ? T.primary : T.line, lineWidth: 1))
        }.buttonStyle(.plain).accessibilityLabel(option).accessibilityAddTraits(
          answer.contains(option) ? .isSelected : [])
      }
    }
  }
}
struct MultipleChoiceQuestion: QuestionRenderable {
  let question: Question
  @Binding var answer: [String]
  var body: some View { Choices(options: question.options, answer: $answer) }
}
struct MultipleSelectQuestion: QuestionRenderable {
  let question: Question
  @Binding var answer: [String]
  var body: some View {
    VStack(alignment: .leading, spacing: T.sm) {
      Text("Select all that apply").font(.subheadline).foregroundStyle(T.muted)
      Choices(options: question.options, answer: $answer, multiple: true)
    }
  }
}
struct TrueFalseQuestion: QuestionRenderable {
  let question: Question
  @Binding var answer: [String]
  var body: some View { Choices(options: question.options, answer: $answer) }
}
struct FillBlankQuestion: QuestionRenderable {
  let question: Question
  @Binding var answer: [String]
  var body: some View {
    VStack(spacing: T.md) {
      ForEach(Array((question.labels ?? ["Your answer"]).enumerated()), id: \.offset) { i, label in
        TextField(label, text: slot($answer, i)).textFieldStyle(.roundedBorder).accessibilityLabel(
          label)
      }
    }
  }
}
struct ShortAnswerQuestion: QuestionRenderable {
  let question: Question
  @Binding var answer: [String]
  var body: some View {
    VStack(alignment: .leading, spacing: T.sm) {
      Text("Explain your reasoning in your own words.").font(.subheadline).foregroundStyle(T.muted)
      TextEditor(text: slot($answer, 0)).font(.body).frame(minHeight: T.size("editorHeight"))
        .padding(T.xs).background(T.surface, in: RoundedRectangle(cornerRadius: T.button)).overlay(
          RoundedRectangle(cornerRadius: T.button).stroke(T.line)
        ).accessibilityLabel("Your written answer")
      Text("Saved offline. Model feedback is available after sign-in and sync.").font(.caption)
        .foregroundStyle(T.muted)
    }
  }
}
struct MatchingQuestion: QuestionRenderable {
  let question: Question
  @Binding var answer: [String]
  var body: some View {
    VStack(spacing: T.md) {
      ForEach(Array((question.labels ?? []).enumerated()), id: \.offset) { i, label in
        HStack {
          Text(label).font(.headline)
          Spacer()
          Picker("Match \(label)", selection: slot($answer, i)) {
            Text("Choose…").tag("")
            ForEach(question.options, id: \.self) { Text($0).tag($0) }
          }.labelsHidden().frame(maxWidth: T.size("cardMinWidth"))
        }.padding(T.md).background(T.background, in: RoundedRectangle(cornerRadius: T.button))
      }
    }
  }
}
struct CategorizationQuestion: QuestionRenderable {
  let question: Question
  @Binding var answer: [String]
  var body: some View {
    VStack(alignment: .leading, spacing: T.md) {
      Text("Drag an item into a category, or use its menu.").font(.subheadline).foregroundStyle(
        T.muted)
      ForEach(Array(question.options.enumerated()), id: \.offset) { i, item in
        HStack {
          Text(item).draggable(String(i))
          Spacer()
          Picker("Category for \(item)", selection: slot($answer, i)) {
            Text("Choose…").tag("")
            ForEach(question.groups ?? [], id: \.self) { Text($0).tag($0) }
          }.labelsHidden()
        }.padding(T.sm).background(T.background, in: RoundedRectangle(cornerRadius: T.button))
      }
      ForEach(question.groups ?? [], id: \.self) { group in
        VStack(alignment: .leading, spacing: T.xs) {
          Text(group).font(.headline)
          ForEach(Array(question.options.enumerated()), id: \.offset) { i, item in
            if answer.indices.contains(i), answer[i] == group { Text(item).font(.caption) }
          }
        }.frame(maxWidth: .infinity, minHeight: T.size("buttonHeight"), alignment: .leading)
          .padding(T.md).background(T.softGreen, in: RoundedRectangle(cornerRadius: T.button))
          .dropDestination(for: String.self) { items, _ in
            guard let first = items.first, let i = Int(first), question.options.indices.contains(i)
            else { return false }
            slot($answer, i).wrappedValue = group
            return true
          }
      }
    }
  }
}
struct OrderingQuestion: QuestionRenderable {
  let question: Question
  @Binding var answer: [String]
  var body: some View {
    VStack(spacing: T.sm) {
      ForEach(Array(answer.enumerated()), id: \.offset) { i, item in
        HStack {
          Text("\(i+1)").font(.headline).foregroundStyle(T.primary)
          Text(item).frame(maxWidth: .infinity, alignment: .leading)
          Button {
            answer.swapAt(i, i - 1)
          } label: {
            Image(systemName: "arrow.up")
          }.disabled(i == 0).accessibilityLabel("Move \(item) up")
          Button {
            answer.swapAt(i, i + 1)
          } label: {
            Image(systemName: "arrow.down")
          }.disabled(i == answer.count - 1).accessibilityLabel("Move \(item) down")
        }.padding(T.md).background(T.background, in: RoundedRectangle(cornerRadius: T.button))
      }
    }.onAppear { if answer.isEmpty { answer = question.options } }
  }
}
struct DropdownQuestion: QuestionRenderable {
  let question: Question
  @Binding var answer: [String]
  var body: some View {
    Picker("Choose the missing term", selection: slot($answer, 0)) {
      Text("Choose…").tag("")
      ForEach(question.options, id: \.self) { Text($0).tag($0) }
    }.pickerStyle(.menu).padding(T.md).piyoCard(T.background)
  }
}
struct NumericQuestion: QuestionRenderable {
  let question: Question
  @Binding var answer: [String]
  var body: some View {
    TextField("Enter a number", text: slot($answer, 0)).textFieldStyle(.roundedBorder).font(
      .title2.monospacedDigit()
    ).accessibilityLabel("Numeric answer")
  }
}
enum ComponentRole: Equatable {
  case client, service, storage, cache, queue, router
  init(_ label: String) {
    let name = label.lowercased()
    func has(_ words: String...) -> Bool { words.contains { name.contains($0) } }
    if has("queue", "stream", "broker", "topic") {
      self = .queue
    } else if has("cache", "cdn") {
      self = .cache
    } else if has("database", "storage", "replica", "disk") {
      self = .storage
    } else if has("balancer", "gateway", "router", "proxy") {
      self = .router
    } else if has("client", "browser", "user") {
      self = .client
    } else {
      self = .service
    }
  }
  var symbol: String {
    switch self {
    case .client: "laptopcomputer"
    case .service: "server.rack"
    case .storage: "externaldrive"
    case .cache: "bolt.horizontal.circle"
    case .queue: "tray.full"
    case .router: "arrow.triangle.branch"
    }
  }
}
struct VisualQuestion: QuestionRenderable {
  let question: Question
  @Binding var answer: [String]
  var body: some View {
    VStack(spacing: T.md) {
      LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: T.md) {
        ForEach(question.options, id: \.self) { label in
          Button {
            answer = [label]
          } label: {
            VStack(spacing: T.sm) {
              Image(systemName: ComponentRole(label).symbol).font(.largeTitle)
              Text(label).font(.headline)
            }.frame(maxWidth: .infinity, minHeight: T.size("buttonHeight") * 2).padding(T.md)
              .background(
                answer.contains(label) ? T.softGreen : T.background,
                in: RoundedRectangle(cornerRadius: T.card)
              ).overlay(
                RoundedRectangle(cornerRadius: T.card).stroke(
                  answer.contains(label) ? T.primary : T.line))
          }.buttonStyle(.plain).accessibilityLabel("Diagram component: \(label)")
        }
      }
      Text("Original system diagram · tap a component").font(.caption).foregroundStyle(T.muted)
    }
  }
}
struct DragDropQuestion: QuestionRenderable {
  let question: Question
  @Binding var answer: [String]
  var body: some View {
    VStack(spacing: T.md) {
      Text(answer.first ?? "Drop a function here").font(.title3.monospaced()).frame(
        maxWidth: .infinity, minHeight: T.size("buttonHeight") * 2
      ).background(T.softGreen, in: RoundedRectangle(cornerRadius: T.button)).dropDestination(
        for: String.self
      ) { values, _ in
        guard let value = values.first, question.options.contains(value) else { return false }
        answer = [value]
        return true
      }
      Text("Drag a token, or tap it to place it.").font(.caption).foregroundStyle(T.muted)
      Choices(options: question.options, answer: $answer).draggable(answer.first ?? "")
      HStack {
        ForEach(question.options, id: \.self) { option in
          Text(option).font(.body.monospaced()).padding(T.xs).background(
            T.background, in: Capsule()
          ).draggable(option)
        }
      }
    }
  }
}
struct AudioQuestion: QuestionRenderable {
  let question: Question
  @Binding var answer: [String]
  @State private var error: String?
  var body: some View {
    VStack(spacing: T.md) {
      Button {
        do { try SoundPlayer.shared.play(question.audioAsset ?? "pulses") } catch {
          self.error = error.localizedDescription
        }
      } label: {
        Label("Play signal", systemImage: "play.circle.fill")
      }.buttonStyle(PiyoButton(secondary: true))
      if let error { Text(error).foregroundStyle(T.coral) }
      Choices(options: question.options, answer: $answer)
      DisclosureGroup("Accessible signal description") {
        Text("Three short, separate tones, spaced evenly.").font(.subheadline)
      }
    }
  }
}
struct LiveQuestion: QuestionRenderable {
  let question: Question
  @Binding var answer: [String]
  var body: some View {
    VStack(alignment: .leading, spacing: T.md) {
      Label("Practice a live-quiz question", systemImage: "person.2").font(.caption)
        .foregroundStyle(T.muted)
      Choices(options: question.options, answer: $answer)
    }
  }
}
struct HomeworkQuestion: QuestionRenderable {
  let question: Question
  @Binding var answer: [String]
  var body: some View {
    VStack(alignment: .leading, spacing: T.md) {
      Label("Your work is saved so you can return later.", systemImage: "tray").font(.caption)
      ShortAnswerQuestion(question: question, answer: $answer)
    }
  }
}
struct CollaborativeQuestion: QuestionRenderable {
  let question: Question
  @Binding var answer: [String]
  var body: some View {
    VStack(alignment: .leading, spacing: T.md) {
      Label("Compare ideas in a Study together room.", systemImage: "person.2").font(.caption)
      ShortAnswerQuestion(question: question, answer: $answer)
    }
  }
}

final class FallingScene: SKScene {
  var choose: ((String) -> Void)?
  init(options: [String], speed: Double = 1) {
    super.init(size: CGSize(width: T.size("gameWidth"), height: T.size("gameHeight")))
    scaleMode = .aspectFit
    backgroundColor = .clear
    let column = size.width / CGFloat(max(options.count, 1))
    let width = min(T.size("gameBlockWidth"), column - T.sm)
    for (i, value) in options.enumerated() {
      let block = SKShapeNode(
        rectOf: CGSize(width: width, height: T.size("gameBlockHeight")),
        cornerRadius: T.button)
      block.fillColor = SKColor(T.softGreen)
      block.strokeColor = SKColor(T.primary)
      block.name = value
      block.position = CGPoint(x: column * (CGFloat(i) + 0.5), y: 240)
      let label = SKLabelNode(text: value)
      label.fontName = "Menlo-Bold"
      label.fontSize = 15
      label.fontColor = block.strokeColor
      label.verticalAlignmentMode = .center
      label.name = value
      label.setScale(min(1, (width - T.sm) / max(label.frame.width, 1)))
      block.addChild(label)
      addChild(block)
      let down = SKAction.moveBy(x: 0, y: -180, duration: (3 + Double(i) * 0.4) / speed)
      block.run(.repeatForever(.sequence([down, .moveBy(x: 0, y: 180, duration: 0)])))
    }
  }
  required init?(coder: NSCoder) { fatalError("Not used") }
  func select(_ point: CGPoint) {
    if let value = nodes(at: point).compactMap(\.name).first { choose?(value) }
  }
  #if os(macOS)
    override func mouseDown(with event: NSEvent) { select(event.location(in: self)) }
  #else
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
      if let touch = touches.first { select(touch.location(in: self)) }
    }
  #endif
}
struct Game2DQuestion: QuestionRenderable {
  let question: Question
  @Binding var answer: [String]
  @Environment(\.piyoAnimationsPaused) private var animationsPaused
  @State private var scene: FallingScene?
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  var body: some View {
    VStack(spacing: T.md) {
      if let scene {
        SpriteView(
          scene: scene, isPaused: reduceMotion || animationsPaused, options: [.allowsTransparency]
        ).frame(
          height: T.size("gameHeight")
        ).background(T.background, in: RoundedRectangle(cornerRadius: T.card)).accessibilityHidden(
          true)
      }
      Text("Tap a falling block, or choose its accessible answer below.").font(.caption)
        .foregroundStyle(T.muted)
      Choices(options: question.options, answer: $answer)
    }.onAppear {
      let speed = question.game?.params?.speed ?? 1
      let s = FallingScene(options: question.options, speed: speed > 0 ? speed : 1)
      s.choose = { value in answer = [value] }
      scene = s
    }
  }
}
@MainActor private func architectureScene(_ options: [String], roles: [String: String]?)
  -> SCNScene
{
  let scene = SCNScene()
  scene.background.contents = SKColor(T.background).cgColor
  for (i, label) in options.enumerated() {
    let role: ComponentRole = {
      if let name = roles?[label]?.lowercased() {
        switch name {
        case "cylinder": return .storage
        case "sphere": return .cache
        case "capsule": return .queue
        case "pyramid": return .router
        default: return .service
        }
      }
      return ComponentRole(label)
    }()
    let shape: SCNGeometry =
      switch role {
      case .storage: SCNCylinder(radius: 0.55, height: 1.1)
      case .cache: SCNSphere(radius: 0.5)
      case .queue: SCNCapsule(capRadius: 0.3, height: 1.3)
      case .router: SCNPyramid(width: 1, height: 0.9, length: 1)
      case .client, .service: SCNBox(width: 1, height: 0.8, length: 0.7, chamferRadius: 0.1)
      }
    shape.firstMaterial?.diffuse.contents =
      role == .storage ? SKColor(T.primary).cgColor : SKColor(T.yellow).cgColor
    let node = SCNNode(geometry: shape)
    if role == .queue { node.eulerAngles.z = .pi / 2 }
    node.position = SCNVector3(Float(i % 2) * 2 - 1, 0, Float(i / 2) * 2 - 1)
    node.name = label
    scene.rootNode.addChildNode(node)
    let text = SCNText(string: label, extrusionDepth: 0.01)
    text.font = .systemFont(ofSize: 0.3)
    text.firstMaterial?.diffuse.contents = SKColor(T.ink).cgColor
    let title = SCNNode(geometry: text)
    title.position = SCNVector3(node.position.x - 0.5, 0.8, node.position.z)
    title.constraints = [SCNBillboardConstraint()]
    title.name = label
    scene.rootNode.addChildNode(title)
  }
  let camera = SCNNode()
  camera.camera = SCNCamera()
  camera.camera?.fieldOfView = 38
  camera.position = SCNVector3(4, 5, 7)
  camera.look(at: SCNVector3(0, 0, 0))
  scene.rootNode.addChildNode(camera)
  return scene
}
struct Game3DQuestion: QuestionRenderable {
  let question: Question
  @Binding var answer: [String]
  var body: some View {
    VStack(spacing: T.md) {
      SceneInteraction(
        options: question.options, roles: question.game?.params?.roles, selected: $answer
      ).frame(
        height: T.size("gameHeight")
      ).clipShape(RoundedRectangle(cornerRadius: T.card)).accessibilityHidden(true)
      Text("Drag to orbit. Tap a component, or choose it below.").font(.caption).foregroundStyle(
        T.muted)
      Choices(options: question.options, answer: $answer)
    }
  }
}
final class SceneCoordinator: NSObject {
  var selected: Binding<[String]>
  init(_ selected: Binding<[String]>) { self.selected = selected }
  #if os(macOS)
    @objc func tapped(_ recognizer: NSClickGestureRecognizer) {
      guard let view = recognizer.view as? SCNView else { return }
      pick(view, recognizer.location(in: view))
    }
  #else
    @objc func tapped(_ recognizer: UITapGestureRecognizer) {
      guard let view = recognizer.view as? SCNView else { return }
      pick(view, recognizer.location(in: view))
    }
  #endif
  func pick(_ view: SCNView, _ point: CGPoint) {
    if let name = view.hitTest(point, options: nil).first?.node.name {
      selected.wrappedValue = [name]
    }
  }
}
#if os(macOS)
  struct SceneInteraction: NSViewRepresentable {
    let options: [String]
    let roles: [String: String]?
    @Binding var selected: [String]
    func makeCoordinator() -> SceneCoordinator { SceneCoordinator($selected) }
    func makeNSView(context: Context) -> SCNView {
      let view = SCNView()
      view.scene = architectureScene(options, roles: roles)
      view.autoenablesDefaultLighting = true
      view.allowsCameraControl = true
      view.addGestureRecognizer(
        NSClickGestureRecognizer(
          target: context.coordinator, action: #selector(SceneCoordinator.tapped(_:))))
      return view
    }
    func updateNSView(_ view: SCNView, context: Context) {
      context.coordinator.selected = $selected
    }
  }
#else
  struct SceneInteraction: UIViewRepresentable {
    let options: [String]
    let roles: [String: String]?
    @Binding var selected: [String]
    func makeCoordinator() -> SceneCoordinator { SceneCoordinator($selected) }
    func makeUIView(context: Context) -> SCNView {
      let view = SCNView()
      view.scene = architectureScene(options, roles: roles)
      view.autoenablesDefaultLighting = true
      view.allowsCameraControl = true
      view.addGestureRecognizer(
        UITapGestureRecognizer(
          target: context.coordinator, action: #selector(SceneCoordinator.tapped(_:))))
      return view
    }
    func updateUIView(_ view: SCNView, context: Context) {
      context.coordinator.selected = $selected
    }
  }
#endif
