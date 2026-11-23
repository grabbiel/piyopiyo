# Human-reviewed grading validation

On November 23, 2026, Claude Haiku 4.5 matched **47 of 50 owner-reviewed scores (94%)**, with **p95 1,556 ms**, no failed calls, and no invalid assessments. The release gate requires at least 45 matches, p95 below 3,000 ms, and zero failed/invalid results.

The reviewed answers are `tests/grading-heldout.json`. Francisco Cruzado supplied `tests/grading-human-review.json` and explicitly confirmed, “I reviewed all 50 scores.” `tests/grading-human-attestation.json` binds that confirmation to the submitted file hash. The labels were not changed to improve agreement.

The originally held-out set was reused during prompt/model iteration. This final result is a **golden-set regression result**, not an unbiased estimate on unseen answers. An additional independent set is appropriate before making broad accuracy claims. Automated grades remain advisory and may be wrong.

## Exact release configuration

- Model: `anthropic.claude-haiku-4-5-20251001-v1:0`, through the PiyoPiyo-only US application inference profile `yfevvxi4bbi9`.
- Temperature 0; thinking disabled; maximum output 300 tokens.
- Structured JSON contains an independent assessment and supporting answer-segment IDs for each rubric fact. The server validates IDs, evidence, and completeness, then computes the score. Learner text cannot replace the server rubric.
- The benchmark calls the same `gradingRequest`, `answerSegments`, and `parseGrade` functions used by Lambda. The deployment bundles the pinned AWS SDK so structured-output serialization matches local validation.
- `tests/grading-human-results.json` is the selected report. `backend/grading-release.json` records its hash, model, and approval. `scripts/grading-gate.cjs` independently recalculates agreement/latency and checks labels, attestation, unique cases, and grader fingerprint.
- The final run consumed 37,667 input and 6,653 output tokens. Latency measures direct Bedrock requests from this workstation; it does not include the complete mobile-to-Lambda network path.

The three disagreements were review-17 (human 2, model 1), review-47 (2 vs 1), and review-07 (1 vs 0). Full answers, rubric checks, and missing concepts are retained in the report for inspection.

## Reproduce

This command invokes paid inference 50 times. It does not silently approve or deploy a new result.

```sh
AWS_PROFILE=admin AWS_REGION=us-east-1 \
PIYOPIYO_MODEL_PROFILE=arn:aws:bedrock:us-east-1:992680757326:application-inference-profile/yfevvxi4bbi9 \
PIYOPIYO_MODEL_FAMILY=haiku45 \
PIYOPIYO_BENCHMARK_OUTPUT=tests/grading-human-candidate.json \
node scripts/benchmark.mjs --human
```

The structured-output schema may require a provider-side compilation on a cold cache. The schema was warmed with one calibration case before this run (2,666 ms). Runtime requests abort after eight seconds; provider delays, throttles, invalid output, and the daily quota return provisional keyword feedback without losing the saved answer. Successful model latency and model ID are logged; learner text is not logged by the app.

Historical candidate reports remain in `tests/grading-*.json`. Nova Micro/Lite/2 Lite/Pro did not pass the human release gate. Haiku 5.5 was unavailable to this account; legacy Llama access was denied. Those candidates are not used by the release runtime. Their app-specific inference profiles allocate no provisioned model capacity.
