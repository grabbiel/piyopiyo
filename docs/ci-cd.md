# GitHub CI/CD

The repository is [grabbiel/piyopiyo](https://github.com/grabbiel/piyopiyo). It is public; private source uploads, Apple keys, signing keychains, local session logs, and browser captures are excluded. Credentials are never committed or included in workflow artifacts.

## Pull requests and main

The **CI** workflow runs on pull requests, pushes to `main`, and manual dispatch. Branch protection requires a pull request, an up-to-date passing **Checks** result, linear history and resolved conversations, including for administrators. Force pushes and branch deletion are disabled. No second human approval is required for this single-owner project. **Checks** succeeds only when both suites pass:

- **Backend:** checksum-pinned actionlint and Gitleaks, `npm ci`, TypeScript, credential-free CDK synthesis, CloudFormation lint, the owner-approved grading evidence gate, all backend/infrastructure/deployment tests, and PDF extraction tests. It saves the exact four function ZIPs and template for seven days.
- **Native:** XcodeGen 2.48.0, Swift functional tests, unsigned Mac/iOS builds, the Sources release build, and iPhone/iPad simulator functional tests on GitHub's `xcode-27` hosted runner with Xcode 27.2 and the iOS 27.2 SDK. Existing pixel baselines were captured on macOS/iOS 27; those rendering comparisons remain a separate local release check rather than being silently re-recorded on a different OS.

Actions are pinned to full commit hashes, with repository settings enforcing SHA pinning and allowing only GitHub-owned actions plus the specific AWS credentials action. External validation binaries have fixed SHA-256 checksums. Dependabot checks npm and action updates monthly, with at most three open PRs per ecosystem. Pull-request jobs have read-only GitHub access and no production secrets. Superseded check jobs are cancelled; deployments and signed releases are serialized without cancelling an active delivery.

## AWS delivery

After **Checks** passes on a push to `main`, **Deploy AWS** downloads artifacts from that same run and verifies their hashes. It skips a superseded main revision. The `aws-production` environment accepts only `main`.

The job exchanges a GitHub OIDC token for the app-only `piyopiyo-github-deploy` role. Its trust pins audience `sts.amazonaws.com` and the repository's actual immutable subject:

```
repo:grabbiel@90626364/piyopiyo@1466624853:environment:aws-production
```

No AWS access key or human SSO credential is stored in GitHub. The role can read/update this app's CloudFormation stack, write/read only its deployment artifact prefixes, and update the four existing app functions using their existing execution roles. CloudFormation also needs metadata reads for unchanged dependencies and stack outputs: the app's roles, HTTP API/domain, storage, queue, AppSync API, log groups and application inference profiles. These permissions use the exact existing app resources, except `logs:DescribeLogGroups` and `logs:DescribeResourcePolicies`: AWS requires `Resource: "*"` for those two list operations, restricted here to `us-east-1`. S3 metadata access includes listing the four app buckets; object reads remain limited to deployment artifacts. The role cannot write IAM roles/policies, fetch source-library files or the signing secret, read database rows, queue messages or log events, invoke models, or delete storage.

`scripts/ci/deploy-policy.cjs` compares the proposed template against the live original template. Only content-addressed `Code.S3Key` updates on the four known functions are accepted. IAM changes, environment/configuration changes, resource removal/addition and function replacement are rejected. Existing CDK telemetry is retained. The CloudFormation change set is inspected again before execution: it must match the exact validated function updates, with no replacement. CloudFormation also lists dynamic dependents of updated Lambda ARNs. Only the existing permission, API integration, policy and AppSync references to those proven-stable ARNs are accepted; their templates must remain unchanged. Static dependency changes, unrelated causes and actual replacements are rejected. AWS failure rollback remains enabled. A no-change deployment succeeds. Final checks cover home, health, support, privacy, and the unauthenticated questions endpoint returning 401. Health must also identify the exact tested GitHub commit embedded during bundling. Each run retains a deployment record for 30 days.

IAM policies and integrations construct Lambda ARNs from the function-name `Ref`, preserving initial creation order while limiting dependency changes during a code update. Avoid Lambda `GetAtt Arn` and explicit function `DependsOn`, which can cause additional resource operations. CloudFormation still reads unchanged dependency metadata and stack outputs; the scoped metadata permissions above were verified through an actual deployment. IAM writes remain unavailable to CI. The reference migration was separately reviewed with the owner profile: all resolved resource properties and existing function packages were verified identical before execution. Infrastructure changes still follow `scripts/deploy.mjs` with the owner's admin profile and a reviewed change set. A change rejected by automatic delivery is an explicit instruction to use that process; do not bypass the guard. For a code rollback, revert the application commit and merge after CI passes; the previous content-addressed artifacts remain available in app storage.

One-time access is managed separately in `infra/delivery.ts` as stack `PiyoPiyoDelivery`; normal CI cannot change it. The initial role was validated by IAM Access Analyzer with zero findings. The policy baseline was generated with:

```sh
DISABLE_IAM_POLICY_AUTOPILOT_TELEMETRY=true uvx iam-policy-autopilot@latest generate-policies \
  "$PWD/scripts/ci/deploy.mjs" --language javascript \
  --account 992680757326 --region us-east-1 --pretty
```

The saved baseline is audit material only. `infra/policies/github-deploy.json` narrows it to the real stack, CI change sets and deployment prefixes, removes unused S3/KMS/CloudFormation variants, and adds the existing-function permissions CloudFormation needs. The service authorization references and registered CloudFormation resource READ handler schemas were checked for the required metadata operations. Lambda code-signing, recursion, runtime-management and scaling configuration reads are restricted to the same four functions. [CloudWatch Logs service authorization](https://docs.aws.amazon.com/service-authorization/latest/reference/list_logs.html) documents the two metadata-list operations that cannot use resource-level permissions. The final policy was also validated with IAM Access Analyzer and tested under the delivery role against the deployed stack. To update delivery access, synthesize `infra/delivery.ts` into a separate output directory, inspect its change set, and deploy with the owner profile.

GitHub's [AWS OIDC guide](https://docs.github.com/en/actions/how-tos/secure-your-work/security-harden-deployments/oidc-in-aws) and [immutable-subject reference](https://docs.github.com/en/actions/reference/security/oidc) describe the trust format. Runner/toolchain details come from the [Xcode 27 arm64 image](https://github.com/actions/runner-images/blob/main/images/macos/xcode-27-arm64-Readme.md).

## Signed Apple releases

Run **Apple release** from `main` in the GitHub Actions UI, or:

```sh
gh workflow run apple-release.yml --repo grabbiel/piyopiyo --ref main \
  -f version=1.1.1 -f upload_testflight=false
```

The exact commit must already have a passing GitHub **Checks** result. The version must be numeric `major.minor.patch`. Build numbers use `100 + github.run_number` for this workflow; reruns use the same number, so do not re-upload a build Apple already accepted. Start a new dispatch when another build number is needed.

The `apple-release` environment accepts only `main`. Its encrypted secrets contain the app-specific Apple Distribution certificate/key/profile, the selected Developer ID identity, and the existing App Store Connect API key. Identifiers are environment variables. A disposable keychain is created on the hosted runner, populated only for signing, and removed in `finally`; the temporary API key, profiles and PKCS#12 files are also removed. No permanent keychain is installed on the runner or this Mac.

Both native CI and release packaging reject Xcode or iOS SDK versions below 27. Release packaging also checks the actual archived app SDK and records the toolchain in its manifest, preventing a repeat of ITMS-90725 for build 104. The `xcode-27` hosted image is currently a public preview; its Xcode installation is selected explicitly rather than following the image default.

The workflow archives a universal iPhone/iPad IPA, builds the native Mac learner and Sources app, verifies signatures, submits both Mac ZIPs to Apple notarization, staples accepted tickets, and saves checksummed artifacts for 14 days. Both Mac packages use the supplied release version for that dispatch. Public App Store release and App Review submission remain separate.

With `upload_testflight=true`, the same signed IPA is uploaded to the existing PiyoPiyo App Store Connect record and processing is followed to VALID. This does not attach it to the current review version, invite testers, submit review, or release publicly. The existing 1.1.0 (5) review submission remains independent.

Renew expired Apple certificates/profiles by replacing the corresponding encrypted environment secrets. PKCS#12 exports must support macOS Security import; for OpenSSL exports use `-keypbe PBE-SHA1-3DES -certpbe PBE-SHA1-3DES -macalg sha1` and verify import into a temporary keychain before replacing secrets. The build rejects expired or wrong-bundle profiles. Release artifacts contain only signed deliverables and their manifest; archives, keychains, keys and raw signing logs are not uploaded.
