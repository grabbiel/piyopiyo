# Multi-phase plan: bugs, arm64 perf, corpus, minigames

Goal: after mapping the Codex-built PiyoPiyo stack, land fixes for real bugs, replace non-native patterns on arm64 Apple targets, decide where C/ObjC/C++/Go beat Python/JS, grow the quiz corpus with real concept coverage, and design 100 SpriteKit plus 100 SceneKit minigames that plug into the existing formats.

This file is the deliverable. Execution starts only on an explicit operator go.

## What changes for the learner

- Broken CI and game-content coupling stop blocking later releases.
- 2D and 3D modes stop being single-question demos.
- Practice volume grows with authored multi-format items, not only more loop-count numerics.
- Minigames become a template catalog the app can ship without 200 one-off Swift scenes.

## Settled decisions (prototyped)

Throwaway evidence lives in `/tmp/piyopiyo-minigame-proto/`.

| Fork | Choice | Why |
| --- | --- | --- |
| Minigame authorship | Template registry + `game.template` / `game.params` on questions (Variant B) | Repo already has one SpriteKit scene and one SceneKit scene. Scaling to 200 hardcoded classes fails review cost. Role shapes must not key off option index. |
| Corpus growth | Author multi-format items in `scripts/build_questions.py` + `content/concepts.json`; keep parameterized numerics labeled | Bank is 45 authored + 1070 parameterized. Topics skew to Programming (912). More `loops-a-b` does not expand concepts. |
| Native games runtime | Stay on SpriteKit / SceneKit; add templates, not Metal engines first | App already imports both. Metal earns a later PR only if Instruments shows GPU or CPU limits on those templates. |
| Faster languages | Prefer for offline/batch and Lambda hot loops named below; keep SwiftUI shell and Node API boundary | Measured stack already uses arm64 Lambda Node and native Swift clients. |

## Evidence baseline (measured 2026-11-23)

- `npm test`: 56 pass, 1 fail, process exit 1. Fail: `fixed-name Lambda code updates do not invalidate dependent IAM policies or integrations` in `tests/infrastructure.test.cjs:16` with `TypeError: Cannot read properties of undefined (reading 'some')` because synth `DependsOn` is missing on Lambda permissions and HTTP integrations in `cdk.out/PiyoPiyoDev.template.json` even though `infra/app.ts` calls `addDependency`.
- `swift test --package-path PiyoPiyo/PiyoPiyoCore`: 18 pass, 0 fail.
- Corpus: 1115 questions. Formats: numeric 1071, multiple_choice 28, every other format 1 each including `game_2d` and `game_3d`.
- Authored topics: Programming 12, Algorithms 10, Distributed systems 9, Databases 8, Operating systems 6. Hard authored items: 1.
- 3D demo `architecture-3d` correct answer is index 2. `architectureScene` always draws a cylinder at index 2 in `QuestionViews.swift`. Visual icons also key off index. New 3D items break the visual metaphor unless roles are content-driven. Falling blocks at `x = 80 + i*140` overflow a 600-wide scene past 4 options.
- Game modes filter to `game_2d` / `game_3d` only (`AppModel.start`). With one item each, a ten-question session cannot exist.
- Default practice uses `questions.prefix(18)`, so daily practice is the first format showcase slice, not a topic-balanced sample of the bank.
- Revisit-mistakes keeps every historically incomplete id, including provisional keyword open answers, so the pool does not clear after mastery (`AppModel.swift`).
- Live rooms render multiple choice only while ~96% of the bank is numeric (inferred broken room draws). Live subscription `start` may be sent as a binary WebSocket frame where AppSync expects text (`Networking.swift`). Contribution UI shows JSON arrays. Display name is ignored on room create.
- Dead refresh tokens are kept after 400→401 mapping, so sync retries every ~30s (`Networking.swift`, `RootView.swift`).
- Draft keystrokes rewrite SQLite with `synchronous=FULL` and merge-decode all sessions (`RootView` → `LocalStore`). `load()` re-decodes the ~610 KB bank after start/submit/next. `SourcesCard` re-decodes `provenance.json` every body pass. A 1 Hz timer republishes quiz `state` even when untimed. Mascot `TimelineView` runs at 20 fps in the sidebar.
- SourcesDesk duplicates Auth from `Networking.swift` (`SourcesDesk/.../Authentication.swift`), with drift risk and no tests.
- Knowledge PDF Lambda is already Python (`backend/pdf`). Offline embeddings use Transformers.js (`scripts/embed.mjs`). Seeds/vectors are not read at app runtime.
- Backend (from [backend map](15a7d29c-24de-47be-a271-2d60de41bd25)): no merge-safe publish from `content/questions.json` to S3 `published/questions.json` (local Resources copy is hand-synced; a naive upload would wipe generated and `retired` items). Authored open answers ship 3 `criteria` while `validateQuestion` requires 5. `createRoom` always takes the first 10 multiple-choice items (`backend/index.cjs`). Scoring exists in both `index.cjs` and `Models.swift` with small drift risk. API Lambda `reservedConcurrentExecutions:2` is shared by HTTP, AppSync rooms, and Bedrock grading. Account deletion rooms phase pages a full-table Scan. Parameterized loop items default `sourceId` to `mit-algorithms` when unset.
- [Probe tests and perf](32dea1d9-4c4c-40ee-9f4d-a230ca7d62a2) also noted 60 Swift force-unwrap matches (hot ones in `Networking.swift` config/URL paths), grading p95 measured workstation→Bedrock only, and that `docs/release-status.md` still cites an older test count. Its claim that `npm test` exits 0 on failure is wrong; remeasured exit code is 1.
- Apple iPhone/iPad 1.1.0 (5) is Waiting for Review (`BLOCKED.md`). Mac 1.1.0 (4) is notarized. No local upload failure remains.

