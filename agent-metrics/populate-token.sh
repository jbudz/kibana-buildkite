#!/bin/bash

set -euo pipefail

AGENT_TOKEN="$(vault read -field token secret/kibana-issues/dev/buildkite-agent-metrics)"

echo "token=${AGENT_TOKEN}" > .env.secret
