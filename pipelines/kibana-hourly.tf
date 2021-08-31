resource "buildkite_pipeline" "hourly" {
  name        = "kibana / hourly"
  description = "Runs full CI hourly"
  repository  = "https://github.com/elastic/kibana.git"
  steps       = <<-EOT
  env:
    SLACK_NOTIFICATIONS_CHANNEL: '#kibana-operations-alerts'
    SLACK_NOTIFICATIONS_ENABLED: 'false'
  steps:
    - label: ":pipeline: Pipeline upload"
      command: buildkite-agent pipeline upload .buildkite/pipelines/hourly.yml
  EOT

  default_branch       = "buildkite-hourly-ci"
  branch_configuration = "buildkite-hourly-ci"

  provider_settings {
    build_branches      = true
    build_tags          = false
    build_pull_requests = false

    trigger_mode = "code"
  }
}

// resource "github_repository_webhook" "hourly" {
//   repository = "kibana"

//   configuration {
//     url          = buildkite_pipeline.hourly.webhook_url
//     content_type = "json"
//     insecure_ssl = false
//   }

//   active = true

//   events = ["push"]
// }