## PR landing order and dependency graph

Independent from `main` (can open in parallel after PR1 lands if preferred; safer serial for CI noise):

```text
main
  └─ PR1  fix/infra-dependson-test          (blocks honest CI)
        ├─ PR2  fix/learner-bugs-games-auth-live
        ├─ PR3  feat/game-template-schema     (needs PR2 shape)
        │         ├─ PR6  docs/minigames-2d-100   (design catalog; needs schema)
        │         └─ PR7  docs/minigames-3d-100   (design catalog; needs schema)
        ├─ PR4  feat/corpus-authored-expansion   (includes merge-safe S3 publish)
        ├─ PR5  perf/arm64-native-patterns
        └─ PR8  docs/faster-language-map      (analysis + optional PoC harness)
```

Review-gated before merge: PR2 (interaction bugs), PR3 (schema touches Question Codable and bank), PR6, PR7 (product surface), PR4 if it changes published bank hashes that App Store builds embed.

## PR1. Restore honest infrastructure gate

- Depends on: nothing
- Files: `tests/infrastructure.test.cjs`, possibly `infra/app.ts`, `infra/knowledge.ts`, `package.json` test script, regenerated `cdk.out/`
- One change: make the fixed-name Lambda dependency assertion match the intended pattern. Prefer restoring explicit `DependsOn` in synth if `addDependency` is dropped. If CloudFormation already gets an implicit `Ref` edge, assert that edge and fail with a clear message instead of calling `.some` on `undefined`.
- Result: `npm test` reports 57 pass, 0 fail.
- Verification:
  - [ ] Unit: `npm test`
  - [ ] Live: `npm run synth` then re-read permissions/integrations in `cdk.out/PiyoPiyoDev.template.json` and confirm either non-empty `DependsOn` containing the function logical id, or documented `Ref`/`Fn::Join` ARN edges the test accepts
  - [ ] Perf: n/a (infra assertion only). Probe: none. Fail if synth time grows over 2× trunk wall clock on the same machine

## PR2. Fix learner-facing bugs (games, practice, auth, live)

- Depends on: PR1 preferred
- Files: `QuestionViews.swift`, `AppModel.swift`, `RootView.swift`, `Networking.swift`, `scripts/build_questions.py`, `content/questions.json`, Swift tests
- One change: ship the smallest set of user-hit fixes together.
  - Map 3D shapes and visual icons by option role or label, not index. Keep falling-block layout inside scene bounds for the option counts you ship.
  - Add at least 10 authored `game_2d` and 10 `game_3d` items so modes can fill a session.
  - Replace `questions.prefix(18)` practice selection with a balanced sample across topics and formats.
  - Clear revisit-mistakes once the learner later scores full marks on that id, and exclude `pending_review` from accuracy or label it.
  - Clear tokens on refresh auth failure so sync stops hammering.
  - Fix live room answer UI for non-MC formats or exclude non-MC from room draws. Stop `createRoom` from always using the first 10 multiple-choice ids; sample a fresh MC pool. Fix subscription start framing if binary is confirmed wrong. Stop showing raw JSON arrays for contributions.
