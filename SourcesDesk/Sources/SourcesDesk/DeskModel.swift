import Foundation
import CryptoKit
import SwiftUI

struct Source: Decodable, Identifiable {
  let id, title, topic, kind, status, updatedAt: String
  let url, error, lastGeneratedAt: String?
  let segmentCount, pageCount: Int?
  let active: Bool
}
struct Batch: Decodable, Identifiable {
  let id, sourceTitle, status, createdAt: String
  let published, rejected: Int?
}
struct Job: Decodable, Identifiable {
  var id: String { jobId }
  let jobId, op, status: String
  let error, completedAt, startedAt, updatedAt: String?
}
struct Settings: Decodable { let enabled, autoPublish: Bool; let maxModelCalls: Int }
struct Usage: Decodable { let calls: Int }
struct Dashboard: Decodable {
  let sources: [Source], batches: [Batch], jobs: [Job]
  let settings: Settings, usage: Usage
  let schedule: String
}
struct BatchDetail: Decodable {
  struct Question: Decodable, Identifiable {
    struct Validation: Decodable { let accepted: Bool; let reasons: [String] }
    let id, prompt, explanation: String
    let correct, options: [String]
    let validation: Validation?
  }
  let sourceTitle: String
  let questions: [Question]
}
struct SafetyReport: Decodable, Identifiable {
  let id, roomId, targetId, targetName, reason, status, createdAt: String
  struct Evidence: Decodable { let questionId: String?; let answer: String? }
  let evidence: [Evidence]
}
@MainActor final class DeskModel: ObservableObject {
  let auth = AuthService()
  @Published var reports: [SafetyReport] = []
  @Published var reportCursor: String?
  @Published var dashboard: Dashboard?
  @Published var busy = false
  @Published var error: String?
  @Published var notice: String?
  @Published var batchDetail: BatchDetail?
  @Published var incomingFile: URL?
  private let config = AppConfiguration.current
  func loadReports(more: Bool = false) async {
    do {
      struct Response: Decodable { let reports: [SafetyReport]; let nextCursor: String? }
      let path = "moderation/reports" + (more ? reportCursor.map { "?cursor=" + $0 } ?? "" : "")
      let result = try JSONDecoder().decode(Response.self, from: await request(path))
      reports = ((more ? reports : []) + result.reports).sorted { $0.createdAt > $1.createdAt }
      reportCursor = result.nextCursor
    } catch { self.error = error.localizedDescription }
  }
  func resolveReport(_ report: SafetyReport, action: String) async {
    busy = true; defer { busy = false }
    do {
      _ = try await request("moderation/reports/" + report.id, method: "POST", body: ["action": action])
      await loadReports()
      notice = action == "restricted" ? "Participant restricted from study rooms; their name is removed from room listings." : "Report updated."
    } catch { self.error = error.localizedDescription }
  }
  func request(_ path: String, method: String = "GET", body: [String: Any]? = nil) async throws -> Data {
    let identity = auth.tokens?.subject
    let tokens = try await auth.validTokens()
    var request = URLRequest(url: URL(string: config.ApiUrl + (path.hasPrefix("moderation/") ? "/" : "/knowledge/") + path)!)
    request.httpMethod = method; request.timeoutInterval = 35
    request.setValue("Bearer " + tokens.accessToken, forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    if let body { request.httpBody = try JSONSerialization.data(withJSONObject: body) }
    let (data, response) = try await URLSession.shared.data(for: request)
    guard auth.tokens?.subject == identity else { throw CancellationError() }
    guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
      let message = (try? JSONSerialization.jsonObject(with: data) as? [String: Any])?["error"] as? String
      throw APIError(message: message ?? "The cloud service could not complete this request.", statusCode: (response as? HTTPURLResponse)?.statusCode)
    }
    return data
  }
  func perform(_ action: () async throws -> Void) async {
    guard !busy else { return }; busy = true; error = nil; notice = nil
    defer { busy = false }
    do { try await action() } catch is CancellationError {} catch { self.error = error.localizedDescription }
  }
  func refresh() async throws {
    let value = try JSONDecoder().decode(Dashboard.self, from: await request("dashboard"))
    dashboard = value
  }
  func signIn() async { await perform { try await auth.signIn(); try await refresh() } }
  func signOut() { auth.signOut(); reports = []; reportCursor = nil; dashboard = nil; batchDetail = nil; error = nil; notice = nil }
  func add(title: String, topic: String, url: String, file: URL?, openLicense: Bool) async {
    await perform {
      var body: [String: Any] = ["title": title, "topic": topic, "consent": true, "rights": openLicense ? "open_license" : "private_reference"]
      var bytes: Data?
      if let file {
        let access = file.startAccessingSecurityScopedResource(); defer { if access { file.stopAccessingSecurityScopedResource() } }
        guard ["pdf", "txt", "md"].contains(file.pathExtension.lowercased()) else { throw APIError(message: "Choose a PDF, TXT, or Markdown file.") }
        let size = try file.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
        guard size > 0 && size <= 20 * 1024 * 1024 else { throw APIError(message: "Choose a file smaller than 20 MB.") }
        let data = try Data(contentsOf: file); bytes = data
        body["kind"] = file.pathExtension.lowercased() == "pdf" ? "pdf" : "text"
        body["bytes"] = data.count
        body["sha256"] = SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
      } else {
        guard let parsed = URL(string: url), parsed.scheme == "https", parsed.host != nil else { throw APIError(message: "Enter a complete public HTTPS URL.") }
        body["kind"] = "url"; body["url"] = url
      }
      struct Submission: Decodable { let source: Source; let duplicate: Bool?; let uploadURL, checksum, contentType: String? }
      let submission = try JSONDecoder().decode(Submission.self, from: await request("sources", method: "POST", body: body))
      if let link = submission.uploadURL, let bytes {
        guard let target = URL(string: link), target.scheme == "https", target.host?.hasSuffix(".amazonaws.com") == true else { throw APIError(message: "The upload destination could not be verified.") }
        var upload = URLRequest(url: target); upload.httpMethod = "PUT"; upload.timeoutInterval = 180
        upload.setValue(submission.contentType, forHTTPHeaderField: "Content-Type")
        upload.setValue(submission.checksum, forHTTPHeaderField: "x-amz-checksum-sha256")
        let (_, response) = try await URLSession.shared.upload(for: upload, from: bytes)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else { throw APIError(message: "The upload did not finish. Add the same file to retry safely.") }
        _ = try await request("sources/\(submission.source.id)/complete", method: "POST")
      }
      notice = submission.duplicate == true ? "This source is already in your library." : "Source shared. Cloud processing will continue in the background."
      incomingFile = nil
      try await refresh()
    }
  }
  func sourceAction(_ source: Source, _ action: String) async {
    await perform { _ = try await request("sources/\(source.id)/\(action)", method: "POST"); notice = "Request queued. Refresh shortly to see the result."; try await refresh() }
  }
  func run(_ op: String, source: Source? = nil) async {
    await perform {
      var body = ["op": op]; if let source { body["sourceId"] = source.id }
      _ = try await request("run", method: "POST", body: body)
      notice = "Background \(op == "generate" ? "question generation" : "source discovery") queued."
      try await refresh()
    }
  }
  func togglePipeline() async {
    await perform { _ = try await request("settings", method: "PATCH", body: ["enabled": !(dashboard?.settings.enabled ?? true)]); try await refresh() }
  }
  func withdraw(_ batch: Batch) async { await perform { _ = try await request("batches/" + batch.id + "/withdraw", method: "POST"); notice = "Withdrawal queued. Saved attempts stay available; future quizzes will exclude this batch."; try await refresh() } }
  func show(_ batch: Batch) async { await perform { batchDetail = try JSONDecoder().decode(BatchDetail.self, from: await request("batches/" + batch.id)) } }
}
