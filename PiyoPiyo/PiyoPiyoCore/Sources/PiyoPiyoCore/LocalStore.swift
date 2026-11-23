import CSQLite
import Foundation

public struct StoreError: LocalizedError {
  public let message: String
  public var errorDescription: String? { message }
}
public actor LocalStore {
  private var database: OpaquePointer?
  private let encoder = JSONEncoder(), decoder = JSONDecoder()
  public init(path: String) throws {
    guard
      sqlite3_open_v2(
        path, &database, SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX, nil)
        == SQLITE_OK
    else { throw StoreError(message: "Unable to open the local learning database.") }
    sqlite3_busy_timeout(database, 5000)
    guard
      sqlite3_exec(
        database,
        "PRAGMA journal_mode=WAL; PRAGMA synchronous=FULL; CREATE TABLE IF NOT EXISTS records (kind TEXT NOT NULL, id TEXT NOT NULL, payload BLOB NOT NULL, PRIMARY KEY(kind,id)); BEGIN IMMEDIATE; UPDATE records SET id=json_extract(CAST(payload AS TEXT),'$.owner') || ':' || id WHERE kind IN ('session','queue') AND instr(id,':')=0; COMMIT;",
        nil, nil, nil) == SQLITE_OK
    else { throw StoreError(message: "Unable to prepare local storage.") }
  }
  deinit { sqlite3_close(database) }
  private func statement(_ sql: String) throws -> OpaquePointer {
    var p: OpaquePointer?
    guard sqlite3_prepare_v2(database, sql, -1, &p, nil) == SQLITE_OK, let p else {
      throw StoreError(message: String(cString: sqlite3_errmsg(database)))
    }
    return p
  }
  private func bind(_ value: String, at index: Int32, to p: OpaquePointer) {
    _ = value.withCString {
      sqlite3_bind_text(p, index, $0, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
    }
  }
  private func write<T: Encodable>(_ value: T, kind: String, id: String) throws {
    let p = try statement(
      "INSERT INTO records(kind,id,payload) VALUES(?,?,?) ON CONFLICT(kind,id) DO UPDATE SET payload=excluded.payload"
    )
    defer { sqlite3_finalize(p) }
    bind(kind, at: 1, to: p)
    bind(id, at: 2, to: p)
    let data = try encoder.encode(value)
    _ = data.withUnsafeBytes {
      sqlite3_bind_blob(
        p, 3, $0.baseAddress, Int32(data.count), unsafeBitCast(-1, to: sqlite3_destructor_type.self)
      )
    }
    guard sqlite3_step(p) == SQLITE_DONE else {
      throw StoreError(message: "Could not save your progress. Please retry.")
    }
  }
  public func saveQuizzes(_ quizzes: [PublishedQuiz]) throws {
    try write(quizzes, kind: "quizzes", id: "published")
  }
  public func saveQuestions(_ questions: [Question]) throws {
    try write(questions, kind: "bank", id: "published")
  }
  public func save(_ state: SessionState) throws {
    try write(merged(state), kind: "session", id: recordKey(state.owner, state.id))
  }
  public func save(_ submission: PendingSubmission) throws {
    try write(submission, kind: "queue", id: recordKey(submission.owner, submission.id))
  }
  public func commit(state: SessionState, submission: PendingSubmission) throws {
    guard sqlite3_exec(database, "BEGIN IMMEDIATE", nil, nil, nil) == SQLITE_OK else {
      throw StoreError(message: "Local storage is busy. Please retry.")
    }
    do {
      try write(merged(state), kind: "session", id: recordKey(state.owner, state.id))
      try write(submission, kind: "queue", id: recordKey(submission.owner, submission.id))
      guard sqlite3_exec(database, "COMMIT", nil, nil, nil) == SQLITE_OK else {
        throw StoreError(message: "Could not commit progress.")
      }
    } catch {
      sqlite3_exec(database, "ROLLBACK", nil, nil, nil)
      throw error
    }
  }
  public func list<T: Decodable & Sendable>(_ type: T.Type, kind: String) throws -> [T] {
    let p = try statement("SELECT payload FROM records WHERE kind=? ORDER BY rowid")
    defer { sqlite3_finalize(p) }
    bind(kind, at: 1, to: p)
    var result: [T] = []
    var status = sqlite3_step(p)
    while status == SQLITE_ROW {
      let data = Data(bytes: sqlite3_column_blob(p, 0), count: Int(sqlite3_column_bytes(p, 0)))
      result.append(try decoder.decode(type, from: data))
      status = sqlite3_step(p)
    }
    guard status == SQLITE_DONE else { throw StoreError(message: "Unable to read saved progress.") }
    return result
  }
  public func appendDiagnostic(_ event: String) throws {
    var events = try list([String].self, kind: "diagnostics").first ?? []
    events.append(event)
    try write(Array(events.suffix(100)), kind: "diagnostics", id: "events")
  }
  public func remove(kind: String, id: String) throws {
    let p = try statement("DELETE FROM records WHERE kind=? AND id=?")
    defer { sqlite3_finalize(p) }
    bind(kind, at: 1, to: p)
    bind(id, at: 2, to: p)
    guard sqlite3_step(p) == SQLITE_DONE else {
      throw StoreError(message: "Unable to update the sync queue.")
    }
  }
  public func reconcile(_ submission: PendingSubmission, result: Evaluation) throws {
    var states = try list(SessionState.self, kind: "session")
    guard let i = states.firstIndex(where: { $0.id == submission.sessionId && $0.owner == submission.owner }),
      let j = states[i].attempts.firstIndex(where: { $0.id == submission.id })
    else { throw StoreError(message: "The queued answer has no saved session.") }
    states[i].attempts[j].result = result
    guard sqlite3_exec(database, "BEGIN IMMEDIATE", nil, nil, nil) == SQLITE_OK else {
      throw StoreError(message: "Storage is busy.")
    }
    do {
      try write(states[i], kind: "session", id: recordKey(states[i].owner, states[i].id))
      if result.status != "pending_review" { try remove(kind: "queue", id: recordKey(submission.owner, submission.id)) }
      guard sqlite3_exec(database, "COMMIT", nil, nil, nil) == SQLITE_OK else {
        throw StoreError(message: "Sync commit failed.")
      }
    } catch {
      sqlite3_exec(database, "ROLLBACK", nil, nil, nil)
      throw error
    }
  }

  private func recordKey(_ owner: String, _ id: String) -> String { owner + ":" + id }
  private func merged(_ state: SessionState) throws -> SessionState {
    guard let existing = try list(SessionState.self, kind: "session").first(where: {
      $0.id == state.id && $0.owner == state.owner
    }) else { return state }
    return state.merging(existing)
  }
  func mergeCloud(_ state: SessionState) throws -> SessionState {
    let local = try list(SessionState.self, kind: "session").first { $0.id == state.id && $0.owner == state.owner }
    let merged = local?.merging(state, authoritative: true) ?? state
    try write(merged, kind: "session", id: recordKey(state.owner, state.id))
    // A cloud attempt can have a different ID when two offline devices answered
    // the same question. The server's first accepted answer remains canonical.
    for item in try list(PendingSubmission.self, kind: "queue") where item.owner == state.owner && item.sessionId == state.id {
      if let attempt = state.attempts.first(where: { $0.questionId == item.attempt.questionId }), attempt.result.status == "graded" {
        try remove(kind: "queue", id: recordKey(item.owner, item.id))
      }
    }
    return merged
  }
  func erase(owner: String) throws {
    let sessions = try list(SessionState.self, kind: "session").filter { $0.owner == owner }
    let queue = try list(PendingSubmission.self, kind: "queue").filter { $0.owner == owner }
    guard sqlite3_exec(database, "BEGIN IMMEDIATE", nil, nil, nil) == SQLITE_OK else { throw StoreError(message: "Storage is busy.") }
    do {
      for s in sessions { try remove(kind: "session", id: recordKey(owner, s.id)) }
      for q in queue { try remove(kind: "queue", id: recordKey(owner, q.id)) }
      guard sqlite3_exec(database, "COMMIT", nil, nil, nil) == SQLITE_OK else { throw StoreError(message: "Could not erase local progress.") }
    } catch { sqlite3_exec(database, "ROLLBACK", nil, nil, nil); throw error }
  }
  func claimGuest(to owner: String) throws {
    let sessions = try list(SessionState.self, kind: "session").filter { $0.owner == "guest" }
    let queued = try list(PendingSubmission.self, kind: "queue").filter { $0.owner == "guest" }
    guard sqlite3_exec(database, "BEGIN IMMEDIATE", nil, nil, nil) == SQLITE_OK else {
      throw StoreError(message: "Storage is busy.")
    }
    do {
      for var s in sessions {
        s.owner = owner
        try write(s, kind: "session", id: recordKey(owner, s.id))
        try remove(kind: "session", id: recordKey("guest", s.id))
      }
      for var q in queued {
        q.owner = owner
        try write(q, kind: "queue", id: recordKey(owner, q.id))
        try remove(kind: "queue", id: recordKey("guest", q.id))
      }
      guard sqlite3_exec(database, "COMMIT", nil, nil, nil) == SQLITE_OK else {
        throw StoreError(message: "Could not move guest progress.")
      }
    } catch {
      sqlite3_exec(database, "ROLLBACK", nil, nil, nil)
      throw error
    }
  }
}