- Result: 2D/3D sessions have content. Practice varies. Dead sessions stop looping auth errors. Rooms remain answerable and do not always show the same ten questions.
- Verification:
  - [ ] Unit: `swift test --package-path PiyoPiyo/PiyoPiyoCore`; `python3 scripts/build_questions.py`
  - [ ] Live: Mac Debug app. Run practice twice and confirm different pools. Finish 2D and 3D sessions of length greater than 1. Force a bad refresh token and confirm sync stops and prompts sign-in. Create a room and answer without JSON blobs in the UI.
  - [ ] Perf: Instruments Time Profiler on one 3D orbit gesture. Trunk baseline first. Fail if mean frame time on M-series exceeds 16.7 ms for 2 consecutive seconds while idle-orbiting

## PR3. Game template schema (scaffold only)

- Depends on: PR2
- Files: `Models.swift` (`Question` optional `game`), `QuestionViews.swift` template switch, `scripts/build_questions.py`, content fixtures, docs note
- One change: add optional `game: { template, params }` as sketched in `/tmp/piyopiyo-minigame-proto/schema-sketch.json`. Register the existing falling_blocks and system_architecture templates behind that key. Default when absent remains today’s behavior.
- Result: new questions can choose a template without new SwiftUI wrappers.
- Verification:
  - [ ] Unit: decode old bank JSON without `game`; decode new fixture with `game`; snapshot still covers both formats
  - [ ] Live: one `game_2d` with template field and one without both render and grade in the Mac app
  - [ ] Perf: bank load time for 1115+ items. Probe: log `ContinuousClock` around `Question.bundled()`. Trunk baseline first. Fail if p50 load rises more than 20% on the same Mac

## PR4. Expand authored corpus

- Depends on: PR1 preferred; independent of PR3
- Files: `content/concepts.json`, `scripts/build_questions.py`, `content/questions.json`, new merge-safe publish script, bundled `Resources/questions.json`, provenance if new sources, open-answer criteria alignment with `backend/knowledge` validator
- One change: add a bounded authored batch (target +80 to +120 non-parameterized items) across Algorithms, OS, Databases, Distributed systems, and under-covered formats (matching, ordering, short answer, visual). Do not add another 900 nested-loop numerics. Keep `generation: parameterized` only for math-checked variants. Align open-answer `criteria` count with `validateQuestion` (5 facts). Add a merge-safe publish path that reads S3, merges by id, keeps `retired` and generated rows, and writes conditional on ETag. Fix wrong default `sourceId` on parameterized items. Add JS-versus-Swift scoring fixture parity for deterministic formats.
- Result: authored count moves from 45 toward ~150. Hard items increase. Topic share of Programming among authored falls. Local bank can update cloud without wiping pipeline output.
- Verification:
  - [ ] Unit: `python3 scripts/build_questions.py` asserts unique ids and 18 formats; backend scoring tests still pass; new parity fixtures pass on both scorers; authored open items pass `validateQuestion`
  - [ ] Live: practice session on each new topic shows prompts tied to cited `sourceURL`; dry-run publish against a non-prod bank copy preserves an injected generated id and a `retired` flag
  - [ ] Perf: app cold start to Learn tab. Trunk baseline first. Fail if time-to-interactive rises more than 15% after bank growth

## PR5. Arm64 native pattern fixes

- Depends on: PR2 for game pause behavior; PR3 if templates are in flight
- Files: `RootView.swift`, `AppModel.swift`, `LocalStore.swift`, `Theme.swift`, `QuestionViews.swift`, SourcesDesk auth share if in scope
- One change: remove wrong client patterns on Apple arm64.
  - Stop per-keystroke full-session merge writes. Debounce drafts or write only the active session row.
  - Stop re-decoding the full bank on every `load()` after local mutations. Cache bank separately from session/queue reads.
  - Decode bundled and server banks off the main actor.
  - Cache provenance decode for `SourcesCard`. Avoid O(n) topic filters on every Home/Library body pass.
  - Drive the 1 Hz quiz tick only when `isTimed` and a timer is visible.
  - Gate mascot `TimelineView` when off-screen or Reduce Motion is on.
  - Prefer `SKSpriteNode` textures over many `SKShapeNode` fills. Replace heavy `SCNText` extrusion with billboarded SpriteKit/Core Text labels where needed. Pause game loops after feedback.
  - Keep embeddings and PDF extract out of the learner app binary.
- Result: typing a draft does not fsync the whole store each key. Untimed quizzes do not tick at 1 Hz. Games use native frameworks only.
- Verification:
  - [ ] Unit: Swift tests + format snapshots
  - [ ] Live: Mac and iPhone SE simulator. Type a short-answer draft and confirm UI stays responsive. Open game modes with Reduce Motion on and off. Confirm mascot is still when Reduce Motion is on.
  - [ ] Perf: Instruments Time Profiler and Energy on a 60s untimed practice and a 60s 2D session. Trunk baselines first. Fail if average CPU on untimed practice exceeds trunk by 25%, or if FallingScene average CPU exceeds trunk by 25% after template work

