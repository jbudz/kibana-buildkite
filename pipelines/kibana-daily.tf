# Note: this pipeline is no longer used, but still exists to keep the historical data
resource "buildkite_pipeline" "daily" {
  name        = "kibana / daily"
  description = "Runs full CI daily and on merge"
  repository  = "https://github.com/elastic/kibana.git"
  steps       = <<-EOT
  env:
    SLACK_NOTIFICATIONS_CHANNEL: '#kibana-operations-alerts'
    SLACK_NOTIFICATIONS_ENABLED: 'true'
    REPORT_FAILED_TESTS_TO_GITHUB: 'true'
  steps:
    - label: ":pipeline: Pipeline upload"
      command: buildkite-agent pipeline upload .buildkite/pipelines/hourly.yml
      agents:
        queue: kibana-default
  EOT

  default_branch       = ""

  // See: https://github.com/buildkite/terraform-provider-buildkite/issues/184
  branch_configuration = "not-a-real-branch"

  provider_settings {
    build_branches      = true
    build_tags          = false
    build_pull_requests = false

    trigger_mode = "code"
  }

  team {
    slug = "everyone"
    access_level = "MANAGE_BUILD_AND_READ"
  }
}
