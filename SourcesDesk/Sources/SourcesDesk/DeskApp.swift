import SwiftUI
import UniformTypeIdentifiers

private let ink = Color(red: 0.16, green: 0.19, blue: 0.19)
private let cream = Color(red: 0.99, green: 0.98, blue: 0.94)
private let gold = Color(red: 0.96, green: 0.70, blue: 0.14)
final class AppDelegate: NSObject, NSApplicationDelegate {
  func applicationDidFinishLaunching(_ notification: Notification) { NSApp.setActivationPolicy(.regular); NSApp.activate(ignoringOtherApps: true) }
}
@main struct SourcesDeskApp: App {
  @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate
  @StateObject private var model = DeskModel()
  var body: some Scene {
    WindowGroup("PiyoPiyo Sources") {
      DeskView(model: model, auth: model.auth).frame(minWidth: 920, minHeight: 660).preferredColorScheme(.light)
        .onOpenURL { url in if url.isFileURL { model.incomingFile = url } }
    }.defaultSize(width: 1080, height: 760)
  }
}
struct DeskView: View {
  @ObservedObject var model: DeskModel
  @ObservedObject var auth: AuthService
  @State private var section = "Sources"
  @State private var showAdd = false
  private let sections = [("Sources", "books.vertical"), ("Question batches", "square.stack.3d.up"), ("Activity", "clock.arrow.circlepath")]
  var body: some View {
    HStack(spacing: 0) {
      VStack(alignment: .leading, spacing: 24) {
        HStack { Image(systemName: "bird.fill").font(.system(size: 30)).foregroundStyle(gold); VStack(alignment: .leading) { Text("PiyoPiyo").font(.title2.bold()); Text("SOURCES").font(.caption.weight(.semibold)).tracking(2).foregroundStyle(.secondary) } }
        Text("A little reading.\nA growing world of ideas.").font(.callout).foregroundStyle(.secondary).lineSpacing(4)
        ForEach(sections, id: \.0) { item in Button { section = item.0 } label: { Label(item.0, systemImage: item.1).frame(maxWidth: .infinity, alignment: .leading).padding(12).background(section == item.0 ? gold.opacity(0.22) : .clear, in: RoundedRectangle(cornerRadius: 10)) }.buttonStyle(.plain) }
        Spacer()
        Label("Private source library", systemImage: "lock.shield").font(.caption).foregroundStyle(.secondary)
        if auth.tokens != nil { Button("Sign out") { model.signOut() }.disabled(model.busy) }
      }.padding(24).frame(width: 220).background(cream)
      Divider()
      VStack(alignment: .leading, spacing: 18) {
        if auth.tokens == nil { welcome }
        else {
          HStack { VStack(alignment: .leading, spacing: 6) { Text(section).font(.largeTitle.bold()); Text("Good sources become better practice.").foregroundStyle(.secondary) }; Spacer(); if model.busy { ProgressView().controlSize(.small) }; Button { Task { await model.perform { try await model.refresh() } } } label: { Label("Refresh", systemImage: "arrow.clockwise") }; Button("Add source", systemImage: "plus") { showAdd = true }.buttonStyle(.borderedProminent).tint(gold).foregroundStyle(ink) }
          if let data = model.dashboard { pipeline(data); content(data) }
          else { ContentUnavailableView("Connect your library", systemImage: "books.vertical", description: Text("Refresh to load your cloud sources and background activity.")) }
        }
        if let error = model.error { Label(error, systemImage: "exclamationmark.triangle").foregroundStyle(.red).font(.callout).textSelection(.enabled) }
        if let notice = model.notice { Label(notice, systemImage: "checkmark.circle").foregroundStyle(.secondary).font(.callout) }
      }.padding(28).frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }.foregroundStyle(ink).background(.white)
      .sheet(isPresented: $showAdd) { AddSourceView(model: model) }
      .sheet(isPresented: Binding(get: { model.batchDetail != nil }, set: { if !$0 { model.batchDetail = nil } })) { if let detail = model.batchDetail { BatchView(detail: detail) } }
      .onChange(of: model.incomingFile) { _, file in if file != nil && auth.tokens != nil { showAdd = true } }
      .onChange(of: auth.tokens?.subject) { _, subject in if subject != nil && model.incomingFile != nil { showAdd = true } }
      .dropDestination(for: URL.self) { urls, _ in guard let file = urls.first, file.isFileURL else { return false }; model.incomingFile = file; return true }
      .task { if auth.tokens != nil { await model.perform { try await model.refresh() } }; while !Task.isCancelled { try? await Task.sleep(for: .seconds(30)); if Task.isCancelled { break }; if auth.tokens != nil && !model.busy { do { try await model.refresh() } catch { model.error = error.localizedDescription } } } }
  }
  private var welcome: some View {
    VStack(alignment: .leading, spacing: 22) {
      Spacer(); Image(systemName: "books.vertical.fill").font(.system(size: 60)).foregroundStyle(gold)
      Text("Feed your curiosity.").font(.system(size: 38, weight: .bold))
      Text("Share textbooks, articles, and notes with PiyoPiyo. Your cloud library keeps growing while new, source-backed quizzes arrive throughout the week.").font(.title3).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
      Label("PDFs, text files, and public HTTPS links", systemImage: "doc.badge.plus")
      Label("Private originals. Validated questions publish automatically.", systemImage: "checkmark.seal")
      Button("Sign in to your source library") { Task { await model.signIn() } }.buttonStyle(.borderedProminent).controlSize(.large).tint(gold).foregroundStyle(ink).disabled(model.busy)
      if model.busy { ProgressView("Opening secure sign-in…") }
      Text("Use your PiyoPiyo content administrator account.").font(.caption).foregroundStyle(.secondary)
      Spacer()
    }.frame(maxWidth: 640, alignment: .leading)
  }
  private func pipeline(_ data: Dashboard) -> some View {
    VStack(alignment: .leading, spacing: 10) {
      HStack { Circle().fill(data.settings.enabled ? .green : .orange).frame(width: 8, height: 8); Text(data.settings.enabled ? "Background learning is on" : "Background learning is paused").fontWeight(.semibold); Spacer(); Text("\(data.usage.calls) / \(data.settings.maxModelCalls) model calls this month").font(.caption).foregroundStyle(.secondary) }
      Text(data.schedule).font(.caption).foregroundStyle(.secondary)
      HStack { Button(data.settings.enabled ? "Pause pipeline" : "Resume pipeline") { Task { await model.togglePipeline() } }; Button("Find new sources") { Task { await model.run("discover") } }.disabled(!data.settings.enabled); Button("Make a quiz now") { Task { await model.run("generate") } }.disabled(!data.settings.enabled); Spacer(); Text("Automatic publication after validation").font(.caption).foregroundStyle(.secondary) }.disabled(model.busy)
    }.padding(16).background(cream, in: RoundedRectangle(cornerRadius: 14))
  }
  @ViewBuilder private func content(_ data: Dashboard) -> some View {
    if section == "Sources" {
      if data.sources.isEmpty { ContentUnavailableView("Your next idea starts here", systemImage: "doc.badge.plus", description: Text("Add a link or drop a PDF into this window.")) }
      else { List(data.sources) { source in VStack(alignment: .leading, spacing: 8) {
        HStack(alignment: .top) { Image(systemName: source.kind == "pdf" ? "doc.richtext" : "link").foregroundStyle(gold); VStack(alignment: .leading, spacing: 5) { Text(source.title).fontWeight(.semibold); Text(source.topic + " · " + (source.active ? source.status.replacingOccurrences(of: "_", with: " ") : "paused")).font(.caption).foregroundStyle(.secondary) }; Spacer(); if let count = source.segmentCount { Text("\(count) passages").font(.caption).foregroundStyle(.secondary) } }
        if let error = source.error { Text(error).font(.caption).foregroundStyle(.red).textSelection(.enabled) }
        HStack { if let link = source.url, let url = URL(string: link) { Link("Open source", destination: url) }; Button(source.active ? "Pause source" : "Resume source") { Task { await model.sourceAction(source, source.active ? "pause" : "resume") } }; Button("Reprocess") { Task { await model.sourceAction(source, "retry") } }; if source.status == "ready" { Button("Make questions") { Task { await model.run("generate", source: source) } }.disabled(!source.active || !data.settings.enabled) } }.font(.caption).disabled(model.busy)
      }.padding(.vertical, 9) }.listStyle(.plain) }
    } else if section == "Question batches" {
      if data.batches.isEmpty { ContentUnavailableView("Questions are on their way", systemImage: "square.stack.3d.up", description: Text("Ready sources become quizzes each Monday, Wednesday, and Friday.")) }
      else { List(data.batches.sorted { $0.createdAt > $1.createdAt }) { batch in Button { Task { await model.show(batch) } } label: { VStack(alignment: .leading, spacing: 7) { Text(batch.sourceTitle).fontWeight(.semibold); Text("\(batch.status.capitalized) · \(batch.published ?? 0) published · \(batch.rejected ?? 0) rejected").font(.caption).foregroundStyle(.secondary); Text(batch.createdAt.prefix(10)).font(.caption2).foregroundStyle(.secondary) }.padding(.vertical, 10).frame(maxWidth: .infinity, alignment: .leading) }.buttonStyle(.plain).contextMenu { if batch.status == "published" { Button("Withdraw from future quizzes") { Task { await model.withdraw(batch) } } } } }.listStyle(.plain) }
    } else { List(data.jobs.sorted { ($0.completedAt ?? $0.updatedAt ?? $0.startedAt ?? "") > ($1.completedAt ?? $1.updatedAt ?? $1.startedAt ?? "") }) { job in VStack(alignment: .leading, spacing: 6) { Text(job.op.capitalized + " · " + job.status).fontWeight(.semibold); if let error = job.error { Text(error).font(.caption).foregroundStyle(.red).textSelection(.enabled) }; Text(job.completedAt ?? job.updatedAt ?? job.startedAt ?? "").font(.caption).foregroundStyle(.secondary) }.padding(.vertical, 8) }.listStyle(.plain) }
  }
}
struct AddSourceView: View {
  @ObservedObject var model: DeskModel
  @Environment(\.dismiss) private var dismiss
  @State private var title = ""
  @State private var url = ""
  @State private var topic = "Programming"
  @State private var file: URL?
  @State private var picker = false
  @State private var consent = false
  @State private var openLicense = false
  private let topics = ["Algorithms", "Programming", "Databases", "Operating systems", "Distributed systems", "Software engineering", "Computer science research"]
  var body: some View {
    VStack(alignment: .leading, spacing: 18) {
      Text("Add a little knowledge").font(.title.bold())
      Text("A textbook chapter, a useful article, or notes worth remembering.").foregroundStyle(.secondary)
      TextField("Source title", text: $title).textFieldStyle(.roundedBorder)
      Picker("Topic", selection: $topic) { ForEach(topics, id: \.self) { Text($0) } }
      if let file { HStack { Label(file.lastPathComponent, systemImage: "doc"); Spacer(); Button("Remove") { self.file = nil } }.padding(12).background(cream, in: RoundedRectangle(cornerRadius: 10)) }
      else { TextField("https://example.com/article", text: $url).textFieldStyle(.roundedBorder) }
      Button("Choose PDF or text file…") { picker = true }
      Text("Up to 20 MB and 1,000 PDF pages. Scanned PDFs need OCR first. Upload only material you are allowed to process.").font(.caption).foregroundStyle(.secondary)
      Toggle("This source has an open license", isOn: $openLicense)
      Toggle("Allow PiyoPiyo to store this source privately in AWS and process relevant passages with Amazon Bedrock to create original questions. The title and public URL may appear in citations.", isOn: $consent).fixedSize(horizontal: false, vertical: true)
      if let error = model.error { Text(error).foregroundStyle(.red).font(.caption) }
      HStack { Button("Cancel") { dismiss() }.keyboardShortcut(.cancelAction); Spacer(); if model.busy { ProgressView().controlSize(.small) }; Button("Share source") { Task { await model.add(title: title, topic: topic, url: url, file: file, openLicense: openLicense); if model.error == nil { dismiss() } } }.buttonStyle(.borderedProminent).tint(gold).foregroundStyle(ink).disabled(!consent || title.trimmingCharacters(in: .whitespaces).count < 3 || (file == nil && url.isEmpty)) }.disabled(model.busy)
    }.padding(28).frame(width: 550)
      .fileImporter(isPresented: $picker, allowedContentTypes: [.pdf, .plainText, UTType(filenameExtension: "md") ?? .plainText]) { result in switch result { case .success(let selected): file = selected; if title.isEmpty { title = selected.deletingPathExtension().lastPathComponent }; case .failure(let error): model.error = error.localizedDescription } }
      .onAppear { file = model.incomingFile; if let file { title = file.deletingPathExtension().lastPathComponent } }
  }
}
struct BatchView: View {
  let detail: BatchDetail
  @Environment(\.dismiss) private var dismiss
  var body: some View { VStack(alignment: .leading, spacing: 18) { HStack { Text(detail.sourceTitle).font(.title2.bold()); Spacer(); Button("Done") { dismiss() } }; ScrollView { VStack(alignment: .leading, spacing: 24) { ForEach(detail.questions) { question in VStack(alignment: .leading, spacing: 9) { Label(question.validation?.accepted == true ? "Passed validation" : "Held from publication", systemImage: question.validation?.accepted == true ? "checkmark.seal" : "pause.circle").font(.caption).foregroundStyle(.secondary); Text(question.prompt).font(.headline); ForEach(question.options, id: \.self) { Text("• " + $0) }; Text("Answer: " + question.correct.joined(separator: ", ")).fontWeight(.semibold); Text(question.explanation).foregroundStyle(.secondary); ForEach(question.validation?.reasons ?? [], id: \.self) { Text($0).font(.caption).foregroundStyle(.red) }; Divider() } } }.textSelection(.enabled) } }.padding(28).frame(width: 740, height: 650) }
}
