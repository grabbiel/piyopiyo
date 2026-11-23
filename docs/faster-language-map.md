# Faster-language map for PiyoPiyo

Decision record for where C, Objective-C, C++, or Go should replace Python or Node, and where they should not. Targets are arm64 iOS, macOS, and Lambda.

## Keep

| Area | Today | Why |
| --- | --- | --- |
| Learner UI, SpriteKit 2D, SceneKit 3D, SQLite | Swift / CSQLite | Already native on Apple Silicon. Expand templates in Swift, not a second runtime. |
| Sources companion | Swift | Same process and auth model as the learner app. |
| API + grading + rooms Lambda | Node 22 arm64 (`backend/index.cjs`) | Hot path waits on DynamoDB, S3, and Bedrock, not CPU. A Go rewrite would not fix the real limiter: `reservedConcurrentExecutions: 2` shared by HTTP, AppSync, and grading. |
| Knowledge API and worker | Node 22 arm64 | I/O and Bedrock bound. Keep until a profiled CPU hotspot appears. |
| Content authoring scripts | Python (`scripts/build_questions.py`, `curate.py`, `compose.py`) | Offline authoring. Build time is not a CI bottleneck today. |
| Icon generation | Swift (`scripts/make-icons.swift`) | Fits the Apple toolchain. |
| Infra | TypeScript CDK | Team and review already live here. |

## Move when measured

| Area | Today | Proposal | Trigger |
| --- | --- | --- | --- |
| PDF extract Lambda | Python 3.13 + pypdf (`backend/pdf`) | Go or C++ (pdfium) streaming extract | PDF jobs dominate the $15 budget or hit memory/timeout alarms. |
| Offline embeddings | `scripts/embed.mjs` + Transformers.js / ONNX | One-shot Python or native batch on Apple Silicon | Local regen of `content/vectors.json` becomes slow enough to block editorial loops. Do not ship ONNX inside the learner app. |
| Deterministic scoring | Duplicated in `backend/index.cjs` and `Models.swift` | Shared fixture vectors, not a new language | Drift between JS and Swift scorers (parity tests). Language change is optional after fixtures exist. |

## Defer

| Idea | Reason |
| --- | --- |
| Metal custom game engines | SpriteKit and SceneKit already cover quiz-sized interactions. Revisit only if Instruments shows GPU or CPU limits on templates. |
| Objective-C bridges for games | No current need; Swift already calls SpriteKit and SceneKit. |
| Go rewrite of the whole API | Would not raise effective concurrency or remove Bedrock wait time. Prefer splitting grading off the concurrency-2 function first. |
| Shipping MiniLM / ONNX in the iOS or Mac app | Embeddings are offline pipeline artifacts. Runtime retrieval is not in the learner loop. |

## Concurrency note

The API function shares two reserved concurrent executions across sync, rooms, and Bedrock grading (up to about 8 s per grade). Language choice does not fix queueing under two simultaneous grades. Measure room and sync latency under concurrent `evaluate` calls before raising concurrency or splitting the function.

## Paths cited

- `PiyoPiyo/PiyoPiyoCore/Sources/PiyoPiyoCore/`
- `SourcesDesk/Sources/SourcesDesk/`
- `backend/index.cjs`, `backend/knowledge/`, `backend/pdf/`
- `infra/app.ts`, `infra/knowledge.ts`
- `scripts/build_questions.py`, `scripts/embed.mjs`, `scripts/curate.py`

## Unproven

No PoC harness ships with this note. Any later speedup claim must name the limiter and exclude process startup from the timed region.
