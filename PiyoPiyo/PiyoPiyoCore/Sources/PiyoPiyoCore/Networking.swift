import AuthenticationServices
import CryptoKit
import Foundation
import Security
import SwiftUI

struct AppConfiguration: Decodable {
  let ApiUrl: String
  let ClientId: String
  let AuthDomain: String
  let LiveUrl: String
  let Region: String
  static let current = try! JSONDecoder().decode(
    Self.self,
    from: Data(contentsOf: Bundle.module.url(forResource: "configuration", withExtension: "json")!))
}
struct AuthTokens: Codable {
  var accessToken: String
  var idToken: String
  var refreshToken: String
  var expiresAt: Date
  var subject: String? {
    let parts = idToken.split(separator: ".")
    guard parts.count == 3, let data = Data(base64URL: String(parts[1])),
      let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
    else { return nil }
    return object["sub"] as? String
  }
}
extension Data {
  var base64URL: String {
    base64EncodedString().replacingOccurrences(of: "+", with: "-").replacingOccurrences(
      of: "/", with: "_"
    ).replacingOccurrences(of: "=", with: "")
  }
  init?(base64URL: String) {
    var value = base64URL.replacingOccurrences(of: "-", with: "+").replacingOccurrences(
      of: "_", with: "/")
    value += String(repeating: "=", count: (4 - value.count % 4) % 4)
    self.init(base64Encoded: value)
  }
}
struct APIError: LocalizedError {
  let message: String
  var statusCode: Int? = nil
  var requiresSignIn: Bool { statusCode == 401 || statusCode == 403 }
  var errorDescription: String? { message }
}
@MainActor
final class AuthService: NSObject, ObservableObject, ASWebAuthenticationPresentationContextProviding
{
  @Published private(set) var tokens: AuthTokens?
  private var session: ASWebAuthenticationSession?
  private let config = AppConfiguration.current
  private let service = "app.piyopiyo.auth"
  private let urlSession: URLSession
  private let useKeychain: Bool
  private var generation = UUID()
  private var refreshTask: Task<AuthTokens, Error>?
  init(urlSession: URLSession = .shared, storedTokens: AuthTokens? = nil, useKeychain: Bool = true) {
    self.urlSession = urlSession
    self.useKeychain = useKeychain
    super.init()
    if !useKeychain { tokens = storedTokens; return }
    var item: CFTypeRef?
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword, kSecAttrService as String: service,
      kSecReturnData as String: true,
    ]
    if SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess, let data = item as? Data
    {
      tokens = try? JSONDecoder().decode(AuthTokens.self, from: data)
    }
  }
  func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
    #if os(macOS)
      NSApplication.shared.keyWindow ?? ASPresentationAnchor()
    #else
      UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.flatMap(\.windows)
        .first(where: \.isKeyWindow) ?? ASPresentationAnchor()
    #endif
  }
  private func save(_ value: AuthTokens) throws {
    if !useKeychain { tokens = value; return }
    let data = try JSONEncoder().encode(value)
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword, kSecAttrService as String: service,
      kSecAttrAccount as String: "current",
    ]
    let status = SecItemUpdate(
      query as CFDictionary, [kSecValueData as String: data] as CFDictionary)
    if status == errSecItemNotFound {
      var add = query
      add[kSecValueData as String] = data
      add[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
      guard SecItemAdd(add as CFDictionary, nil) == errSecSuccess else {
        throw APIError(message: "Unable to store sign-in securely.")
      }
    } else if status != errSecSuccess {
      throw APIError(message: "Unable to update secure sign-in.")
    }
    tokens = value
  }
  static func formBody(_ parameters: [String: String]) -> Data {
    let safe = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~")
    return Data(parameters.sorted { $0.key < $1.key }.map {
      $0.key.addingPercentEncoding(withAllowedCharacters: safe)! + "=" + $0.value.addingPercentEncoding(withAllowedCharacters: safe)!
    }.joined(separator: "&").utf8)
  }
  func signOut() {
    let previous = tokens
    generation = UUID()
    refreshTask?.cancel()
    refreshTask = nil
    session?.cancel()
    session = nil
    if useKeychain {
      SecItemDelete([kSecClass as String: kSecClassGenericPassword, kSecAttrService as String: service] as CFDictionary)
    }
    tokens = nil
    if let previous {
      Task {
        var request = URLRequest(url: URL(string: config.AuthDomain + "/oauth2/revoke")!)
        request.httpMethod = "POST"
        request.timeoutInterval = 10
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = Self.formBody(["client_id":config.ClientId,"token":previous.refreshToken])
        _ = try? await urlSession.data(for: request)
      }
    }
  }
  private func exchange(_ parameters: [String: String], refreshToken: String = "") async throws -> AuthTokens {
    var request = URLRequest(url: URL(string: config.AuthDomain + "/oauth2/token")!)
    request.httpMethod = "POST"
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    request.httpBody = Self.formBody(parameters)
    request.timeoutInterval = 20
    let (data, response) = try await urlSession.data(for: request)
    guard (response as? HTTPURLResponse)?.statusCode == 200 else {
      throw APIError(message: "Sign-in expired. Please sign in again.", statusCode: (response as? HTTPURLResponse)?.statusCode == 400 ? 401 : (response as? HTTPURLResponse)?.statusCode)
    }
    struct Response: Decodable {
      let accessToken: String
      let idToken: String
      let refreshToken: String?
      let expiresIn: Double
    }
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    let value = try decoder.decode(Response.self, from: data)
    return AuthTokens(
      accessToken: value.accessToken, idToken: value.idToken,
      refreshToken: value.refreshToken ?? refreshToken,
      expiresAt: Date().addingTimeInterval(value.expiresIn))
  }
  func validTokens() async throws -> AuthTokens {
    guard let current = tokens else { throw APIError(message: "Sign in to sync or join a room.") }
    if current.expiresAt.timeIntervalSinceNow > 60 { return current }
    if let refreshTask { return try await refreshTask.value }
    let identity = generation
    let task = Task { () throws -> AuthTokens in
      let refreshed = try await exchange([
        "grant_type": "refresh_token", "client_id": config.ClientId,
        "refresh_token": current.refreshToken,
      ], refreshToken: current.refreshToken)
      guard generation == identity, !Task.isCancelled, tokens?.subject == current.subject,
        refreshed.subject == current.subject else { throw CancellationError() }
      try save(refreshed)
      return refreshed
    }
    refreshTask = task
    defer { if generation == identity { refreshTask = nil } }
    do {
      return try await task.value
    } catch let error as APIError where error.statusCode == 401 && generation == identity {
      signOut()
      throw error
    }
  }
  func authorizeAppleDeletion(url: URL, expectedState: String) async throws {
    guard url.scheme == "https", url.host == "appleid.apple.com" else { throw APIError(message: "Invalid Apple authorization URL.") }
    let identity = generation
    defer { session = nil }
    let callback: URL = try await withCheckedThrowingContinuation { continuation in
      session = ASWebAuthenticationSession(url: url, callbackURLScheme: "piyopiyo") { url, error in
        if let error { continuation.resume(throwing: error) }
        else if let url { continuation.resume(returning: url) }
        else { continuation.resume(throwing: APIError(message: "Apple authorization was cancelled.")) }
      }
      session?.prefersEphemeralWebBrowserSession = true
      session?.presentationContextProvider = self
      guard session?.start() == true else { continuation.resume(throwing: APIError(message: "Unable to open Apple authorization.")); return }
    }
    let items = URLComponents(url: callback, resolvingAgainstBaseURL: false)?.queryItems ?? []
    guard generation == identity, callback.scheme == "piyopiyo", callback.host == "auth", callback.path == "/apple-delete",
      items.first(where: { $0.name == "state" })?.value == expectedState,
      items.first(where: { $0.name == "status" })?.value == "ready"
    else { throw APIError(message: "Apple authorization could not be revoked. Please try again with the Apple account used for PiyoPiyo.") }
  }
  func signIn() async throws {
    let identity = generation
    var bytes = [UInt8](repeating: 0, count: 32)
    guard SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes) == errSecSuccess else {
      throw APIError(message: "Unable to prepare secure sign-in.")
    }
    let verifier = Data(bytes).base64URL
    let challenge = Data(SHA256.hash(data: Data(verifier.utf8))).base64URL
    let state = UUID().uuidString
    var url = URLComponents(string: config.AuthDomain + "/oauth2/authorize")!
    url.queryItems = [
      "client_id": config.ClientId, "response_type": "code",
      "redirect_uri": "piyopiyo://auth/callback", "scope": "openid email profile",
      "code_challenge": challenge, "code_challenge_method": "S256", "state": state,
    ].map { URLQueryItem(name: $0.key, value: $0.value) }
    let callback: URL = try await withCheckedThrowingContinuation { continuation in
      session = ASWebAuthenticationSession(url: url.url!, callbackURLScheme: "piyopiyo") {
        url, error in
        if let error {
          continuation.resume(throwing: error)
        } else if let url {
          continuation.resume(returning: url)
        } else {
          continuation.resume(throwing: APIError(message: "Sign-in was cancelled."))
        }
      }
      session?.prefersEphemeralWebBrowserSession = true
      session?.presentationContextProvider = self
      guard session?.start() == true else {
        continuation.resume(throwing: APIError(message: "Unable to open sign-in."))
        return
      }
    }
    let items = URLComponents(url: callback, resolvingAgainstBaseURL: false)?.queryItems ?? []
    guard generation == identity, callback.scheme == "piyopiyo", callback.host == "auth", callback.path == "/callback",
      items.first(where: { $0.name == "state" })?.value == state,
      let code = items.first(where: { $0.name == "code" })?.value
    else { throw APIError(message: "Sign-in response could not be verified.") }
    let result = try await exchange([
      "grant_type": "authorization_code", "client_id": config.ClientId, "code": code,
      "redirect_uri": "piyopiyo://auth/callback", "code_verifier": verifier,
    ])
    guard generation == identity else { throw CancellationError() }
    guard result.subject != nil else { throw APIError(message: "Missing account identity.") }
    try save(result)
    session = nil
  }
}
struct APIClient {
  let baseURL: URL
  var urlSession: URLSession = .shared
  init(
    baseURL: URL = URL(string: AppConfiguration.current.ApiUrl)!, urlSession: URLSession = .shared
  ) {
    self.baseURL = baseURL
    self.urlSession = urlSession
  }
  func request(_ path: String, method: String = "GET", token: String, body: Data? = nil)
    async throws -> Data
  {
    var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
    let parts = path.split(separator: "?", maxSplits: 1)
    components.path = "/" + String(parts[0])
    components.percentEncodedQuery = parts.count > 1 ? String(parts[1]) : nil
    var request = URLRequest(url: components.url!)
    request.httpMethod = method
    request.timeoutInterval = 25
    request.httpBody = body
    request.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    let (data, response) = try await urlSession.data(for: request)
    guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
      let object = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
      throw APIError(
        message: object?["error"] as? String
          ?? "Sync is temporarily unavailable. Your work is saved on this device.",
        statusCode: (response as? HTTPURLResponse)?.statusCode)
    }
    return data
  }
  func progress(token: String, owner: String, questions: [Question]) async throws -> [SessionState]
  {
    struct Row: Decodable {
      let SK: String
      let id: String?
      let mode: DeliveryMode?
      let questionIds: [String]?
      let attemptId: String?
      let answer: [String]?
      let result: Evaluation?
      let createdAt: String?
      let deadline: Double?
    }
    struct Page: Decodable {
      let items: [Row]
      let nextCursor: String?
    }
    var rows: [Row] = []
    var cursor: String?
    repeat {
      let data = try await request(
        "progress" + (cursor.map { "?cursor=" + $0 } ?? ""), token: token)
      let page = try JSONDecoder().decode(Page.self, from: data)
      rows += page.items
      cursor = page.nextCursor
    } while cursor != nil
    let byId = Dictionary(uniqueKeysWithValues: questions.map { ($0.id, $0) })
    return rows.compactMap { row in
      guard let id = row.id, let mode = row.mode, let ids = row.questionIds else { return nil }
      let bank = ids.compactMap { byId[$0] }
      guard bank.count == ids.count else { return nil }
      var state = SessionState(owner: owner, mode: mode, questions: bank)
      state.id = id
      state.attempts = rows.filter { $0.SK.hasPrefix("SESSION#" + id + "#ATTEMPT#") }.compactMap {
        a in
        guard let attemptId = a.attemptId, let answer = a.answer, let result = a.result else {
          return nil
        }
        var attempt = Attempt(
          questionId: String(a.SK.split(separator: "#").last ?? ""), answer: answer, result: result)
        attempt.id = attemptId
        attempt.serverAccepted = true
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        attempt.createdAt =
          formatter.date(from: a.createdAt ?? "") ?? ISO8601DateFormatter().date(
            from: a.createdAt ?? "") ?? Date()
        return attempt
      }
      state.savedAt = state.attempts.map(\.createdAt).max() ?? Date()
      let answered = Set(state.attempts.map(\.questionId))
      state.cursor = bank.prefix { answered.contains($0.id) }.count
      if let deadline = row.deadline {
        state.savedAt = Date()
        state.remaining = max(0, deadline / 1000 - state.savedAt.timeIntervalSince1970)
      }
      return state
    }
  }
  func submit(_ item: PendingSubmission, token: String, allowAI: Bool = false) async throws -> Evaluation {
    var sessionPayload: [String: Any] = ["id": item.sessionId, "mode": item.mode.rawValue, "questionIds": item.questionIds]
    if let elapsed = item.attempt.elapsedSeconds { sessionPayload["startedAt"] = item.attempt.createdAt.addingTimeInterval(-elapsed).ISO8601Format() }
    let session = try JSONSerialization.data(withJSONObject: sessionPayload)
    _ = try await request("quiz", method: "POST", token: token, body: session)
    var payload: [String: Any] = ["questionId": item.attempt.questionId, "attemptId": item.attempt.id, "answer": item.attempt.answer, "allowAI": allowAI, "createdAt": item.attempt.createdAt.ISO8601Format()]
    if let elapsed = item.attempt.elapsedSeconds { payload["elapsedSeconds"] = elapsed }
    let answer = try JSONSerialization.data(withJSONObject: payload)
    let data = try await request(
      "quiz/\(item.sessionId)/attempts", method: "POST", token: token, body: answer)
    return try JSONDecoder().decode(Evaluation.self, from: data)
  }
}
struct Participant: Decodable, Identifiable {
  let id: String
  let name: String
  let score: Int
}
struct LiveRoom: Decodable, Identifiable {
  let id: String
  let hostId: String
  let mode: String
  let questionIds: [String]
  let participants: [Participant]
  let expiresAt: Double
}
@MainActor final class LiveClient: ObservableObject {
  @Published var room: LiveRoom?
  @Published var status = "Create a room or enter a room code."
  @Published var contributions: [String] = []
  private var socket: URLSessionWebSocketTask?
  private var listener: Task<Void, Never>?
  private let config = AppConfiguration.current
  private let fields = "id hostId mode questionIds participants { id name score } expiresAt"
  func operation(_ query: String, variables: [String: Any], token: String) async throws -> Data {
    var r = URLRequest(url: URL(string: config.LiveUrl)!)
    r.httpMethod = "POST"
    r.setValue(token, forHTTPHeaderField: "Authorization")
    r.setValue("application/json", forHTTPHeaderField: "Content-Type")
    r.httpBody = try JSONSerialization.data(withJSONObject: [
      "query": query, "variables": variables,
    ])
    let (data, response) = try await URLSession.shared.data(for: r)
    guard (response as? HTTPURLResponse)?.statusCode == 200 else {
      throw APIError(message: "Live service unavailable.")
    }
    let object = try JSONSerialization.jsonObject(with: data) as? [String: Any]
    if let errors = object?["errors"] as? [[String: Any]] {
      throw APIError(message: errors.first?["message"] as? String ?? "Please retry.")
    }
    return data
  }
  func open(mode: String, auth: AuthService) async throws {
    let t = try await auth.validTokens()
    let data = try await operation(
      "mutation($mode:String!){createRoom(mode:$mode){\(fields)}}", variables: ["mode": mode],
      token: t.idToken)
    try decodeRoom(data, field: "createRoom")
    subscribe(auth: auth)
  }
  func join(id: String, name: String, auth: AuthService) async throws {
    let t = try await auth.validTokens()
    let data = try await operation(
      "mutation($id:ID!,$name:String!){joinRoom(id:$id,name:$name){\(fields)}}",
      variables: ["id": id, "name": name], token: t.idToken)
    try decodeRoom(data, field: "joinRoom")
    subscribe(auth: auth)
  }
  private func decodeRoom(_ data: Data, field: String) throws {
    let object = try JSONSerialization.jsonObject(with: data) as? [String: Any]
    guard let value = (object?["data"] as? [String: Any])?[field], !(value is NSNull) else {
      throw APIError(message: "Room unavailable.")
    }
    room = try JSONDecoder().decode(
      LiveRoom.self, from: JSONSerialization.data(withJSONObject: value))
    status = "Connected"
  }
  func refresh(auth: AuthService) async throws {
    guard let room else { return }
    let t = try await auth.validTokens()
    let data = try await operation(
      "query($id:ID!){room(id:$id){\(fields)}}", variables: ["id": room.id], token: t.idToken)
    try decodeRoom(data, field: "room")
  }
  func submit(question: Question, answer: [String], auth: AuthService) async throws {
    guard let room else { return }
    let t = try await auth.validTokens()
    let answerText = String(data: try JSONEncoder().encode(answer), encoding: .utf8)!
    _ = try await operation(
      "mutation($roomId:ID!,$questionId:ID!,$answer:String!,$attemptId:ID!){submitAnswer(roomId:$roomId,questionId:$questionId,answer:$answer,attemptId:$attemptId){roomId participantId questionId score total answer}}",
      variables: [
        "roomId": room.id, "questionId": question.id, "answer": answerText,
        "attemptId": UUID().uuidString,
      ], token: t.idToken)
    try await refresh(auth: auth)
  }
  func close() {
    listener?.cancel()
    listener = nil
    socket?.cancel(with: .goingAway, reason: nil)
    socket = nil
    room = nil
    contributions = []
    status = "Create a room or enter a room code."
  }
  private func subscribe(auth: AuthService) {
    listener?.cancel()
    socket?.cancel(with: .goingAway, reason: nil)
    listener = Task { [weak self] in
      guard let self else { return }
      while !Task.isCancelled, let room = self.room {
        do {
          let t = try await auth.validTokens()
          let host = URL(string: config.LiveUrl)!.host!
          let authorization = ["host": host, "Authorization": t.idToken]
          var url = URLComponents(
            string: config.LiveUrl.replacingOccurrences(of: "https://", with: "wss://")
              .replacingOccurrences(of: "appsync-api", with: "appsync-realtime-api"))!
          url.queryItems = [
            URLQueryItem(
              name: "header",
              value: try JSONSerialization.data(withJSONObject: authorization).base64EncodedString()
            ), URLQueryItem(name: "payload", value: Data("{}".utf8).base64EncodedString()),
          ]
          let ws = URLSession.shared.webSocketTask(with: url.url!, protocols: ["graphql-ws"])
          self.socket = ws
          ws.resume()
          try await ws.send(.string("{\"type\":\"connection_init\"}"))
          while !Task.isCancelled {
            let message = try await ws.receive()
            let data: Data
            switch message {
            case .data(let d): data = d
            case .string(let s): data = Data(s.utf8)
            @unknown default: continue
            }
            let envelope = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            let kind = envelope?["type"] as? String
            if kind == "connection_ack" {
              let query = String(
                data: try JSONSerialization.data(withJSONObject: [
                  "query":
                    "subscription($roomId:ID!){onAnswer(roomId:$roomId){roomId participantId questionId score total answer}}",
                  "variables": ["roomId": room.id],
                ]), encoding: .utf8)!
              let start: [String: Any] = [
                "id": UUID().uuidString, "type": "start",
                "payload": ["data": query, "extensions": ["authorization": authorization]],
              ]
              try await ws.send(.data(JSONSerialization.data(withJSONObject: start)))
              status = "Live updates connected"
            } else if kind == "data" {
              if let payload = envelope?["payload"] as? [String: Any],
                let values = payload["data"] as? [String: Any],
                let event = values["onAnswer"] as? [String: Any],
                let answer = event["answer"] as? String
              {
                contributions.append(answer)
                contributions = Array(contributions.suffix(30))
              }
              try await refresh(auth: auth)
            } else if kind == "error" {
              throw APIError(message: "Live updates interrupted.")
            }
          }
        } catch {
          if Task.isCancelled { return }
          status = "Reconnecting…"
          try? await Task.sleep(for: .seconds(5))
        }
      }
    }
  }
}
