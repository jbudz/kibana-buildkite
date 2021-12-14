resource "buildkite_pipeline" "artifacts" {
  name        = "kibana / artifacts"
  description = "Buld Kibana artifacts"
  repository  = "https://github.com/elastic/kibana.git"
  steps       = <<-EOT
  env:
    SLACK_NOTIFICATIONS_CHANNEL: '#kibana-operations-alerts'
    SLACK_NOTIFICATIONS_ENABLED: 'true'
  steps:
    - label: ":pipeline: Pipeline upload"
      command: buildkite-agent pipeline upload .buildkite/pipelines/artifacts.yml
  EOT

  default_branch       = "main"
  branch_configuration = join(" ", local.hourly_branches)

  provider_settings {
    trigger_mode = "none"
  }
}

resource "buildkite_pipeline_schedule" "hourly-ci" {
  for_each = toset(local.hourly_branches)

  pipeline_id = buildkite_pipeline.hourly.id
  label       = "Hourly build"
  cronline    = "0 * * * * America/New_York"
  branch      = each.value
}
