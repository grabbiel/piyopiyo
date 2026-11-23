import XCTest

@testable import PiyoPiyoCore

final class CoreTests: XCTestCase {
  func testAllFormatsAndInvalidResponses() throws {
    let questions = try Question.bundled()
    XCTAssertEqual(Set(questions.map(\.format)), Set(QuestionFormat.allCases))
    for format in QuestionFormat.allCases {
      let q = try XCTUnwrap(questions.first { $0.format == format })
      let answer = q.correct.map { String($0.split(separator: "|").first!) }
      let result = try Scoring.evaluate(q, answer: answer)
      XCTAssertEqual(result.fraction, 1, "\(format)")
      XCTAssertEqual(result.status, format.isOpen ? "pending_review" : "graded")
      if !format.isOpen {
        XCTAssertEqual(try Scoring.evaluate(q, answer: ["definitely incorrect"]).fraction, 0)
      }
      XCTAssertThrowsError(try Scoring.evaluate(q, answer: []))
      XCTAssertThrowsError(try Scoring.evaluate(q, answer: ["  "]))
    }
  }
  func testSetsNumbersAndUnicode() throws {
    let bank = try Question.bundled()
    let set = bank.first { $0.format == .multipleSelect }!
    XCTAssertEqual(try Scoring.evaluate(set, answer: set.correct.reversed()).fraction, 1)
    XCTAssertEqual(try Scoring.evaluate(set, answer: set.correct + [set.correct[0]]).fraction, 0)
    let number = bank.first { $0.format == .numeric }!
    for invalid in ["nan", "inf", "-inf", "4.1"] {
      XCTAssertEqual(try Scoring.evaluate(number, answer: [invalid]).fraction, 0)
    }
    XCTAssertEqual(try Scoring.evaluate(number, answer: ["４"]).fraction, 1)
    let fill = bank.first { $0.format == .fillBlank }!
    XCTAssertEqual(try Scoring.evaluate(fill, answer: [" STACK \n"]).fraction, 1)
  }
  func testGameSpecIsOptional() throws {
    let base =
      #"{"id":"g","format":"game_3d","topic":"t","prompt":"p","options":["A","B"],"correct":["A"],"explanation":"e","sourceId":"s","sourceURL":"","difficulty":"easy""#
    let plain = try JSONDecoder().decode(Question.self, from: Data((base + "}").utf8))
    XCTAssertNil(plain.game)
    let themed = try JSONDecoder().decode(
      Question.self,
      from: Data(
        (base
          + #","game":{"template":"system_architecture","params":{"roles":{"A":"cylinder","B":"box"},"orbit":true,"lanes":3}}}"#)
          .utf8))
    XCTAssertEqual(
      themed.game,
      GameSpec(template: "system_architecture", params: .init(roles: ["A": "cylinder", "B": "box"])))
    let bank = try Question.bundled()
    XCTAssertEqual(bank.first { $0.id == "falling-complexity" }?.game?.template, "falling_blocks")
    XCTAssertEqual(
      bank.first { $0.id == "architecture-3d" }?.game?.params?.roles?["Database"], "cylinder")
  }
  func testTimerResumeDoesNotResetOrGainTime() async throws {
    let q = try Question.bundled()[0]
    var state = SessionState(owner: "test", mode: .timed, questions: [q])
    state.remaining = 20
    state.savedAt = Date(timeIntervalSince1970: 1000)
    let session = try QuizSession(state: state, now: Date(timeIntervalSince1970: 1010))
    let restored = await session.snapshot()
    XCTAssertLessThanOrEqual(restored.remaining!, 10)
    XCTAssertGreaterThan(restored.remaining!, 9)
    let backward = try QuizSession(state: state, now: Date(timeIntervalSince1970: 990))
    let snapshot = await backward.snapshot()
    XCTAssertLessThanOrEqual(snapshot.remaining!, 20)
    let expired = try QuizSession(state: state, now: Date(timeIntervalSince1970: 1030))
    do {
      _ = try await expired.submit(q.correct)
      XCTFail("Accepted expired answer")
    } catch { XCTAssertTrue(error is QuizError) }
  }
  func testSessionTransitionsAndDrafts() async throws {
    let q = try Question.bundled()[0]
    let session = try QuizSession(
      state: SessionState(owner: "test", mode: .homework, questions: [q]))
    do {
      try await session.advance()
      XCTFail("Skipped unanswered question")
    } catch {}
    await session.setDraft(["unfinished reasoning"])
    let draft = await session.snapshot()
    XCTAssertEqual(draft.draft, ["unfinished reasoning"])
    let first = try await session.submit(q.correct)
    let repeated = try await session.submit(["different"])
    XCTAssertEqual(first.id, repeated.id)
    try await session.advance()
    let completed = await session.snapshot()
    XCTAssertTrue(completed.complete)
    XCTAssertNil(completed.draft)
    XCTAssertEqual(completed.attempts.count, 1)
    XCTAssertNotNil(completed.dueAt)
    XCTAssertThrowsError(
      try QuizSession(state: SessionState(owner: "test", mode: .practice, questions: [])))
  }
  func testOfflineSessionReopensAndReconcilesWithoutLoss() async throws {
    let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: dir) }
    let path = dir.appendingPathComponent("test.sqlite").path
    let store = try LocalStore(path: path)
    let bank = Array(try Question.bundled().prefix(18))
    let engine = try QuizSession(
      state: SessionState(owner: "guest", mode: .practice, questions: bank))
    for q in bank {
      let attempt = try await engine.submit(
        q.correct.map { String($0.split(separator: "|").first!) })
      let state = await engine.snapshot()
      let queued = PendingSubmission(
        owner: state.owner, sessionId: state.id, mode: state.mode, questionIds: bank.map(\.id),
        attempt: attempt)
      try await store.commit(state: state, submission: queued)
      try await engine.advance()
    }
    let final = await engine.snapshot()
    try await store.save(final)
    let reopened = try LocalStore(path: path)
    var sessions = try await reopened.list(SessionState.self, kind: "session")
    var queue = try await reopened.list(PendingSubmission.self, kind: "queue")
    XCTAssertEqual(sessions.count, 1)
    XCTAssertTrue(sessions[0].complete)
    XCTAssertEqual(sessions[0].attempts.count, 18)
    XCTAssertEqual(queue.count, 18)
    try await reopened.claimGuest(to: "learner-a")
    queue = try await reopened.list(PendingSubmission.self, kind: "queue")
    XCTAssertTrue(queue.allSatisfy { $0.owner == "learner-a" })
    for item in queue {
      var result = item.attempt.result
      result.status = "graded"
      result.modelId = "test-server"
      try await reopened.reconcile(item, result: result)
    }
    sessions = try await reopened.list(SessionState.self, kind: "session")
    queue = try await reopened.list(PendingSubmission.self, kind: "queue")
    XCTAssertTrue(queue.isEmpty)
    XCTAssertEqual(sessions[0].attempts.count, 18)
    XCTAssertTrue(sessions[0].attempts.allSatisfy { $0.result.status == "graded" })
    var stale = final
    stale.owner = "learner-a"
    try await reopened.save(stale)
    let preserved = try await reopened.list(SessionState.self, kind: "session")
    XCTAssertTrue(preserved[0].attempts.allSatisfy { $0.result.status == "graded" })
  }
  func testPendingReviewStaysQueuedAndDiagnosticsBounded() async throws {
    let store = try LocalStore(path: ":memory:")
    let q = try Question.bundled().first { $0.format.isOpen }!
    let engine = try QuizSession(state: SessionState(owner: "a", mode: .homework, questions: [q]))
    let attempt = try await engine.submit(["some reasoning"])
    let state = await engine.snapshot()
    let item = PendingSubmission(
      owner: "a", sessionId: state.id, mode: .homework, questionIds: [q.id], attempt: attempt)
    try await store.commit(state: state, submission: item)
    try await store.reconcile(item, result: attempt.result)
    let queue = try await store.list(PendingSubmission.self, kind: "queue")
    XCTAssertEqual(queue.count, 1)
    for i in 0..<105 { try await store.appendDiagnostic("event-\(i)") }
    let log = try await store.list([String].self, kind: "diagnostics")
    XCTAssertEqual(log.first?.count, 100)
    XCTAssertEqual(log.first?.first, "event-5")
  }
  func testAllDeliveryModesConfigured() {
    XCTAssertEqual(DeliveryMode.allCases.count, 8)
    XCTAssertEqual(DeliveryMode.timed.config.timeLimit, 300)
    XCTAssertTrue(DeliveryMode.openBook.config.isOpenBook)
    XCTAssertFalse(DeliveryMode.live.config.allowsResume)
    XCTAssertTrue(DeliveryMode.collaborative.config.isCollaborative)
    XCTAssertNotNil(DeliveryMode.game3D.config.gameDimension)
  }
}
final class StubProtocol: URLProtocol {
  static var respond: ((URLRequest) throws -> (Int, Data))!
  override class func canInit(with request: URLRequest) -> Bool { true }
  override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
  override func startLoading() {
    do {
      let (status, data) = try Self.respond(request)
      client?.urlProtocol(
        self,
        didReceive: HTTPURLResponse(
          url: request.url!, statusCode: status, httpVersion: nil, headerFields: nil)!,
        cacheStoragePolicy: .notAllowed)
      client?.urlProtocol(self, didLoad: data)
      client?.urlProtocolDidFinishLoading(self)
    } catch { client?.urlProtocol(self, didFailWithError: error) }
  }
  override func stopLoading() {}
}
final class NetworkingTests: XCTestCase {
  func client() -> APIClient {
    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [StubProtocol.self]
    return APIClient(
      baseURL: URL(string: "https://example.invalid")!,
      urlSession: URLSession(configuration: config))
  }
  func testSubmissionUsesStableIDsAndServerEvaluation() async throws {
    let q = try Question.bundled()[0]
    let attempt = Attempt(
      questionId: q.id, answer: q.correct, result: try Scoring.evaluate(q, answer: q.correct))
    let item = PendingSubmission(
      owner: "owner", sessionId: "session-1", mode: .practice, questionIds: [q.id], attempt: attempt
    )
    var paths: [String] = []
    StubProtocol.respond = { request in
      XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer test-token")
      XCTAssertEqual(request.httpMethod, "POST")
      paths.append(request.url!.path)
      return (200, try JSONEncoder().encode(attempt.result))
    }
    let result = try await client().submit(item, token: "test-token")
    XCTAssertEqual(result, attempt.result)
    XCTAssertEqual(paths, ["/quiz", "/quiz/session-1/attempts"])
  }
  func testFailurePreservesQueueForRetry() async throws {
    let q = try Question.bundled()[0]
    let state = SessionState(owner: "owner", mode: .practice, questions: [q])
    let item = PendingSubmission(
      owner: "owner", sessionId: state.id, mode: .practice, questionIds: [q.id],
      attempt: Attempt(
        questionId: q.id, answer: q.correct, result: try Scoring.evaluate(q, answer: q.correct)))
    let store = try LocalStore(path: ":memory:")
    try await store.save(item)
    StubProtocol.respond = { _ in throw URLError(.notConnectedToInternet) }
    do {
      _ = try await client().submit(item, token: "token")
      XCTFail("Offline request succeeded")
    } catch {}
    let remaining = try await store.list(PendingSubmission.self, kind: "queue")
    XCTAssertEqual(remaining.first?.id, item.id)
  }
  func testCloudRestorationPreservesDatesAndDoesNotSubtractTimeTwice() async throws {
    let bank = Array(try Question.bundled().prefix(2))
    let result = try Scoring.evaluate(bank[0], answer: bank[0].correct)
    let resultObject = try JSONSerialization.jsonObject(with: JSONEncoder().encode(result))
    let payload: [String: Any] = [
      "items": [
        [
          "SK": "SESSION#cloud", "id": "cloud", "mode": "timed", "questionIds": bank.map(\.id),
          "deadline": Date().addingTimeInterval(90).timeIntervalSince1970 * 1000,
        ],
        [
          "SK": "SESSION#cloud#ATTEMPT#" + bank[0].id, "attemptId": "a1", "answer": bank[0].correct,
          "result": resultObject, "createdAt": "2026-11-01T12:00:00.123Z",
        ],
      ], "nextCursor": NSNull(),
    ]
    StubProtocol.respond = { _ in (200, try JSONSerialization.data(withJSONObject: payload)) }
    let restored = try await client().progress(token: "test", owner: "learner", questions: bank)
    let state = try XCTUnwrap(restored.first)
    XCTAssertEqual(state.cursor, 1)
    XCTAssertEqual(
      Calendar(identifier: .gregorian).component(.day, from: state.attempts[0].createdAt), 1)
    let engine = try QuizSession(state: state)
    let resumed = await engine.snapshot()
    XCTAssertGreaterThan(resumed.remaining!, 85)
  }
  func testProgressPaginationPreservesQuery() async throws {
    var calls = 0
    StubProtocol.respond = { request in
      calls += 1
      if calls == 1 { return (200, Data("{\"items\":[],\"nextCursor\":\"abc_123\"}".utf8)) }
      XCTAssertEqual(request.url?.query, "cursor=abc_123")
      return (200, Data("{\"items\":[],\"nextCursor\":null}".utf8))
    }
    let result = try await client().progress(token: "test", owner: "a", questions: [])
    XCTAssertTrue(result.isEmpty)
    XCTAssertEqual(calls, 2)
  }
}

