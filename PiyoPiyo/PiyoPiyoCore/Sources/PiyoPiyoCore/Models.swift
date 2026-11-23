import Foundation

public enum QuestionFormat: String, Codable, CaseIterable, Sendable, Identifiable {
  case multipleChoice = "multiple_choice"
  case multipleSelect = "multiple_select"
  case trueFalse = "true_false"
  case fillBlank = "fill_blank"
  case shortAnswer = "short_answer"
  case matching, categorization, ordering, dropdown, numeric, visual
  case dragDrop = "drag_drop"
  case audio
  case game2D = "game_2d"
  case game3D = "game_3d"
  case live, homework, collaborative
  public var id: String { rawValue }
  public var title: String {
    switch self {
    case .game2D: "2D challenge"
    case .game3D: "3D explorer"
    default: rawValue.replacingOccurrences(of: "_", with: " ").capitalized
    }
  }
  public var isOpen: Bool { [.shortAnswer, .homework, .collaborative].contains(self) }
  public var symbol: String {
    switch self {
    case .game2D, .game3D: "gamecontroller"
    case .audio: "waveform"
    case .shortAnswer, .homework: "pencil.line"
    case .live, .collaborative: "person.2"
    case .ordering: "arrow.up.arrow.down"
    case .numeric: "number"
    default: "square.grid.2x2"
    }
  }
}
public struct GameSpec: Codable, Sendable, Equatable {
  public struct Params: Codable, Sendable, Equatable {
    public var speed: Double?
    public var roles: [String: String]?
  }
  public var template: String
  public var params: Params?
}
public struct Question: Codable, Identifiable, Sendable, Equatable {
  public let id: String
  public let format: QuestionFormat
  public let topic: String
  public let prompt: String
  public let options: [String]
  public let correct: [String]
  public let explanation: String
  public let sourceId: String
  public let sourceURL: String
  public let difficulty: String
  public var sourceTitle: String?
  public var context: String?
  public var labels: [String]?
  public var groups: [String]?
  public var criteria: [String]?
  public var rubric: String?
  public var audioAsset: String?
  public var dueAt: String?
  public var tolerance: Double?
  public var generation: String?
  public var game: GameSpec?
  public static func bundled() throws -> [Question] {
    try JSONDecoder().decode(
      [Question].self,
      from: Data(contentsOf: Bundle.module.url(forResource: "questions", withExtension: "json")!))
  }
}
public enum DeliveryMode: String, Codable, CaseIterable, Sendable, Identifiable {
  case practice, timed
  case openBook = "open_book"
  case homework
  case game2D = "game_2d"
  case game3D = "game_3d"
  case live, collaborative
  public var id: String { rawValue }
  public var title: String {
    switch self {
    case .practice: "Daily practice"
    case .timed: "Five-minute sprint"
    case .openBook: "Open book"
    case .homework: "Homework"
    case .game2D: "2D challenge"
    case .game3D: "3D explorer"
    case .live: "Live quiz"
    case .collaborative: "Study together"
    }
  }
  public var detail: String {
    switch self {
    case .practice: "Build understanding at your own pace."
    case .timed: "A gentle challenge against the clock."
    case .openBook: "Follow the sources as you learn."
    case .homework: "Save your work and return later."
    case .game2D: "Catch the right idea."
    case .game3D: "Explore a system in three dimensions."
    case .live: "Answer together, compare your progress."
    case .collaborative: "Share ideas with your study group."
    }
  }
  public var symbol: String {
    switch self {
    case .timed: "timer"
    case .openBook: "book"
    case .homework: "tray"
    case .game2D, .game3D: "gamecontroller"
    case .live, .collaborative: "person.2"
    default: "leaf"
    }
  }
  public var config: QuizMode {
    QuizMode(
      isTimed: self == .timed, timeLimit: self == .timed ? 300 : nil, isOpenBook: self == .openBook,
      isLive: self == .live, isCollaborative: self == .collaborative,
      isGameBased: [.game2D, .game3D].contains(self),
      gameDimension: self == .game2D ? .twoD : self == .game3D ? .threeD : nil,
      allowsResume: ![.live, .collaborative].contains(self))
  }
}
public struct QuizMode: Sendable {
  public enum GameDimension: Sendable { case twoD, threeD }
  public let isTimed: Bool
  public let timeLimit: TimeInterval?
  public let isOpenBook: Bool
  public let isLive: Bool
  public let isCollaborative: Bool
  public let isGameBased: Bool
  public let gameDimension: GameDimension?
  public let allowsResume: Bool
}
public struct Evaluation: Codable, Sendable, Equatable {
  public var score: Double
  public var maxScore: Double
  public var missingConcepts: [String]
  public var feedback: String
  public var modelId: String
  public var latencyMs: Int
  public var status: String
  public var fraction: Double { maxScore > 0 ? score / maxScore : 0 }
}
public struct Attempt: Codable, Identifiable, Sendable {
  public var id = UUID().uuidString
  public let questionId: String
  public let answer: [String]
  public var result: Evaluation
  public var createdAt = Date()
  public var serverAccepted: Bool?
  public var elapsedSeconds: Double?
}
public struct SessionState: Codable, Identifiable, Sendable {
  public var id = UUID().uuidString
  public var owner: String
  public var mode: DeliveryMode
  public var questions: [Question]
  public var attempts: [Attempt] = []
  public var cursor = 0
  public var remaining: TimeInterval?
  public var savedAt = Date()
  public var dueAt: Date?
  public var draft: [String]?
  public var complete: Bool { cursor >= questions.count }
  public var current: Question? { complete ? nil : questions[cursor] }
  public var earned: Double { attempts.reduce(0) { $0 + $1.result.fraction } }
  // Progress is monotonic. An authoritative cloud attempt replaces the entire
  // local attempt, including its stable ID and original answer.
  func merging(_ other: SessionState, authoritative: Bool = false) -> SessionState {
    guard id == other.id, owner == other.owner, questions.map(\.id) == other.questions.map(\.id)
    else { return self }
    var copy = self
    for attempt in other.attempts {
      if let i = copy.attempts.firstIndex(where: { $0.questionId == attempt.questionId }) {
        if authoritative || (copy.attempts[i].serverAccepted != true && attempt.serverAccepted == true) || (copy.attempts[i].result.status == "pending_review" && attempt.result.status == "graded") {
          copy.attempts[i] = attempt
        }
      } else { copy.attempts.append(attempt) }
    }
    copy.cursor = max(cursor, other.cursor)
    if copy.cursor != cursor { copy.draft = nil }
    if let r = remaining, let o = other.remaining {
      let now = Date()
      copy.remaining = min(max(0, r - max(0, now.timeIntervalSince(savedAt))), max(0, o - max(0, now.timeIntervalSince(other.savedAt))))
      copy.savedAt = now
    }
    return copy
  }
  public init(owner: String, mode: DeliveryMode, questions: [Question]) {
    self.owner = owner
    self.mode = mode
    self.questions = questions
    self.remaining = mode.config.timeLimit
    self.dueAt =
      mode == .homework ? Calendar.current.date(byAdding: .day, value: 7, to: Date()) : nil
  }
}
public struct PendingSubmission: Codable, Identifiable, Sendable {
  public var id: String { attempt.id }
  public var owner: String
  public let sessionId: String
  public let mode: DeliveryMode
  public let questionIds: [String]
  public var attempt: Attempt
  public var retryCount = 0
  public var nextRetryAt = Date.distantPast
}
public enum QuizError: LocalizedError {
  case invalidAnswer, finished, expired, invalidSession
  public var errorDescription: String? {
    switch self {
    case .invalidAnswer: "Choose or enter an answer first."
    case .finished: "This session is complete."
    case .expired: "Time is up. Your saved answers are safe."
    case .invalidSession: "This session cannot be restored."
    }
  }
}
public enum Scoring {
  static func normalize(_ x: String) -> String {
    x.precomposedStringWithCompatibilityMapping.trimmingCharacters(in: .whitespacesAndNewlines)
      .lowercased().split(whereSeparator: \.isWhitespace).joined(separator: " ")
  }
  public static func evaluate(_ q: Question, answer: [String]) throws -> Evaluation {
    guard !answer.isEmpty, answer.count <= 50,
      answer.allSatisfy({
        !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && $0.count <= 6000
      })
    else { throw QuizError.invalidAnswer }
    let a = answer.map(normalize)
    let e = q.correct.map(normalize)
    if q.format.isOpen {
      let text = a.joined(separator: " ")
      let criteria = q.criteria ?? q.correct
      let missing = criteria.filter {
        !$0.split(separator: "|").contains(where: { text.contains(normalize(String($0))) })
      }
      let score = (5 * Double(criteria.count - missing.count) / Double(max(1, criteria.count)))
        .rounded()
      return Evaluation(
        score: score, maxScore: 5, missingConcepts: missing,
        feedback:
          "Saved for review. Compare your reasoning with the explanation; this keyword estimate is provisional.",
        modelId: "keyword-fallback", latencyMs: 0, status: "pending_review")
    }
    let correct: Bool
    switch q.format {
    case .numeric:
      if a.count == 1, let n = Double(a[0]), let target = Double(e.first ?? ""), n.isFinite {
        correct = abs(n - target) <= (q.tolerance ?? 0)
      } else {
        correct = false
      }
    case .multipleSelect: correct = Set(a).count == a.count && Set(a) == Set(e)
    case .fillBlank:
      correct =
        a.count == e.count
        && zip(a, e).allSatisfy { x, y in y.split(separator: "|").contains(Substring(x)) }
    default: correct = a == e
    }
    return Evaluation(
      score: correct ? 1 : 0, maxScore: 1, missingConcepts: [], feedback: q.explanation,
      modelId: "deterministic", latencyMs: 0, status: "graded")
  }
}
public actor QuizSession {
  private var state: SessionState
  private let clock = ContinuousClock()
  private var anchor: ContinuousClock.Instant
  public init(state: SessionState, now: Date = Date()) throws {
    guard !state.questions.isEmpty, Set(state.questions.map(\.id)).count == state.questions.count,
      (0...state.questions.count).contains(state.cursor)
    else { throw QuizError.invalidSession }
    self.state = state
    if let remaining = state.remaining {
      self.state.remaining = max(0, remaining - max(0, now.timeIntervalSince(state.savedAt)))
    }
    self.anchor = ContinuousClock().now
  }
  public func snapshot() -> SessionState {
    var s = state
    if let r = state.remaining {
      let d = anchor.duration(to: clock.now).components
      s.remaining = max(0, r - Double(d.seconds) - Double(d.attoseconds) / 1e18)
    }
    s.savedAt = Date()
    return s
  }
  public func submit(_ answer: [String]) throws -> Attempt {
    guard let q = state.current else { throw QuizError.finished }
    if let existing = state.attempts.first(where: { $0.questionId == q.id }) { return existing }
    if let r = snapshot().remaining, r <= 0 { throw QuizError.expired }
    var attempt = Attempt(
      questionId: q.id, answer: answer, result: try Scoring.evaluate(q, answer: answer))
    if let remaining = snapshot().remaining, let limit = state.mode.config.timeLimit { attempt.elapsedSeconds = max(0, limit - remaining) }
    state.attempts.append(attempt)
    return attempt
  }
  public func advance() throws {
    guard let q = state.current else { throw QuizError.finished }
    guard state.attempts.contains(where: { $0.questionId == q.id }) else {
      throw QuizError.invalidAnswer
    }
    state.cursor += 1
    state.draft = nil
  }
  public func applyReview(attemptId: String, result: Evaluation) {
    if let i = state.attempts.firstIndex(where: { $0.id == attemptId }) {
      state.attempts[i].result = result
    }
  }
  public func merge(_ remote: SessionState, preserveCurrentFeedback: Bool = false) {
    let current = snapshot()
    state = current.merging(remote, authoritative: true)
    if preserveCurrentFeedback, let question = current.current,
      current.attempts.contains(where: { $0.questionId == question.id }) {
      state.cursor = current.cursor
      state.draft = nil
    }
    anchor = clock.now
  }
  public func setDraft(_ answer: [String]) { if state.current != nil { state.draft = answer } }
  public func finish() { state.cursor = state.questions.count }
}

public struct PublishedQuiz: Codable, Identifiable, Sendable {
  public let id: String
  public let title: String
  public let topic: String
  public let questionIds: [String]
  public let createdAt: String
}
