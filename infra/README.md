# PiyoPiyo AWS operations

`PiyoPiyoDev` is isolated to account `992680757326`, `us-east-1`, using the owner's `admin` SSO profile. No agent IAM user, role, permission set, or shared application resources are created. Learner runtime roles and the additional knowledge-pipeline roles belong exclusively to PiyoPiyo.

## Resource boundaries

- Three private encrypted versioned S3 buckets: `piyopiyo-question-banks`, `piyopiyo-media`, and `piyopiyo-provenance`. TLS is required; ACLs/public access are disabled. Old object versions expire after 30 days. Deploy bundles/templates also live in the app's private provenance bucket.
- `PiyoPiyoQuizSessions` is a retained on-demand table, with user/room partitions, seven-day point-in-time backups, and TTL for rooms, quotas, challenges and deletion tombstones. Learner progress does not expire automatically.
- Cognito Lite provides email and Apple login, PKCE, ten-minute access/ID tokens, seven-day refresh tokens, and authenticated-only media credentials. Native clients have no client secret or direct database access.
- HTTP routes require Cognito JWTs except health, the state/nonce-validated Apple callback, and static home/privacy/support pages. AppSync additionally checks room membership.
- `piyopiyo/apple-sign-in` holds only this app's Apple key. The API role can read that secret and delete identities only in this app's user pool.
- Runtime logs expire after seven days. Grade logs contain model ID/latency and operational status, not answer text or tokens.

## Grading and cost

The runtime invokes only the approved Haiku 4.5 application profile and its underlying US models, constrained by the profile ARN. `npm run verify:grading` validates the 50 owner-reviewed cases and report/source hashes before synthesis. Five additional app-owned profiles retain candidate history without provisioned capacity. They are not runtime dependencies.

Limits: 256 MB ARM Lambda, 20-second function timeout, concurrency 2; API 5 requests/second, burst 10; DynamoDB maximum 10 read and 5 write request units/second; 20 model grades per user/day; 300 output tokens; eight-second model deadline. No NAT, VPC compute, provisioned inference, or search cluster.

The $15 monthly budget filters the active `Project=PiyoPiyo` allocation tag and emails the owner at forecast 80%, actual 80%, and actual 100%. It is an alert, not a hard cap. All taggable resources have Project/Environment tags. CloudWatch alarms cover Lambda errors, API 5xx, table throttling, and grading p95 latency.

## Deploy safely

```sh
aws sso login --profile admin
npm ci
npm run typecheck
npm run synth
npm test
.venv/bin/cfn-lint cdk.out/PiyoPiyoDev.template.json
node scripts/deploy.mjs
```

Synthesis builds a deterministic ZIP containing the backend, public documents, and pinned AWS SDK. Its SHA-256 is the S3 key, so every code change changes the CloudFormation reference. CDK's generic warning about omitted S3 object versions does not apply to overwriting a stable key: these keys are content-addressed.

`deploy.mjs` verifies account and non-root identity, uploads the app-only bundle, prepares a change set, and records its ID in `.agent/deploy-review.json`. Inspect `cloudformation describe-change-set` for that ID before executing:

```sh
node scripts/deploy.mjs --execute
./scripts/aws.sh cloudformation describe-stacks --stack-name PiyoPiyoDev \
  --query 'Stacks[0].StackStatus'
python3 scripts/configure-client.py
npm run test:integration
```

Wait for `UPDATE_COMPLETE`, inspect failures rather than repeatedly retrying, and verify integration before accepting a deployment. The helper rejects resource removal and definite replacement (except the budget). Retain stable construct IDs for storage/authentication. Budget email and Apple key use previous CloudFormation parameter values; initial key setup reads `PIYOPIYO_APPLE_KEY_PATH` into a temporary 0600 file that is deleted after use.

The integration runner creates temporary email-suppressed accounts, exercises auth/scoring/sync/rooms/deletion, and removes only its own data. Do not use the owner's account for destructive tests. `docs/deployed-resources.json` records the final resource inventory. App Store review submission is recorded separately in `docs/app-store-deployment.md`.

## Branded public website

`https://piyopiyo.grabbiel.com` serves home, support, and privacy pages through the existing HTTP API and Lambda. `WebsiteCertificate`, `WebsiteDomain`, and `WebsiteMapping` in `infra/app.ts` configure its ACM certificate, regional TLS 1.2 domain, and default-stage mapping. Website outputs contain the current URL, certificate ARN, and DNS target.

GoDaddy DNS has two added CNAMEs, each with TTL 600: `piyopiyo` points to `d-xdbrcs2i27.execute-api.us-east-1.amazonaws.com`; `_6cb73bf318f560db5e2297820502b863.piyopiyo` points to `_104d4cce22530bcdd412e6d8a430c674.wzccmgtwzk.acm-validations.aws`. Keep the validation record for ACM renewal. Existing unrelated records were not replaced. The official GoDaddy CLI is installed at `~/.local/bin/gddy`; its production OAuth login manages DNS without storing credentials in this repository.

Edit `docs/home.html`, `docs/support.html`, `docs/privacy-policy.html`, and `docs/website.css`, then use the normal synth/deploy workflow. `scripts/prepare-public-documents.mjs` packages shared branding and navigation into the backend. There is no extra always-on server, hosted zone, or separate hosting platform. HTTPS checks are recorded in `tests/website-live-check.json`.
