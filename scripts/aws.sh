#!/bin/sh
# The user's chosen deployment identity. Application clients never use this profile.
set -eu
if [ -z "${AWS_ACCESS_KEY_ID:-}" ] && [ -z "${AWS_WEB_IDENTITY_TOKEN_FILE:-}" ]; then
  export AWS_PROFILE="${AWS_PROFILE:-admin}"
fi
export AWS_REGION=us-east-1 AWS_DEFAULT_REGION=us-east-1 AWS_PAGER=''
exec aws "$@"
