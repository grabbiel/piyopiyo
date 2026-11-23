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
  private let service = "app.piyopiyo.sources.auth"
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
    guard let current = tokens else { throw APIError(message: "Sign in to manage your sources.") }
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
    return try await task.value
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
      "redirect_uri": "piyopiyo-sources://auth/callback", "scope": "openid email profile",
      "code_challenge": challenge, "code_challenge_method": "S256", "state": state,
    ].map { URLQueryItem(name: $0.key, value: $0.value) }
    let callback: URL = try await withCheckedThrowingContinuation { continuation in
      session = ASWebAuthenticationSession(url: url.url!, callbackURLScheme: "piyopiyo-sources") {
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
    guard generation == identity, callback.scheme == "piyopiyo-sources", callback.host == "auth", callback.path == "/callback",
      items.first(where: { $0.name == "state" })?.value == state,
      let code = items.first(where: { $0.name == "code" })?.value
    else { throw APIError(message: "Sign-in response could not be verified.") }
    let result = try await exchange([
      "grant_type": "authorization_code", "client_id": config.ClientId, "code": code,
      "redirect_uri": "piyopiyo-sources://auth/callback", "code_verifier": verifier,
    ])
    guard generation == identity else { throw CancellationError() }
    guard result.subject != nil else { throw APIError(message: "Missing account identity.") }
    try save(result)
    session = nil
  }
}