## PR6. Design catalog: 100 SpriteKit (2D) minigames

- Depends on: PR3
- Files: `docs/minigames-2d-catalog.md` (or split files under `docs/minigames/2d/`), optional JSON seed list
- One change: write 100 designs, each with id, learning objective, topic, template id from the registry (or `needs_new_template`), prompt sketch, options, correct answer, params, accessibility fallback (always the Choices list), and estimate of new Swift work if template missing. Prefer reuse of ~8–12 templates.
- Result: a reviewable catalog an owner can approve before implementation waves.
- Verification:
  - [ ] Unit: script counts exactly 100 entries and unique ids
  - [ ] Live: operator reads 10 sampled designs for pedagogy fit (review gate)
  - [ ] Perf: n/a for docs. Fail if more than 40 designs require a brand-new template (registry discipline)

## PR7. Design catalog: 100 SceneKit (3D) minigames

- Depends on: PR3
- Files: `docs/minigames-3d-catalog.md` (or `docs/minigames/3d/`)
- One change: same structure as PR6 for 3D. Every design names shape roles explicitly. No index-coupled geometry.
- Result: 100 reviewable 3D designs complementary to the quiz bank.
- Verification:
  - [ ] Unit: count 100, unique ids, every entry has `roles` or equivalent params
  - [ ] Live: operator review gate on 10 samples
  - [ ] Perf: n/a for docs. Same new-template budget as PR6

## PR8. Faster-language map (and optional PoC)

- Depends on: PR1 preferred
- Files: `docs/faster-language-map.md`, optional `artifacts/poc/` harness
- One change: document where C, Objective-C, C++, or Go should replace Python/NPM+JS, with keep/move/defer.

Recommended map (inference from current tree; PoC may revise):

| Area | Today | Proposal |
| --- | --- | --- |
| Learner UI, games, SQLite store | Swift / SpriteKit / SceneKit / CSQLite | Keep. Expand native templates. |
| API + grading Lambda | Node 22 arm64, concurrency 2 shared with rooms | Keep language. Split or raise concurrency only after measuring room/sync starvation under concurrent grades. Shared scoring fixtures beat a Go rewrite for correctness. |
| Knowledge PDF extract | Python Lambda (`backend/pdf`, pypdf) | Keep until PDF CPU dominates the $15 budget. Then consider a Go or C++ Lambda with a streaming parser. |
| Offline embeddings | `scripts/embed.mjs` + Transformers.js / ONNX | Prefer a one-shot native or Python batch job on Apple Silicon for local regen. Do not ship ONNX in the app. |
| Question generation scripts | Python (`build_questions.py`, `curate.py`) | Keep Python for authoring. Optional Go only if bank build time becomes a CI bottleneck. |
| Icon / audio codegen | Swift / Python | Keep. |
| Infra | TypeScript CDK | Keep. |

- Result: an owner-facing decision record. Optional PoC only if a named bottleneck is measured.
- Verification:
  - [ ] Unit: doc links to real paths
  - [ ] Live: if PoC ships, run it once on this Mac and paste timings into the doc
  - [ ] Perf: any PoC must use **Explain the Number**. Name the limiter. Fail if the PoC measures process startup instead of the hot loop

## Out of scope until later waves

- Implementing all 200 minigames in Swift.
- Retraining or fine-tuning model weights.
- App Store resubmission while 1.1.0 iOS is Waiting for Review, unless a blocking user bug appears.
- Force-push, production data deletion, or customer messages.

## Unproven

- Whether `addDependency` is dropped by the current CDK version or `cdk.out` is stale relative to `infra/*.ts` (PR1 settles this with a fresh synth).
- Real device GPU cost of many SceneKit templates (PR5 Instruments).
- Whether Bedrock grading latency regresses when corpus open-ended items grow (watch existing p95 gate, currently 1,556 ms attested). Workstation→Bedrock p95 omits API Gateway and Lambda cold path.
- Pedagogy quality of the 200 designs until the operator review gates on PR6/PR7.
- Whether live subscription binary frames are actually rejected in production (inferred from AppSync docs; confirm in PR2 live check).
- How far local bundled bank has already drifted from S3 `published/questions.json` (PR4 dry-run).

## Operator go

Reply with which PR ids to execute (for example `PR1–PR4` or `all`). No code for those PRs lands before that.
