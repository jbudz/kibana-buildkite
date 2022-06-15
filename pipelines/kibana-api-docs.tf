resource "buildkite_pipeline" "api_docs_daily" {
  name        = "kibana / api-docs / daily"
  description = "Builds api_docs daily and creates a PR with the changes"
  repository  = "https://github.com/elastic/kibana.git"
  steps       = <<-EOT
  env:
    SLACK_NOTIFICATIONS_CHANNEL: '#kibana-operations-alerts'
    SLACK_NOTIFICATIONS_ENABLED: 'true'
  steps:
    - label: ":pipeline: Pipeline upload"
      command: buildkite-agent pipeline upload .buildkite/pipelines/build_api_docs.yml
      agents:
        queue: kibana-default
  EOT

  default_branch             = "main"
  branch_configuration       = "main"
  cancel_intermediate_builds = true

  provider_settings {
    trigger_mode = "none"
  }

  team {
    slug         = "everyone"
    access_level = "MANAGE_BUILD_AND_READ"
  }
}

resource "buildkite_pipeline_schedule" "api_docs_daily" {
  pipeline_id = buildkite_pipeline.api_docs_daily.id
  label       = "Daily build"
  cronline    = "0 0 * * * America/New_York"
  branch      = buildkite_pipeline.api_docs_daily.default_branch
}
