import SwiftUI

public struct PiyoPiyoRootView: View {
  @StateObject private var model = AppModel()
  @Environment(\.scenePhase) private var scenePhase
  private let pages = [
    ("Learn", "leaf"), ("Library", "books.vertical"), ("Progress", "chart.bar"),
    ("Rooms", "person.2"), ("Settings", "slider.horizontal.3"),
  ]
  public init() {}
  public var body: some View {
    shell.environmentObject(model).tint(T.primary).foregroundStyle(T.ink).preferredColorScheme(
      .light
    )
    .sheet(
      isPresented: $model.showQuiz,
      onDismiss: {
        Task {
          await model.persist()
          await model.load()
        }
      }
    ) { QuizScreen().environmentObject(model) }
    .alert(
      "A little pause",
      isPresented: Binding(get: { model.error != nil }, set: { if !$0 { model.error = nil } })
    ) {
      Button("OK") { model.error = nil }
    } message: {
      Text(model.error ?? "")
    }
    .task {
      await model.loadBank()
      await model.load()
      await model.sync()
      while !Task.isCancelled {
        try? await Task.sleep(for: .seconds(30))
        await model.sync()
      }
    }
    .onChange(of: scenePhase) { _, phase in
      if phase != .active { Task { await model.persist() } } else { Task { await model.sync() } }
    }
  }
  @ViewBuilder private var shell: some View {
    #if os(macOS)
      NavigationSplitView {
        VStack(alignment: .leading, spacing: T.xl) {
          HStack(spacing: T.xs) {
            PiyoMascot().frame(width: T.size("smallMascot"), height: T.size("smallMascot"))
            Text("piyopiyo").font(.system(.title2, design: .rounded).bold())
          }.padding(.top, T.lg)
          VStack(spacing: T.xs) {
            ForEach(pages, id: \.0) { name, symbol in
              Button {
                model.selectedPage = name
              } label: {
                Label(name, systemImage: symbol).font(.headline).frame(
                  maxWidth: .infinity, alignment: .leading
                ).padding(T.md).background(
                  model.selectedPage == name ? T.softGreen : T.clear,
                  in: RoundedRectangle(cornerRadius: T.button))
              }.buttonStyle(.plain)
            }
          }
          Spacer()
          VStack(alignment: .leading, spacing: T.xs) {
            Label("A little better, every day.", systemImage: "sun.max").font(.caption)
            Text("Your computer science companion").font(.caption2).foregroundStyle(T.muted)
          }.padding(.bottom, T.lg)
        }.padding(.horizontal, T.md).background(T.surface).navigationSplitViewColumnWidth(
          T.size("sidebar"))
      } detail: {
        page(model.selectedPage)
      }.frame(minWidth: T.size("macMinWidth"), minHeight: T.size("macMinHeight"))
    #else
      TabView(selection: $model.selectedPage) {
        ForEach(pages, id: \.0) { name, symbol in
          NavigationStack { page(name) }.tabItem { Label(name, systemImage: symbol) }.tag(name)
        }
      }
    #endif
  }
  @ViewBuilder private func page(_ name: String) -> some View {
    switch name {
    case "Library": LibraryScreen()
    case "Progress": ProgressScreen()
    case "Rooms": RoomsScreen()
    case "Settings": SettingsScreen()
    default: HomeScreen()
    }
  }
}
struct PageLayout<Content: View>: View {
  let title: String
  let subtitle: String
  @ViewBuilder var content: () -> Content
  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: T.lg) {
        HStack {
          VStack(alignment: .leading, spacing: T.xs) {
            Text(title).font(.largeTitle.bold())
            Text(subtitle).font(.subheadline).foregroundStyle(T.muted)
          }
          Spacer()
        }
        content()
      }.padding(T.lg).frame(maxWidth: T.size("content"), alignment: .leading).frame(
        maxWidth: .infinity)
    }.background(T.background)
  }
}
struct SectionHeading: View {
  let title: String
  var detail: String?
  var body: some View {
    HStack {
      Text(title).font(.title2.bold())
      Spacer()
      if let detail { Text(detail).font(.caption).foregroundStyle(T.muted) }
    }
  }
}
struct HomeScreen: View {
  @EnvironmentObject private var model: AppModel
  @State private var mode: DeliveryMode = .practice
  var body: some View {
    PageLayout(
      title: "Make room for a little learning.",
      subtitle: Date().formatted(.dateTime.weekday(.wide).month(.wide).day())
    ) {
      ViewThatFits(in: .horizontal) {
        HStack(spacing: T.xl) {
          heroText
          PiyoMascot(state: Calendar.current.component(.hour, from: Date()) >= 22 ? .sleepy : .idle)
            .frame(width: T.size("heroMascot"), height: T.size("heroMascot"))
        }
        VStack(alignment: .leading, spacing: T.md) {
          HStack {
            PiyoMascot().frame(width: T.size("smallMascot"), height: T.size("smallMascot"))
            Text("piyopiyo").font(.system(.title3, design: .rounded).bold())
            Spacer()
          }
          heroText
        }
      }.piyoCard(T.softYellow)
      HStack(spacing: T.sm) {
        stat("Today", "\(model.todayCount)", "questions", symbol: "checkmark.seal")
        stat("Streak", "\(model.streak)", "days", symbol: "flame")
        stat("Accuracy", "\(model.accuracy)%", "so far", symbol: "scope")
      }
      VStack(alignment: .leading, spacing: T.sm) {
        HStack {
          Label("A small daily goal", systemImage: "sun.max").font(.headline)
          Spacer()
          Text("\(min(model.todayCount,5)) / 5").font(.subheadline.monospacedDigit())
        }
        ProgressView(value: Double(min(model.todayCount, 5)), total: 5)
        Text("Five thoughtful answers are a good place to start.").font(.caption).foregroundStyle(
          T.muted)
      }.piyoCard()
      if let recent = model.history.first(where: { !$0.complete }) {
        Button {
          Task { await model.resume(recent) }
        } label: {
          HStack {
            Image(systemName: "arrow.uturn.forward.circle.fill").font(.title)
            VStack(alignment: .leading) {
              Text("Pick up where you left off").font(.headline)
              Text(
                "\(recent.mode.title) · \(recent.attempts.count) of \(recent.questions.count) answered"
              ).font(.subheadline)
            }
            Spacer()
            Image(systemName: "arrow.right")
          }.padding(T.lg).background(T.softGreen, in: RoundedRectangle(cornerRadius: T.card))
        }.buttonStyle(.plain)
      }
      SectionHeading(
        title: "Find your next idea",
        detail: "\(model.questions.count.formatted()) practice questions")
      LazyVGrid(columns: [GridItem(.adaptive(minimum: T.size("cardMinWidth")))], spacing: T.md) {
        ForEach(Array(model.topics.enumerated()), id: \.element) { i, topic in
          Button {
            Task { await model.start(topic: topic) }
          } label: {
            VStack(alignment: .leading, spacing: T.md) {
              HStack {
                Image(
                  systemName: [
                    "point.3.connected.trianglepath.dotted", "externaldrive", "network",
                    "memorychip", "chevron.left.forwardslash.chevron.right",
                  ][i % 5]
                ).font(.title2).foregroundStyle(T.primary)
                Spacer()
                Image(systemName: "arrow.up.right").foregroundStyle(T.muted)
              }
              Text(topic).font(.headline)
              Text(
                "\(model.questions.filter{$0.topic==topic}.count.formatted()) questions · learn by doing"
              ).font(.caption).foregroundStyle(T.muted)
            }.frame(maxWidth: .infinity, alignment: .leading).piyoCard()
          }.buttonStyle(.plain)
        }
      }
      SectionHeading(title: "Choose your pace")
      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: T.sm) {
          ForEach(DeliveryMode.allCases) { m in
            Button {
              mode = m
            } label: {
              Label(m.title, systemImage: m.symbol).font(.subheadline.weight(.semibold)).padding(
                T.md
              ).background(
                mode == m ? T.softGreen : T.surface, in: RoundedRectangle(cornerRadius: T.button)
              ).overlay(
                RoundedRectangle(cornerRadius: T.button).stroke(mode == m ? T.primary : T.line))
            }.buttonStyle(.plain)
          }
        }
      }
      HStack {
        Text(mode.detail).font(.subheadline).foregroundStyle(T.muted)
        Spacer()
        Button("Let's go") {
          if [.live, .collaborative].contains(mode) {
            model.selectedPage = "Rooms"
          } else {
            Task { await model.start(mode: mode) }
          }
        }.buttonStyle(PiyoButton())
      }
    }
  }
  private var heroText: some View {
    VStack(alignment: .leading, spacing: T.md) {
      Text("A CURIOUS MIND GROWS HERE").font(.caption.weight(.bold)).tracking(1.5).foregroundStyle(
        T.primary)
      Text("Small steps.\nDeeper understanding.").font(
        .system(.largeTitle, design: .rounded).bold()
      ).fixedSize(horizontal: false, vertical: true)
      Text(
        "Algorithms, systems, and the ideas behind good software. Learn a little with Piyo today."
      ).foregroundStyle(T.muted).fixedSize(horizontal: false, vertical: true)
      Button {
        Task { await model.start() }
      } label: {
        Label("Start today's practice", systemImage: "arrow.right")
      }.buttonStyle(PiyoButton()).disabled(model.busy)
    }.frame(maxWidth: .infinity, alignment: .leading)
  }
  private func stat(_ title: String, _ value: String, _ suffix: String, symbol: String) -> some View
  {
    VStack(alignment: .leading, spacing: T.xs) {
      Image(systemName: symbol).font(.caption).foregroundStyle(T.primary)
      Text(title).font(.caption).foregroundStyle(T.muted).fixedSize(
        horizontal: false, vertical: true)
      Text(value).font(.title.bold().monospacedDigit())
      Text(suffix).font(.caption).foregroundStyle(T.muted)
    }.frame(maxWidth: .infinity, alignment: .leading).padding(T.md).background(
      T.surface, in: RoundedRectangle(cornerRadius: T.card))
  }
}
struct LibraryScreen: View {
  @EnvironmentObject private var model: AppModel
  @State private var search = ""
  @State private var format: QuestionFormat?
  @State private var topic = "All topics"
  @State private var limit = 40
  private var filtered: [Question] {
    model.questions.filter {
      (format == nil || $0.format == format) && (topic == "All topics" || $0.topic == topic)
        && (search.isEmpty
          || ($0.prompt + " " + $0.topic + " " + ($0.context ?? ""))
            .localizedCaseInsensitiveContains(search))
    }
  }
  var body: some View {
    PageLayout(
      title: "A library for your curiosity",
      subtitle: "Original exercises, with sources you can follow."
    ) {
      if !model.publishedQuizzes.isEmpty {
        VStack(alignment: .leading, spacing: T.sm) {
          Label("Fresh quizzes", systemImage: "sparkles").font(.title2.bold())
          Text("New questions grounded in the growing source library.").font(.subheadline).foregroundStyle(T.muted)
          ForEach(model.publishedQuizzes.prefix(8)) { quiz in
            Button {
              let ids = Set(quiz.questionIds)
              Task { await model.start(exact: model.questions.filter { ids.contains($0.id) }) }
            } label: {
              HStack {
                VStack(alignment: .leading, spacing: 4) {
                  Text(quiz.title).font(.headline).multilineTextAlignment(.leading)
                  Text("\(quiz.topic) · \(quiz.questionIds.count) questions · \(quiz.createdAt.prefix(10))").font(.caption).foregroundStyle(T.muted)
                }
                Spacer()
                Image(systemName: "play.circle.fill").foregroundStyle(T.primary)
              }.padding(T.md).frame(maxWidth: .infinity).background(T.surface, in: RoundedRectangle(cornerRadius: 16))
            }.buttonStyle(.plain)
          }
        }
      }
      TextField("Search concepts, code, or topics", text: $search).textFieldStyle(.roundedBorder)
      HStack {
        Picker("Topic", selection: $topic) {
          Text("All topics").tag("All topics")
          ForEach(model.topics, id: \.self) { Text($0).tag($0) }
        }
        Picker("Format", selection: $format) {
          Text("All 18 formats").tag(nil as QuestionFormat?)
          ForEach(QuestionFormat.allCases) { Text($0.title).tag(Optional($0)) }
        }
      }.font(.subheadline)
      Text("\(filtered.count.formatted()) questions · parameterized exercises are labeled").font(
        .caption
      ).foregroundStyle(T.muted)
      LazyVStack(spacing: T.md) {
        ForEach(filtered.prefix(limit)) { q in
          VStack(alignment: .leading, spacing: T.sm) {
            HStack {
              Label(q.format.title, systemImage: q.format.symbol).font(.caption).foregroundStyle(
                T.primary)
              Spacer()
              Text(q.difficulty.capitalized).font(.caption).foregroundStyle(T.muted)
            }
            Text(q.prompt).font(.headline)
            if let context = q.context {
              Text(context).font(.caption.monospaced()).textSelection(.enabled)
            }
            HStack {
              Text(q.topic + (q.generation == nil ? "" : " · Parameterized")).font(.caption)
                .foregroundStyle(T.muted)
              Spacer()
              Button("Practice") { Task { await model.startQuestion(q) } }.buttonStyle(
                PiyoButton(secondary: true))
            }
          }.frame(maxWidth: .infinity, alignment: .leading).piyoCard()
        }
        if filtered.count > limit {
          Button("Show more questions") { limit += 40 }.buttonStyle(PiyoButton(secondary: true))
        }
      }
      if filtered.isEmpty { ContentUnavailableView.search(text: search) }
    }
  }
}
struct QuizScreen: View {
  @EnvironmentObject private var model: AppModel
  @Environment(\.dismiss) private var dismiss
  @State private var answer: [String] = []
  @State private var draftSave: Task<Void, Never>?
  var body: some View {
    VStack(spacing: T.none) {
      HStack {
        Button {
          Task {
            await model.persist()
            dismiss()
          }
        } label: {
          Label("Save & close", systemImage: "xmark")
        }.buttonStyle(.plain)
        Spacer()
        if let state = model.state {
          Label(state.mode.title, systemImage: state.mode.symbol).font(.subheadline)
          if let remaining = state.remaining {
            Text("\(Int(remaining)/60):\(String(format:"%02d",Int(remaining)%60))").font(
              .headline.monospacedDigit()
            ).foregroundStyle(T.primary)
          }
        }
      }.padding(T.lg)
      Divider()
      ScrollView {
        VStack(alignment: .leading, spacing: T.lg) {
          if let state = model.state {
            if state.complete {
              summary(state)
            } else if let q = state.current {
              HStack {
                Text("QUESTION \(state.cursor+1) OF \(state.questions.count)").font(.caption.bold())
                  .tracking(1)
                Spacer()
                Text(q.topic).font(.caption).foregroundStyle(T.muted)
              }
              ProgressView(value: Double(state.cursor), total: Double(state.questions.count))
              HStack {
                Label(q.format.title, systemImage: q.format.symbol).font(.caption).foregroundStyle(
                  T.primary)
                Spacer()
                if let due = state.dueAt {
                  Text("Due \(due.formatted(date:.abbreviated,time:.omitted))").font(.caption)
                }
              }
              Text(q.prompt).font(.title2.bold()).fixedSize(horizontal: false, vertical: true)
              if let context = q.context {
                Text(context).font(.body.monospaced()).frame(
                  maxWidth: .infinity, alignment: .leading
                ).padding(T.md).background(
                  T.background, in: RoundedRectangle(cornerRadius: T.button)
                ).textSelection(.enabled)
              }
              QuestionInput(question: q, answer: $answer).id(q.id).disabled(
                model.feedback != nil || model.busy
              ).environment(\.piyoAnimationsPaused, model.feedback != nil)
              if state.mode == .openBook, let url = URL(string: q.sourceURL), url.scheme == "https"
              {
                Link(destination: url) { Label("Open reference", systemImage: "book") }.font(
                  .subheadline)
              }
              if let result = model.feedback {
                feedback(result, q: q)
              } else {
                Button {
                  Task { await model.submit(answer) }
                } label: {
                  HStack {
                    Text(model.busy ? "Saving…" : "Check answer")
                    Spacer()
                    Image(systemName: "arrow.right")
                  }
                }.buttonStyle(PiyoButton()).disabled(model.busy || answer.isEmpty)
              }
            }
          }
        }.padding(T.lg).frame(maxWidth: T.size("quizWidth")).frame(maxWidth: .infinity)
      }
    }.background(T.surface).onAppear { restoreAnswer() }.onChange(of: model.state?.current?.id) {
      _, _ in restoreAnswer()
    }
    .onChange(of: answer) { _, value in
      draftSave?.cancel()
      draftSave = Task { await model.saveDraft(value) }
    }
    .task(id: model.state?.id) {
      while model.state?.remaining != nil, model.state?.complete == false, !Task.isCancelled {
        try? await Task.sleep(for: .seconds(1))
        await model.tick()
      }
    }
    #if os(macOS)
      .frame(
        minWidth: T.size("quizWidth"), idealWidth: T.size("quizIdealWidth"),
        minHeight: T.size("quizMinHeight"))
    #endif
  }
  private func restoreAnswer() {
    answer =
      model.state?.attempts.first { $0.questionId == model.state?.current?.id }?.answer ?? model
      .state?.draft ?? []
  }
  private func feedback(_ result: Evaluation, q: Question) -> some View {
    VStack(alignment: .leading, spacing: T.md) {
      HStack(spacing: T.md) {
        PiyoMascot(state: result.fraction == 1 ? .celebrating : .encouraging).frame(
          width: T.size("smallMascot"), height: T.size("smallMascot"))
        VStack(alignment: .leading) {
          Text(
            result.status == "pending_review"
              ? "Your reasoning is saved"
              : result.fraction == 1 ? "That’s the idea!" : "A useful step forward"
          ).font(.headline)
          Text(
            result.status == "pending_review"
              ? "Provisional · awaiting model review"
              : "\(Int(result.score)) / \(Int(result.maxScore)) points"
          ).font(.caption).foregroundStyle(T.muted)
        }
      }
      Text(result.feedback).font(.subheadline)
      if result.status == "pending_review" {
        Text(q.explanation).font(.subheadline)
        if !model.aiFeedbackEnabled {
          Text("AI feedback is off. You can enable it in Settings to send this written answer to Amazon Bedrock for grading.").font(.caption).foregroundStyle(T.muted)
        }
      }
      if !result.missingConcepts.isEmpty {
        Text("Consider: " + result.missingConcepts.joined(separator: ", ")).font(.caption)
      }
      if let url = URL(string: q.sourceURL), url.scheme == "https" {
        Link(q.sourceTitle ?? "Explore the source", destination: url).font(.caption)
      } else if let title = q.sourceTitle {
        Text("Source: " + title + " · private reference").font(.caption).foregroundStyle(T.muted)
      }
      Button {
        Task {
          await model.next()
          answer = []
        }
      } label: {
        Label("Continue", systemImage: "arrow.right")
      }.buttonStyle(PiyoButton())
    }.piyoCard(T.softGreen)
  }
  private func summary(_ state: SessionState) -> some View {
    VStack(spacing: T.lg) {
      PiyoMascot(state: .celebrating).frame(
        width: T.size("heroMascot"), height: T.size("heroMascot"))
      Text("A little wiser already.").font(.largeTitle.bold())
      Text("You worked through \(state.attempts.count) of \(state.questions.count) questions.")
        .foregroundStyle(T.muted)
      Text(
        "\(Int((state.earned/Double(state.questions.count)*100).rounded()))% mastery this session"
      ).font(.title2.bold())
      if state.attempts.contains(where: { $0.result.status == "pending_review" }) {
        Text("Written-answer scores are provisional until reviewed.").font(.caption)
      }
      Button("Back to learning") { dismiss() }.buttonStyle(PiyoButton())
      ForEach(state.attempts) { attempt in
        if let q = state.questions.first(where: { $0.id == attempt.questionId }) {
          VStack(alignment: .leading, spacing: T.xs) {
            Text(q.prompt).font(.headline)
            Text(q.explanation).font(.subheadline).foregroundStyle(T.muted)
          }.frame(maxWidth: .infinity, alignment: .leading).piyoCard(T.background)
        }
      }
    }.frame(maxWidth: .infinity)
  }
}
struct ProgressScreen: View {
  @EnvironmentObject private var model: AppModel
  var body: some View {
    PageLayout(
      title: "See how far you’ve come", subtitle: "Every attempt adds to your understanding."
    ) {
      HStack {
        VStack(alignment: .leading, spacing: T.xs) {
          Text("\(model.attempts.count.formatted()) questions explored").font(.title2.bold())
          Text("\(model.accuracy)% overall · \(model.streak)-day streak").foregroundStyle(T.muted)
        }
        Spacer()
        Button("Revisit mistakes") { Task { await model.start(review: true) } }.buttonStyle(
          PiyoButton(secondary: true))
      }.piyoCard(T.softGreen)
      if model.history.isEmpty {
        ContentUnavailableView(
          "Your story starts here", systemImage: "leaf",
          description: Text("Complete a practice question to start tracking your progress."))
      }
      ForEach(model.history) { session in
        Button {
          Task { await model.resume(session) }
        } label: {
          HStack(spacing: T.md) {
            Image(systemName: session.complete ? "checkmark.circle.fill" : "clock").font(.title2)
              .foregroundStyle(T.primary)
            VStack(alignment: .leading, spacing: T.xs) {
              Text(session.mode.title).font(.headline)
              Text(session.savedAt.formatted(date: .abbreviated, time: .shortened)).font(.caption)
                .foregroundStyle(T.muted)
            }
            Spacer()
            Text("\(session.attempts.count)/\(session.questions.count)").monospacedDigit()
            Image(systemName: "chevron.right")
          }.piyoCard()
        }.buttonStyle(.plain)
      }
      Label(
        model.queueCount == 0
          ? "No answers waiting to sync" : "\(model.queueCount) answers saved for sync or review",
        systemImage: "externaldrive.badge.icloud"
      ).font(.caption).foregroundStyle(T.muted)
    }.task { await model.load() }
  }
}
struct RoomsScreen: View {
  @EnvironmentObject private var model: AppModel
  var body: some View { RoomContent(model: model, live: model.live, auth: model.auth) }
}
struct RoomContent: View {
  @ObservedObject var model: AppModel
  @ObservedObject var live: LiveClient
  @ObservedObject var auth: AuthService
  @State private var code = ""
  @State private var name = "Learner"
  @State private var answer: [String] = []
  @State private var cursor = 0
  @State private var busy = false
  @State private var submitted = false
  var body: some View {
    PageLayout(
      title: "Better together", subtitle: "A small study room. A shared sense of discovery."
    ) {
      if auth.tokens == nil {
        VStack(alignment: .leading, spacing: T.md) {
          Label("Sign in to create or join a room", systemImage: "person.crop.circle").font(
            .title2.bold())
          Text(
            "Practice is always available offline. Rooms use your account to keep contributions and scores together."
          ).foregroundStyle(T.muted)
          Button("Sign in") { Task { await model.signIn() } }.buttonStyle(PiyoButton())
        }.piyoCard(T.softYellow)
      } else if let room = live.room {
        HStack {
          Label(
            room.mode == "collaborative" ? "Study together" : "Live quiz", systemImage: "person.2"
          ).font(.headline)
          Spacer()
          Button("Leave room") {
            live.close()
            cursor = 0
            submitted = false
            answer = []
          }
        }
        Text(room.id).font(.caption.monospaced()).textSelection(.enabled)
        ShareLink("Share room code", item: room.id)
        Text(live.status).font(.caption).foregroundStyle(T.muted)
        ForEach(room.participants.sorted { $0.score > $1.score }) { p in
          HStack {
            Label(p.name, systemImage: "person.crop.circle")
            Spacer()
            Text("\(p.score) pts").font(.headline.monospacedDigit())
          }.padding(T.md).background(T.softGreen, in: RoundedRectangle(cornerRadius: T.button))
        }
        if cursor < room.questionIds.count,
          let q = model.questions.first(where: { $0.id == room.questionIds[cursor] })
        {
          Text(q.prompt).font(.title2.bold())
          QuestionInput(question: q, answer: $answer).id(q.id).disabled(submitted || busy)
          if submitted {
            Text("Answer recorded").foregroundStyle(T.primary)
            Button("Next question") {
              cursor += 1
              answer = []
              submitted = false
            }.buttonStyle(PiyoButton())
          } else {
            Button("Share answer") {
              perform {
                try await live.submit(question: q, answer: answer, auth: auth)
                submitted = true
              }
            }.buttonStyle(PiyoButton()).disabled(answer.isEmpty || busy)
          }
        } else {
          Text("You’ve completed this room’s questions.").font(.title2.bold())
        }
        if room.mode == "collaborative" {
          SectionHeading(title: "Shared contributions")
          ForEach(Array(live.contributions.enumerated()), id: \.offset) { _, text in
            Text(text).font(.subheadline).padding(T.sm)
          }
        }
      } else {
        TextField("Your display name", text: $name).textFieldStyle(.roundedBorder)
        HStack {
          Button("Create live quiz") {
            perform { try await live.open(mode: "live", name: name, auth: auth) }
          }.buttonStyle(PiyoButton())
          Button("Study together") {
            perform { try await live.open(mode: "collaborative", name: name, auth: auth) }
          }.buttonStyle(PiyoButton(secondary: true))
        }.disabled(busy)
        VStack(alignment: .leading, spacing: T.md) {
          Text("Have an invitation?").font(.headline)
          TextField("Paste room code", text: $code).textFieldStyle(.roundedBorder)
          Button("Join room") {
            perform {
              try await live.join(
                id: code.trimmingCharacters(in: .whitespacesAndNewlines), name: name, auth: auth)
            }
          }.buttonStyle(PiyoButton(secondary: true)).disabled(busy || code.isEmpty)
        }.piyoCard()
        Text("Up to 12 learners · rooms expire after two hours").font(.caption).foregroundStyle(
          T.muted)
      }
    }
  }
  private func perform(_ action: @escaping @MainActor () async throws -> Void) {
    busy = true
    Task {
      defer { busy = false }
      do { try await action() } catch { model.error = error.localizedDescription }
    }
  }
}
struct SettingsScreen: View {
  @EnvironmentObject private var model: AppModel
  @State private var confirmErase = false
  @AppStorage("soundEnabled") private var sound = false
  @AppStorage("diagnosticsEnabled") private var diagnostics = false
  var body: some View {
    PageLayout(title: "Make yourself at home", subtitle: "A calm space for your learning routine.")
    {
      AccountCard(model: model, auth: model.auth)
      VStack(alignment: .leading, spacing: T.lg) {
        Toggle("Gentle original music", isOn: $sound).onChange(of: sound) { _, enabled in
          if enabled {
            try? SoundPlayer.shared.play("focus", loop: true)
          } else {
            SoundPlayer.shared.stop()
          }
        }
        Toggle("Practice offline", isOn: $model.offlinePractice)
        Text(
          "Your current session and answers stay on this device. Turn this off to resume syncing when connected."
        ).font(.caption).foregroundStyle(T.muted)
        Label(
          model.online ? "Network available" : "Offline — keep learning",
          systemImage: model.online ? "wifi" : "wifi.slash"
        ).font(.caption)
        Text(model.syncStatus).font(.caption).foregroundStyle(T.muted)
        Button("Sync now") { Task { await model.sync() } }.buttonStyle(PiyoButton(secondary: true))
      }.piyoCard()
      VStack(alignment: .leading, spacing: T.md) {
        Toggle("Share aggregate diagnostics", isOn: $diagnostics)
        Text(
          "Off by default. Sends counts of sessions, rendering failures, and queued answers. Written answers are not included."
        ).font(.caption).foregroundStyle(T.muted)
        Button("Send diagnostic counts") { Task { await model.diagnostics() } }.disabled(
          !diagnostics)
      }.piyoCard()
      VStack(alignment: .leading, spacing: T.md) {
        Toggle("Use Amazon Bedrock for AI feedback", isOn: Binding(get: { model.aiFeedbackEnabled }, set: { model.setAIFeedback($0) }))
        Text("When enabled, your queued and future written answers are sent to Amazon Bedrock with the question and rubric for automated grading. Feedback may be wrong. Leave this off to keep written answers on this device. Avoid including personal information or secrets.").font(.caption).foregroundStyle(T.muted)
      }.piyoCard()
      PrivacyCard()
      Group {
        Button("Erase practice saved on this device", role: .destructive) { confirmErase = true }
          .confirmationDialog("Erase this device’s practice?", isPresented: $confirmErase) {
            Button("Erase practice", role: .destructive) { Task { await model.eraseGuestProgress() } }
          } message: { Text("This signs you out and permanently removes the current account’s local answers, including anything not yet synced. Cloud data and other accounts are unchanged.") }
      }
      SourcesCard()
      Text(
        "PiyoPiyo · 1.0 release candidate\nOriginal exercises and audio. Written-answer estimates remain provisional until reviewed."
      ).font(.caption).foregroundStyle(T.muted)
    }
  }
}
struct AccountCard: View {
  @ObservedObject var model: AppModel
  @ObservedObject var auth: AuthService
  @State private var confirmDeletion = false
  var body: some View {
    VStack(alignment: .leading, spacing: T.md) {
      Label(
        auth.tokens == nil ? "Learn now. Sync when you’re ready." : "Your learning account",
        systemImage: "person.crop.circle"
      ).font(.title2.bold())
      Text(
        auth.tokens == nil
          ? "Sign in to sync practice. Written answers upload only when you enable AI feedback in Settings."
          : "Your sign-in is stored securely on this device."
      ).font(.subheadline).foregroundStyle(T.muted)
      Button(auth.tokens == nil ? "Sign in or create account" : "Sign out") {
        Task { if auth.tokens == nil { await model.signIn() } else { await model.signOut() } }
      }.buttonStyle(PiyoButton()).disabled(model.busy)
      if auth.tokens != nil {
        Button("Delete account", role: .destructive) { confirmDeletion = true }
          .disabled(model.deletingAccount)
          .confirmationDialog("Permanently delete your PiyoPiyo account?", isPresented: $confirmDeletion) {
            Button("Delete account and progress", role: .destructive) { Task { await model.deleteAccount() } }
          } message: {
            Text("This removes your account, cloud answers, progress, and room contributions, plus this account’s data on this device. It cannot be undone. Internet access is required. Copies on other devices must be erased there. Recoverable server backups expire within seven days.")
          }
      }
      if model.deletingAccount { ProgressView("Deleting account…") }
    }.piyoCard(T.softYellow)
  }
}
struct SourcesCard: View {
  struct Source: Decodable, Identifiable {
    let id: String
    let title: String?
    let url: String
    let status: String?
    let kind: String
  }
  private static let acquired: [Source] = {
    guard let url = Bundle.module.url(forResource: "provenance", withExtension: "json"),
      let data = try? Data(contentsOf: url)
    else { return [] }
    return ((try? JSONDecoder().decode([Source].self, from: data)) ?? []).filter {
      $0.status == "acquired"
    }
  }()
  var body: some View {
    DisclosureGroup("Sources & original assets") {
      VStack(alignment: .leading, spacing: T.md) {
        ForEach(Self.acquired) { source in
          if let url = URL(string: source.url) {
            Link(source.title ?? source.id, destination: url).font(.subheadline)
          }
        }
        Text(
          "The app bundles original questions and generated audio, not reference PDFs, screenshots, or soundtrack recordings."
        ).font(.caption).foregroundStyle(T.muted)
      }
    }.piyoCard()
  }
}
extension AppModel {
  func startQuestion(_ q: Question) async { await start(exact: [q]) }
}

