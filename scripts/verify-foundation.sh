#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
export AWS_PROFILE=admin AWS_REGION=us-east-1 AWS_DEFAULT_REGION=us-east-1 AWS_PAGER=''
aws sts get-caller-identity --output json > .agent/identity.json
python3 - <<'PY'
import json
from pathlib import Path
identity=json.loads(Path('.agent/identity.json').read_text())
if identity['Arn'].endswith(':root'): raise SystemExit('Root credentials refused')
if identity['Account'] != '992680757326': raise SystemExit('Unexpected AWS account; refusing to continue')
PY
aws s3 ls s3://piyopiyo-question-banks/
aws dynamodb describe-table --table-name PiyoPiyoQuizSessions --query Table.TableStatus
aws bedrock list-foundation-models --by-provider anthropic --query 'modelSummaries[].modelId'
aws cloudformation describe-stacks --stack-name PiyoPiyoDev --output json > .agent/stack.json
