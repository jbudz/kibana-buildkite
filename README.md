# Kibana Buildkite

Tools / Automation / Etc

- [tools](tools) - Misc. one-off tools for interacting with Buildkite. Inspect a build using the API, grab the slowest steps from a build, etc.
- [pipelines](pipelines) - Buildkite pipelines managed as code
- [agents](agents) - Tools for creating Buildkite agent images using Packer. Currently there is only one image, based on Ubuntu 20.04
- [agent-metrics](agent-metrics) - Config for deploying Buildkite's [buildkite-agent-metrics](https://github.com/buildkite/buildkite-agent-metrics)

## Other Tools / repos

- [buildkite-agent-manager](https://github.com/elastic/buildkite-agent-manager) - for managing/auto-scaling agents in GCP
- [buildkite-pr-bot](https://github.com/elastic/buildkite-pr-bot) - for triggering PRs in Buildkite
- [kibana-buildkite-build-bot](https://github.com/elastic/kibana-buildkite-build-bot/) - Slack notifications and possibly PR comments in the future
- [kibana-buildkite-library](https://github.com/elastic/kibana-buildkite-library) - Library used in pipelines and in several other tools above, has a client for interacting with Buildkite as well as types for the API

## Locations of other Buildkite things

- [Pull Request configuration](https://github.com/elastic/kibana/blob/master/.buildkite/pull_requests.json)
- [Agent configurations](agents.json)
- [terraform for CI infra](https://github.com/elastic/kibana-operations/tree/main/infra/elastic-kibana-ci)
- [Custom monitoring collectors](https://github.com/elastic/kibana-operations/tree/main/monitoring) e.g. for Buildkite and Github