final class ReleaseRegressionTests: XCTestCase {
  func testSyncKeepsFeedbackVisibleUntilLearnerContinues() async throws {
    let questions = Array(try Question.bundled().prefix(2))
    let engine = try QuizSession(state: SessionState(owner: "a", mode: .practice, questions: questions))
    _ = try await engine.submit(questions[0].correct)
    var remote = await engine.snapshot()
    remote.cursor = 1
    await engine.merge(remote, preserveCurrentFeedback: true)
    let reviewing = await engine.snapshot()
    XCTAssertEqual(reviewing.current?.id, questions[0].id)
    XCTAssertEqual(reviewing.attempts.count, 1)
    try await engine.advance()
    let continued = await engine.snapshot()
    XCTAssertEqual(continued.current?.id, questions[1].id)
  }

  func testSameSessionIDsStayIsolatedBetweenAccounts() async throws {
    let store = try LocalStore(path: ":memory:")
    let q = try Question.bundled()[0]
    var a = SessionState(owner: "a", mode: .practice, questions: [q])
    var b = SessionState(owner: "b", mode: .practice, questions: [q])
    a.id = "shared-id"; b.id = a.id
    try await store.save(a); try await store.save(b)
    let before = try await store.list(SessionState.self, kind: "session")
    XCTAssertEqual(Set(before.map(\.owner)), ["a", "b"])
    try await store.erase(owner: "a")
    let after = try await store.list(SessionState.self, kind: "session")
    XCTAssertEqual(after.map(\.owner), ["b"])
  }
  func testCloudAttemptsSurviveStaleSnapshotsAndUpdateActiveSession() async throws {
    let store = try LocalStore(path: ":memory:")
    let questions = Array(try Question.bundled().prefix(2))
    let local = SessionState(owner: "a", mode: .practice, questions: questions)
    let engine = try QuizSession(state: local)
    try await store.save(local)
    var remote = local
    var attempt = Attempt(questionId: questions[0].id, answer: questions[0].correct, result: try Scoring.evaluate(questions[0], answer: questions[0].correct))
    attempt.serverAccepted = true
    remote.attempts = [attempt]; remote.cursor = 1
    let merged = try await store.mergeCloud(remote)
    await engine.merge(merged)
    try await store.save(local)
    let persisted = try await store.list(SessionState.self, kind: "session")
    XCTAssertEqual(persisted[0].attempts.first?.id, attempt.id)
    XCTAssertEqual(persisted[0].cursor, 1)
    let active = await engine.snapshot()
    XCTAssertEqual(active.current?.id, questions[1].id)
    XCTAssertEqual(active.attempts.count, 1)
  }
  func testCloudCanonicalAnswerReplacesConflictingOfflineAnswerAndQueue() async throws {
    let store = try LocalStore(path: ":memory:")
    let q = try Question.bundled()[0]
    var local = SessionState(owner: "a", mode: .practice, questions: [q])
    let wrong = Attempt(questionId: q.id, answer: ["wrong"], result: try Scoring.evaluate(q, answer: ["wrong"]))
    local.attempts = [wrong]
    let queued = PendingSubmission(owner: "a", sessionId: local.id, mode: .practice, questionIds: [q.id], attempt: wrong)
    try await store.commit(state: local, submission: queued)
    var remote = local
    var canonical = Attempt(questionId: q.id, answer: q.correct, result: try Scoring.evaluate(q, answer: q.correct))
    canonical.serverAccepted = true
    remote.attempts = [canonical]
    _ = try await store.mergeCloud(remote)
    try await store.save(local)
    let result = try await store.list(SessionState.self, kind: "session")
    let queue = try await store.list(PendingSubmission.self, kind: "queue")
    XCTAssertEqual(result[0].attempts[0].id, canonical.id)
    XCTAssertEqual(result[0].attempts[0].answer, q.correct)
    XCTAssertTrue(queue.isEmpty)
  }
  @MainActor func testOAuthFormEscapesPlusAndRefreshCoalesces() async throws {
    XCTAssertEqual(String(data: AuthService.formBody(["token":"a+b/c=" ]), encoding: .utf8), "token=a%2Bb%2Fc%3D")
    let id = "header." + Data("{\"sub\":\"learner\"}".utf8).base64URL + ".signature"
    let tokens = AuthTokens(accessToken: "old", idToken: id, refreshToken: "refresh+token", expiresAt: .distantPast)
    let config = URLSessionConfiguration.ephemeral; config.protocolClasses = [StubProtocol.self]
    var calls = 0
    StubProtocol.respond = { request in
      calls += 1
      Thread.sleep(forTimeInterval: 0.05)
      return (200, try JSONSerialization.data(withJSONObject: ["access_token":"new", "id_token":id, "expires_in":600]))
    }
    let auth = AuthService(urlSession: URLSession(configuration: config), storedTokens: tokens, useKeychain: false)
    async let first = auth.validTokens()
    async let second = auth.validTokens()
    let results = try await [first, second]
    XCTAssertEqual(calls, 1)
    XCTAssertEqual(results.map(\.accessToken), ["new", "new"])
    XCTAssertEqual(auth.tokens?.refreshToken, "refresh+token")
  }
  @MainActor func testSignOutDuringRefreshCannotRestoreCredentials() async throws {
    let id = "h." + Data("{\"sub\":\"learner\"}".utf8).base64URL + ".s"
    let config = URLSessionConfiguration.ephemeral; config.protocolClasses = [StubProtocol.self]
    StubProtocol.respond = { request in
      if request.url?.path == "/oauth2/token" { Thread.sleep(forTimeInterval: 0.1) }
      return (200, try JSONSerialization.data(withJSONObject: ["access_token":"new", "id_token":id, "expires_in":600]))
    }
    let auth = AuthService(urlSession: URLSession(configuration: config), storedTokens: AuthTokens(accessToken: "old", idToken: id, refreshToken: "r", expiresAt: .distantPast), useKeychain: false)
    let task = Task { try await auth.validTokens() }
    try await Task.sleep(for: .milliseconds(15))
    auth.signOut()
    do { _ = try await task.value; XCTFail("Refresh survived sign-out") } catch {}
    XCTAssertNil(auth.tokens)
  }
}
