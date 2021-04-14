resource "buildkite_pipeline" "baseline" {
  name        = "kibana-baseline"
  description = "Capture the baseline metrics/snapshots for each commit of Kibana"
  repository  = "https://github.com/elastic/kibana.git"
  steps       = <<-EOT
  env:
    GITHUB_COMMIT_STATUS_ENABLED: 'true'
    GITHUB_COMMIT_STATUS_CONTEXT: 'buildkite/kibana-ci-baseline'
    SLACK_NOTIFICATIONS_CHANNEL: '#kb-bk'
    SLACK_NOTIFICATIONS_ENABLED: 'true'
  steps:
    - label: ":pipeline: Pipeline upload"
      command: buildkite-agent pipeline upload .buildkite/baseline.yml
  EOT

  default_branch       = "buildkite"
  branch_configuration = "buildkite"

  provider_settings {
    build_branches      = true
    build_tags          = false
    build_pull_requests = false

    trigger_mode = "code"
  }
}

resource "github_repository_webhook" "baseline" {
  repository = "kibana"

  configuration {
    url          = buildkite_pipeline.baseline.webhook_url
    content_type = "json"
    insecure_ssl = false
  }

  active = true

  events = ["push"]
}