struct PrivacyCard: View {
  var body: some View {
    DisclosureGroup("Privacy & your data") {
      VStack(alignment: .leading, spacing: T.md) {
        Text("Guest practice stays on your device. Signing in uploads your saved quiz progress; written answers upload only with AI feedback enabled to PiyoPiyo’s dedicated AWS services in the United States. Your email and account identifier support sign-in and sync.")
        Text("Written answers and their rubrics are sent to Amazon Bedrock for automated feedback. Do not include passwords or other sensitive information in answers. Feedback can be wrong; consult the linked sources.")
        Text("Rooms share your chosen display name and score with members. Collaborative rooms also share answers. Room records expire after two hours; database cleanup may take up to several days.")
        Text("No advertising or cross-app tracking. Optional aggregate diagnostics are off by default. Operational logs expire after seven days. Learning records remain until you delete your account; recoverable backups expire within seven days. A temporary account identifier blocks old sign-in tokens for 24 hours after deletion, then expires.")
        Text("Delete your account in Settings to remove cloud data. Use Erase practice saved on this device to clear local progress. Signing out alone keeps progress on this device for your next sign-in. Other devices may retain offline copies until erased there.")
      }.font(.subheadline).textSelection(.enabled).padding(.top, T.sm)
    }.piyoCard()
  }
}
