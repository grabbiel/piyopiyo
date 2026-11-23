# PiyoPiyo

A native computer-science practice app for iPhone, iPad, and Mac. It includes 18 question formats, eight learning modes, 1,115 original exercises, offline progress, Apple/email sign-in, cloud sync, optional Bedrock feedback, and shared study rooms.

**1.1.0 adds a growing cloud library and fresh quizzes.** iPhone/iPad build 5 is Waiting for Review in App Store Connect, with manual public release. Mac build 4 is notarized and stapled. Apple login and synchronization were verified with the owner. The grader matches 47/50 owner-reviewed scores (94%, p95 1,556 ms). The owner accepted the tested device coverage. See [release status](docs/release-status.md).

## Run or install

- Mac: unzip `artifacts/release/PiyoPiyo-1.1.0.zip`, then open `PiyoPiyo.app`.
- Sources companion: unzip `artifacts/release/PiyoPiyo-Sources-1.0.1.zip`. It is also installed in `~/Applications`, with a separate mint-and-teal library icon.
- iPhone/iPad: `artifacts/release/1.1.0-iOS/PiyoPiyo-iOS.ipa` is signed for App Store Connect/TestFlight distribution, not direct device installation.
- Development: open `PiyoPiyo/PiyoPiyo.xcodeproj`; choose `PiyoPiyo-macOS`, `PiyoPiyo-iOS`, or `PiyoPiyo-iPadOS`. Minimum versions are macOS 14 and iOS/iPadOS 17.

```sh
xcodebuild -project PiyoPiyo/PiyoPiyo.xcodeproj \
  -scheme PiyoPiyo-macOS -configuration Debug \
  -derivedDataPath DerivedData/mac CODE_SIGNING_ALLOWED=NO build
open DerivedData/mac/Build/Products/Debug/PiyoPiyo.app
```

Practice works immediately without an account. Settings provides sign-in, original music, offline practice, privacy choices, and account deletion. Guest progress moves into the account on sign-in. AI feedback is off by default for each account: written answers remain on the device until the learner explicitly enables it. Room codes let signed-in learners join a shared ten-question session; rooms support 12 members and expire after two hours.

## Background learning and source sharing

PiyoPiyo Sources is installed in `~/Applications/PiyoPiyo Sources.app`; the updated learner app is alongside it. Use your existing Apple sign-in. Add public links, PDFs, or text files, inspect processing and question batches, and pause the pipeline or withdraw a published batch when needed. Originals stay private.

Cloud discovery runs Monday, Wednesday, and Friday at 09:30 in Lima; question generation runs at 10:30. Validated questions publish automatically into **Library → Fresh quizzes**. The pipeline caps generation at 60 model calls per month and retains the existing $15 total app budget alerts. It grows the source corpus and question bank without retraining model weights. See [the source-library guide and operations runbook](docs/knowledge-pipeline.md).

## Learning behavior

- Formats: multiple choice/select, true/false, fill blank, short answer, matching, categorization, ordering, dropdown, numeric, visual, drag-and-drop, audio, SpriteKit 2D, SceneKit 3D, live quiz, homework, and collaborative answers.
- Modes: practice, timed five-minute sprint, open book, resumable homework, 2D, 3D, live, and collaborative.
- Answers, drafts, remaining time, and queued sync work are saved locally. Timed answers can sync after the timer expires without being discarded. Server reconciliation preserves canonical answers and reviewed scores.
- Cognito identities isolate progress by account. Submissions are idempotent. Account deletion removes progress and room contributions, revokes Apple access when applicable, and blocks old access tokens from recreating data.
- The bank contains 45 authored exercises and 1,070 labeled parameterized variants. This is practice volume, not 1,115 separately researched concepts. Nine public sources, 80 extracted chunks/seeds, and MiniLM embeddings are stored privately. Unreviewed seeds are not published as questions.

## Checks and development

```sh
npm ci
npm run typecheck
npm run synth
npm test
npm run verify:grading
swift test --package-path PiyoPiyo/PiyoPiyoCore
```

The current checks include 50 backend/infrastructure/release-gate tests plus three PDF extraction tests, 18 Swift tests per platform, and 54 format snapshots. Use `PiyoPiyo-iPhoneTests` with iPhone SE (3rd generation) and `PiyoPiyo-iPadTests` with iPad mini (A17 Pro). Xcode 27 / Swift 6.4, Swift 5 language mode, and SnapshotTesting 1.19.7 were used. Baselines depend on OS/runtime. Regenerate the project with `xcodegen generate --spec PiyoPiyo/project.yml`.

Real AWS integration creates temporary learners without sending email, verifies scoring/sync/deletion and three concurrent AppSync participants, then removes test data:

```sh
aws sso login --profile admin
npm run test:integration
```

The paid human regression command and its limitations are documented in [grading validation](docs/grading-validation.md). Approval is bound to the reviewed labels, model, grader source, and exact report hash; stale or failing evidence blocks infrastructure synthesis with grading enabled.

## AWS and assets

`PiyoPiyoDev` runs only app-owned resources in account `992680757326`, `us-east-1`, using the owner's `admin` SSO profile. There is no agent IAM identity or shared application database, bucket, user pool, or runtime role. The $15 monthly budget sends forecast and actual alerts; it is not a hard spending cap. Lambda concurrency, API/DynamoDB throughput, 300 output tokens, and 20 grades per user per day bound usage. There is no NAT gateway, always-on compute, or provisioned inference.

See [infrastructure operations](infra/README.md) and [release packaging](docs/release-packaging.md). Public app configuration contains no credentials. Apple private keys and local signing material are ignored by Git and excluded from the bundles.

The cute yellow chick icon is original generated artwork inspired by the owner's reference. Its master and generation prompt are under `artifacts/branding/`; `swift scripts/make-icons.swift` regenerates platform sizes. The distinct Sources book icon and prompt are under `SourcesDesk/Branding/`; `swift scripts/make-sources-icons.swift` regenerates its Mac sizes. Only original audio, the Canvas mascot, and original icon artwork ship. Reference screenshots, source PDFs, and trailer excerpts remain outside the app. The provenance ledger records sources, references, and asset hashes.

[Website](https://piyopiyo.grabbiel.com) · [Privacy policy](https://piyopiyo.grabbiel.com/privacy) · [Support](https://piyopiyo.grabbiel.com/support)

## GitHub CI/CD

Pull requests run backend, infrastructure, secret, and native checks. Passing `main` builds deliver the tested AWS function artifacts through app-scoped OIDC credentials. Infrastructure changes require the reviewed deployment procedure. The **Apple release** workflow creates signed iPhone/iPad packages and notarized Mac apps, with an explicit TestFlight upload option. See [CI/CD operations](docs/ci-cd.md).
