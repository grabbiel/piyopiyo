import AVFoundation
import Foundation
import Network
import SwiftUI

@MainActor final class SoundPlayer {
  static let shared = SoundPlayer()
  private var music: AVAudioPlayer?
  private var effect: AVAudioPlayer?
  func play(_ name: String, loop: Bool = false) throws {
    guard let url = Bundle.module.url(forResource: name, withExtension: "wav") else {
      throw APIError(message: "Audio asset unavailable.")
    }
    #if os(iOS)
      try AVAudioSession.sharedInstance().setCategory(.ambient)
    #endif
    let player = try AVAudioPlayer(contentsOf: url)
    player.volume = loop ? 0.25 : 0.6
    player.numberOfLoops = loop ? -1 : 0
    player.prepareToPlay()
    player.play()
    if loop { music = player } else { effect = player }
  }
  func stop() {
    music?.stop()
    effect?.stop()
  }
}
@MainActor final class AppModel: ObservableObject {
  @Published var questions: [Question] = []
  @Published var publishedQuizzes: [PublishedQuiz] = []
  @Published var history: [SessionState] = []
  @Published var state: SessionState?
  @Published var feedback: Evaluation?
  @Published var error: String?
  @Published var busy = false
  @Published var online = true
  @Published var queueCount = 0
  @Published var syncStatus = "Saved on this device"
  @Published var selectedPage = "Learn"
  @Published var showQuiz = false
  @Published var offlinePractice = UserDefaults.standard.bool(forKey: "offlinePractice") {
    didSet {
      UserDefaults.standard.set(offlinePractice, forKey: "offlinePractice")
      if !offlinePractice { Task { await sync() } }
    }
  }
  let auth = AuthService()
  let live = LiveClient()
  private(set) var store: LocalStore?
  private var engine: QuizSession?
  private var syncing = false
  private var accountEpoch = UUID()
  @Published var deletingAccount = false
  @Published var aiFeedbackEnabled = false
  func setAIFeedback(_ enabled: Bool) {
    aiFeedbackEnabled = enabled
    UserDefaults.standard.set(enabled, forKey: "aiFeedback." + owner)
    if enabled { Task { await sync() } }
  }
  private let monitor = NWPathMonitor()
  private let api = APIClient()
  private var lastPull = Date.distantPast
  private var lastContentPull = Date.distantPast
  var owner: String { auth.tokens?.subject ?? "guest" }
  var topics: [String] { Array(Set(questions.map(\.topic))).sorted() }
  var attempts: [Attempt] { history.flatMap(\.attempts) }
  var todayCount: Int { attempts.filter { Calendar.current.isDateInToday($0.createdAt) }.count }
  var accuracy: Int {
    let graded = attempts.filter { $0.result.status != "pending_review" }
    return graded.isEmpty
      ? 0
      : Int(
        (graded.reduce(0) { $0 + $1.result.fraction } / Double(graded.count) * 100).rounded())
  }
  nonisolated static func missedQuestionIds(_ attempts: [Attempt]) -> Set<String> {
    let latest = Dictionary(
      grouping: attempts.filter { $0.result.status != "pending_review" }, by: \.questionId
    ).compactMapValues { $0.max { $0.createdAt < $1.createdAt } }
    return Set(latest.values.filter { $0.result.fraction < 1 }.map(\.questionId))
  }
  nonisolated static func balancedSample(_ pool: [Question], count: Int) -> [Question] {
    var buckets = Dictionary(grouping: pool) { "\($0.topic)/\($0.format.rawValue)" }
      .values.map { $0.shuffled() }.shuffled()
    var chosen: [Question] = []
    while chosen.count < count, !buckets.isEmpty {
      for i in buckets.indices.reversed() where chosen.count < count {
        chosen.append(buckets[i].removeLast())
        if buckets[i].isEmpty { buckets.remove(at: i) }
      }
    }
    return chosen.shuffled()
  }
  var streak: Int {
    var count = 0
    var day = Calendar.current.startOfDay(for: Date())
    let dates = Set(attempts.map { Calendar.current.startOfDay(for: $0.createdAt) })
    if !dates.contains(day) { day = Calendar.current.date(byAdding: .day, value: -1, to: day)! }
    while dates.contains(day) {
      count += 1
      day = Calendar.current.date(byAdding: .day, value: -1, to: day)!
    }
    return count
  }
  init() {
    do {
      let directory = FileManager.default.urls(
        for: .applicationSupportDirectory, in: .userDomainMask)[0].appendingPathComponent(
          "PiyoPiyo", isDirectory: true)
      try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
      store = try LocalStore(path: directory.appendingPathComponent("learning.sqlite").path)
    } catch { self.error = error.localizedDescription }
    monitor.pathUpdateHandler = { [weak self] path in
      Task { @MainActor in
        self?.online = path.status == .satisfied
        if path.status == .satisfied { await self?.sync() }
      }
    }
    monitor.start(queue: DispatchQueue(label: "piyopiyo.connectivity"))
  }
  deinit { monitor.cancel() }
  func loadBank() async {
    do {
      let cached = try await store?.list([Question].self, kind: "bank").first
      let bank: [Question]
      if let cached, !cached.isEmpty {
        bank = cached
      } else {
        bank = try await Task.detached(priority: .userInitiated) { try Question.bundled() }.value
      }
      if questions.isEmpty { questions = bank }
    } catch { self.error = error.localizedDescription }
  }
  func load() async {
    let epoch = accountEpoch
    let currentOwner = owner
    do {
      guard let store else { return }
      let sessions = try await store.list(SessionState.self, kind: "session")
      let pending = try await store.list(PendingSubmission.self, kind: "queue")
      guard epoch == accountEpoch, currentOwner == owner else { return }
      aiFeedbackEnabled = UserDefaults.standard.bool(forKey: "aiFeedback." + currentOwner)
      publishedQuizzes = try await store.list([PublishedQuiz].self, kind: "quizzes").first ?? []
      history = sessions.filter { $0.owner == currentOwner }.sorted { $0.savedAt > $1.savedAt }
      queueCount = pending.filter { $0.owner == currentOwner }.count
    } catch { if epoch == accountEpoch { self.error = error.localizedDescription } }
  }
  func log(_ event: String) {
    let entry = "\(Date().ISO8601Format()) \(event) queue=\(queueCount)"
    Task { try? await store?.appendDiagnostic(entry) }
  }
  func start(
    mode: DeliveryMode = .practice, topic: String? = nil, format: QuestionFormat? = nil,
    review: Bool = false, exact: [Question]? = nil
  ) async {
    guard !busy else { return }
    busy = true
    defer { busy = false }
    do {
      if let engine, let store { try await store.save(engine.snapshot()) }
      let missed = Self.missedQuestionIds(attempts)
      var pool =
        exact
        ?? questions.filter {
          (topic == nil || $0.topic == topic) && (format == nil || $0.format == format)
            && (!review || missed.contains($0.id))
        }
      if mode == .game2D { pool = pool.filter { $0.format == .game2D } }
      if mode == .game3D { pool = pool.filter { $0.format == .game3D } }
      if mode == .homework { pool = pool.filter { $0.format.isOpen } }
      guard !pool.isEmpty else {
        throw APIError(
          message: review
            ? "No missed questions yet. Try a practice session first."
            : "No questions match this selection.")
      }
      let chosen = exact == nil ? Self.balancedSample(pool, count: 10) : Array(pool.shuffled().prefix(10))
      let fresh = SessionState(owner: owner, mode: mode, questions: chosen)
      engine = try QuizSession(state: fresh)
      state = fresh
      feedback = nil
      showQuiz = true
      try await store?.save(fresh)
      log("session_started")
      await load()
    } catch { self.error = error.localizedDescription }
  }
  func resume(_ saved: SessionState) async {
    do {
      engine = try QuizSession(state: saved)
      state = await engine?.snapshot()
      feedback = saved.attempts.first { $0.questionId == saved.current?.id }?.result
      showQuiz = true
    } catch { self.error = error.localizedDescription }
  }
  func submit(_ answer: [String]) async {
    guard !busy, let engine, let store else { return }
    busy = true
    defer { busy = false }
    do {
      let attempt = try await engine.submit(answer)
      let snapshot = await engine.snapshot()
      let pending = PendingSubmission(
        owner: snapshot.owner, sessionId: snapshot.id, mode: snapshot.mode,
        questionIds: snapshot.questions.map(\.id), attempt: attempt)
      try await store.commit(state: snapshot, submission: pending)
      state = snapshot
      feedback = attempt.result
      log("answer_saved")
      await load()
      Task { await sync() }
      if UserDefaults.standard.bool(forKey: "soundEnabled") {
        try? SoundPlayer.shared.play(attempt.result.fraction == 1 ? "celebration" : "reflection")
      }
    } catch { self.error = error.localizedDescription }
  }
  func next() async {
    guard let engine else { return }
    do {
      try await engine.advance()
      state = await engine.snapshot()
      feedback = state?.attempts.first { $0.questionId == state?.current?.id }?.result
      if let state {
        try await store?.save(state)
        if state.complete { log("session_completed") }
      }
      await load()
    } catch { self.error = error.localizedDescription }
  }
  func saveDraft(_ answer: [String]) async {
    guard let engine, feedback == nil else { return }
    await engine.setDraft(answer)
    try? await Task.sleep(for: .milliseconds(400))
    if !Task.isCancelled { await persist() }
  }
  func persist() async {
    guard !deletingAccount, let engine else { return }
    do {
      let value = await engine.snapshot()
      try await store?.save(value)
      state = value
    } catch { self.error = error.localizedDescription }
  }
  func tick() async {
    guard let engine, showQuiz else { return }
    state = await engine.snapshot()
    if let remaining = state?.remaining, remaining <= 0, state?.complete == false {
      await engine.finish()
      feedback = nil
      await persist()
      await load()
    }
  }
  func signIn() async {
    guard !busy else { return }
    accountEpoch = UUID()
    lastPull = .distantPast
    busy = true
    defer { busy = false }
    do {
      await persist()
      try await auth.signIn()
      guard let subject = auth.tokens?.subject, let store else { return }
      try await store.claimGuest(to: subject)
      if var state, self.state?.owner == "guest" {
        state.owner = subject
        self.state = state
        engine = try QuizSession(state: state)
      }
      await load()
      await sync()
    } catch { self.error = error.localizedDescription }
  }
  func signOut() async {
    guard !deletingAccount else { return }
    accountEpoch = UUID()
    lastPull = .distantPast
    await persist()
    auth.signOut()
    live.close()
    state = nil
    engine = nil
    feedback = nil
    showQuiz = false
    await load()
  }
  func sync() async {
    guard !syncing, !deletingAccount, online, !offlinePractice, auth.tokens != nil, !questions.isEmpty, let store else { return }
    let epoch = accountEpoch
    syncing = true
    defer { syncing = false }
    var issue: String?
    do {
      let token = try await auth.validTokens()
      guard epoch == accountEpoch, let subject = token.subject else { return }
      // Content refresh must never prevent saved answers from reaching the server.
      if Date().timeIntervalSince(lastContentPull) > 3600 {
        do {
          let data = try await api.request("questions", token: token.accessToken)
          guard epoch == accountEpoch else { return }
          let fetched = try JSONDecoder().decode([Question].self, from: data)
          guard !fetched.isEmpty, Set(fetched.map(\.id)).count == fetched.count else { throw APIError(message: "Question update could not be verified.") }
          try await store.saveQuestions(fetched)
          questions = fetched
          let quizData = try await api.request("quizzes", token: token.accessToken)
          guard epoch == accountEpoch else { return }
          let quizzes = try JSONDecoder().decode([PublishedQuiz].self, from: quizData)
          let available = Set(fetched.map(\.id))
          publishedQuizzes = quizzes.filter { !$0.questionIds.isEmpty && $0.questionIds.allSatisfy(available.contains) }
          try await store.saveQuizzes(publishedQuizzes)
          lastContentPull = Date()
        } catch { issue = "Using saved questions. " + error.localizedDescription }
      }
      let items = try await store.list(PendingSubmission.self, kind: "queue").filter { $0.owner == subject && $0.nextRetryAt <= Date() }
      if !items.isEmpty { syncStatus = "Syncing saved answers…" }
      for var item in items {
        guard epoch == accountEpoch, auth.tokens?.subject == subject, !offlinePractice else { return }
        if item.attempt.result.status == "pending_review" && !aiFeedbackEnabled { issue = "Written answers stay on this device until you enable AI feedback in Settings."; continue }
        do {
          let currentToken = try await auth.validTokens()
          let result = try await api.submit(item, token: currentToken.accessToken, allowAI: aiFeedbackEnabled)
          guard epoch == accountEpoch else { return }
          try await store.reconcile(item, result: result)
          if state?.id == item.sessionId, let active = engine {
            await active.applyReview(attemptId: item.id, result: result)
            guard epoch == accountEpoch else { return }
            if state?.id == item.sessionId {
              state = await active.snapshot()
              if state?.current?.id == item.attempt.questionId { feedback = result }
            }
          }
          if result.status == "pending_review" {
            item.retryCount += 1
            item.nextRetryAt = Date().addingTimeInterval(min(3600, pow(2, Double(min(item.retryCount, 8))) * 30))
            try await store.save(item)
          }
        } catch {
          guard epoch == accountEpoch else { return }
          item.retryCount += 1
          item.nextRetryAt = Date().addingTimeInterval(min(3600, pow(2, Double(min(item.retryCount, 8))) * 15))
          try await store.save(item)
          issue = error.localizedDescription
          if (error as? APIError)?.requiresSignIn == true { break }
          // One rejected answer must not starve unrelated saved submissions.
        }
      }
      guard epoch == accountEpoch else { return }
      if Date().timeIntervalSince(lastPull) > 300 || !items.isEmpty {
        let currentToken = try await auth.validTokens()
        let remote = try await api.progress(token: currentToken.accessToken, owner: subject, questions: questions)
        for session in remote {
          guard epoch == accountEpoch else { return }
          let merged = try await store.mergeCloud(session)
          if state?.id == session.id, let active = engine {
            await active.merge(merged, preserveCurrentFeedback: feedback != nil)
            guard epoch == accountEpoch else { return }
            state = await active.snapshot()
            feedback = state?.attempts.first { $0.questionId == state?.current?.id }?.result
          }
        }
        lastPull = Date()
      }
      guard epoch == accountEpoch else { return }
      await load()
      syncStatus = issue ?? (queueCount == 0 ? "All answers synced" : "Saved answers are waiting for review or retry")
    } catch { if epoch == accountEpoch { syncStatus = error.localizedDescription } }
  }
  func deleteAccount() async {
    guard !deletingAccount, auth.tokens != nil else { return }
    accountEpoch = UUID()
    deletingAccount = true
    busy = true
    live.close()
    defer { deletingAccount = false; busy = false }
    do {
      let token = try await auth.validTokens()
      guard let subject = token.subject else { throw APIError(message: "Sign in to delete your account.") }
      let preparation = try await api.request("account/deletion-authorization", method: "POST", token: token.accessToken)
      struct DeletionAuthorization: Decodable { let required: Bool; let url: URL?; let state: String? }
      let authorization = try JSONDecoder().decode(DeletionAuthorization.self, from: preparation)
      if authorization.required {
        guard let url = authorization.url, let state = authorization.state else { throw APIError(message: "Apple deletion authorization is unavailable.") }
        syncStatus = "Confirm your Apple account to revoke PiyoPiyo’s access."
        try await auth.authorizeAppleDeletion(url: url, expectedState: state)
      }
      syncStatus = "Deleting your account and saved cloud data…"
      for _ in 0..<300 {
        let current = try await auth.validTokens()
        let data = try await api.request("account", method: "DELETE", token: current.accessToken)
        let response = try JSONSerialization.jsonObject(with: data) as? [String: String]
        if response?["status"] == "deleted" {
          try await store?.erase(owner: subject)
          auth.signOut()
          state = nil; engine = nil; feedback = nil; showQuiz = false
          lastPull = .distantPast
          await load()
          syncStatus = "Your account and saved progress have been deleted."
          return
        }
        try await Task.sleep(for: .milliseconds(400))
      }
      throw APIError(message: "Deletion is still in progress. Use Delete account again to finish.")
    } catch {
      self.error = "Deletion has not finished. Reconnect and use Delete account again. " + error.localizedDescription
    }
  }
  func eraseGuestProgress() async {
    guard !busy else { return }
    accountEpoch = UUID()
    let previousOwner = owner
    do {
      state = nil; engine = nil; feedback = nil; showQuiz = false
      try await store?.erase(owner: previousOwner)
      auth.signOut()
      live.close()
      lastPull = .distantPast
      await load()
    } catch { self.error = error.localizedDescription }
  }
  func diagnostics() async {
    guard UserDefaults.standard.bool(forKey: "diagnosticsEnabled") else { return }
    do {
      let t = try await auth.validTokens()
      let body = try JSONSerialization.data(withJSONObject: [
        "optedIn": true, "sessions": history.count, "renderFailures": 0, "queueLength": queueCount,
      ])
      _ = try await api.request("diagnostics", method: "POST", token: t.accessToken, body: body)
      syncStatus = "Aggregate counts sent"
    } catch { self.error = error.localizedDescription }
  }
}
