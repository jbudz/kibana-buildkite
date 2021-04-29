#!/usr/bin/env bash

set -euo pipefail

export DEBIAN_FRONTEND="noninteractive"

# Install docker credential helpers for GCR and GAR
sudo -u buildkite-agent gcloud auth configure-docker us-central1-docker.pkg.dev,gcr.io,us.gcr.io --quiet

# Setup Buildkite agent configuration
{
  agentConfig="$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/buildkite-agent-config -qf -H "Metadata-Flavor: Google" || true)"

  BUILDKITE_TOKEN="$(gcloud secrets versions access latest --secret=kibana-buildkite-agent-token)"
  echo "${agentConfig}" >> /etc/buildkite-agent/buildkite-agent.cfg
  echo "token=$BUILDKITE_TOKEN" >> /etc/buildkite-agent/buildkite-agent.cfg
}

# Setup Elastic Agent
{
  ELASTIC_AGENT_HOST="$(gcloud secrets versions access latest --secret=kibana-buildkite-elastic-agent-host)"
  ELASTIC_AGENT_USERNAME="$(gcloud secrets versions access latest --secret=kibana-buildkite-elastic-agent-username)"
  ELASTIC_AGENT_PASSWORD="$(gcloud secrets versions access latest --secret=kibana-buildkite-elastic-agent-password)"

  cd /tmp/elastic-agent
  sed -i "s/ELASTIC_AGENT_HOST/$(printf '%s\n' "$ELASTIC_AGENT_HOST" | sed -e 's/[\/&]/\\&/g')/" elastic-agent.yml
  sed -i "s/ELASTIC_AGENT_USERNAME/$(printf '%s\n' "$ELASTIC_AGENT_USERNAME" | sed -e 's/[\/&]/\\&/g')/" elastic-agent.yml
  sed -i "s/ELASTIC_AGENT_PASSWORD/$(printf '%s\n' "$ELASTIC_AGENT_PASSWORD" | sed -e 's/[\/&]/\\&/g')/" elastic-agent.yml
  ./elastic-agent install -f
}

systemctl enable buildkite-agent
systemctl start buildkite-agent

exit 0