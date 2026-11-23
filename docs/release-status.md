# PiyoPiyo 1.1.0 release status

Verified November 23, 2026. PiyoPiyo 1.1.0 (5) for iPhone and iPad is **Waiting for Review** in App Store Connect. Apple processing is VALID and public release remains manual. The native Mac app is 1.1.0 (4). The engineering release gate passed, and the owner explicitly accepted the verified iPhone SE/iPad mini simulator and MacBook Pro coverage in place of the named MacBook Air. Apple approval and public App Store availability are pending.

## Background learning update

PiyoPiyo Sources 1.0.1 (2) and PiyoPiyo 1.1.0 (4) are installed in `~/Applications`. Both Mac apps are Developer ID signed, notarized, stapled, and accepted by Gatekeeper. Sources has its own mint-and-teal book icon with the Piyo chick; the main app retains its original icon. The companion app retains its own Keychain sign-in; the owner successfully opened the administrator library with Apple. A native file-picker upload reached the cloud and became a ready source. The updated learner app displayed the published three-question quiz, scored its answer correctly, and showed the private-source title without exposing the original file. The universal iPhone/iPad 1.1.0 (5) IPA is `artifacts/release/1.1.0-iOS/PiyoPiyo-iOS.ipa`; it is uploaded, attached to the store version, and submitted for review.

The deployed pipeline imports private PDFs/text and public URLs, discovers recent CS research abstracts, and generates source-backed quizzes three times weekly. Publication is automatic after structural, evidence, duplicate, and independent model-review checks. Source controls and batch withdrawal are available locally. The quota is 60 attempted content-model calls per month, alongside the existing $15 total app budget alerts. [Workflow, limits, and operations](knowledge-pipeline.md) describe the implementation.

Verification includes 50 backend/infrastructure/gate tests, three PDF extraction tests, and 18 Swift tests on each of the three verified platforms. Real cloud import/generation results are recorded in `tests/knowledge-integration-results.json`; signed artifact hashes and notarization identifiers are in `tests/knowledge-release-artifacts.json`. The underlying learner grading model and owner-reviewed 94% grading result are unchanged.

The first actual scheduled generation completed November 23 at 10:30 Lima time and automatically published one accepted research question while withholding two candidates that failed exact-source evidence checks. This separate production schedule observation is recorded in `tests/knowledge-scheduled-run.json`.

## Original release foundation

| Area | Result |
| --- | --- |
| Native builds | Mac release build and universal iPhone/iPad App Store archive/export succeeded |
| Mac distribution | Developer ID signed, Apple notarization Accepted, ticket stapled, Gatekeeper accepted |
| iPhone/iPad distribution | Apple Distribution signed; one IPA, bundle `app.piyopiyo.iphone`, device families `[1,2]` |
| Branding | Original chick icon included in Mac `.icns`, iPhone/iPad icon entries and compiled assets; opaque 1024px source |
| Apple authentication | Owner completed real Apple login; app showed signed-in account and all answers synced; state survived the build-3 update |
| Swift tests | 18 each on Mac, iPhone SE (3rd generation) simulator, and iPad mini simulator; 54 format snapshot comparisons |
| Backend/infrastructure | 40 passing tests; TypeScript, CloudFormation synthesis and lint passed |
| Human grading | 47/50 exact matches, 94%, p95 1,556 ms, zero invalid results; approved grader deployed and live Lambda invocation verified |
| Real AWS integration | Public pages, auth isolation, all 18 formats, duplicate protection, progress, delayed offline answers, three concurrent learners, WebSocket events, resumable deletion and old-token rejection passed; temporary data removed |
| Assets | 28 provenance entries; bundled original audio and icon asset hashes verified; external reference media excluded |
| Privacy | AI and diagnostics off by default, account deletion and Apple revocation flow, privacy manifests, public privacy/support pages |
| Cost isolation | App-owned storage/auth/roles/model profiles; $15 alerts, on-demand services, daily AI quotas and throughput limits |

The original 1.0.0 artifacts remain recorded in `tests/release-artifacts.json`. Current 1.1.0 artifacts are `artifacts/release/PiyoPiyo-1.1.0.zip` and `artifacts/release/1.1.0-iOS/PiyoPiyo-iOS.ipa`; the companion is `artifacts/release/PiyoPiyo-Sources-1.0.1.zip`. The IPA has passed App Store Connect processing; external TestFlight invitations were not sent.

## Distribution and follow-up checks

The store record, listing, free pricing, privacy/age/export declarations, review contact/demo account, and iPhone/iPad screenshots are complete. Apple accepted submission `ffd960b6-3a19-45cd-96d4-df6c282e9034` on November 23 at 12:21 Lima time. Initial availability is United States and Peru, with manual release after approval. See `tests/app-store-submission.json` and `docs/app-store-deployment.md` for the exact evidence and identifiers. The owner-authorized Paid Apps Agreement was verified Active.

The live website is [piyopiyo.grabbiel.com](https://piyopiyo.grabbiel.com), with working support and privacy pages used in the store listing. It shares the app's existing API Gateway/Lambda runtime, with a dedicated ACM certificate and GoDaddy DNS records. It adds no always-on server or separate hosting platform. HTTPS and responsive page checks passed.

The owner accepted the tested device coverage; the exact reply is recorded in `tests/device-acceptance.json`. A full manual VoiceOver/large-text audit is not claimed. `docs/acceptance-checklist.md` remains a useful broader usability checklist, not a newly imposed approval gate.

The coding assistant reviewed the 45 authored questions and checked all 1,070 numeric variants; see `tests/content-review.json`. This was not an independent human editorial audit. The initial corpus and parameterized practice count remain explicitly labeled.

The real owner account was not deleted during testing. Backend account deletion used disposable Cognito accounts; Apple token revocation was tested with signed-token mocks covering valid and invalid identities. The real Apple deletion/revocation round trip still needs a disposable Apple test account if that acceptance is desired.

## Practical limits

Local SQLite progress is not application-encrypted; credentials use Keychain. Sign-out retains account-separated local progress. Deleting a cloud account does not erase offline copies on other devices. Database backups expire within seven days; an identifier tombstone blocks old tokens for up to 24 hours.

Rooms have ten questions, 12 members, and a two-hour lifetime; they have no teacher-paced rounds or moderation console. Timed practice uses a monotonic local clock and accepts later uploads; it is not a proctored examination system.

The grader's 94% result uses a reused owner-reviewed regression set, not untouched validation data. Keyword fallback is provisional. Schema compilation, model throttling, outages, and the 20-per-user daily quota may defer model feedback. Budget alerts and rate limits do not enforce a hard $15 spending ceiling.
