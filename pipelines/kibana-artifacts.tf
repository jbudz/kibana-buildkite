resource "buildkite_pipeline" "kibana_artifacts_snapshot" {
  name        = "kibana / artifacts snapshot"
  description = "Kibana snapshot artifact builds"
  repository  = "https://github.com/elastic/kibana.git"
  steps       = <<-EOT
  env:
    SLACK_NOTIFICATIONS_ENABLED: 'true'
  steps:
    - label: ":pipeline: Pipeline upload"
      command: buildkite-agent pipeline upload .buildkite/pipelines/artifacts.yml
      agents:
        queue: kibana-default
  EOT

  default_branch       = "main"
  branch_configuration = join(" ", setsubtract(local.current_dev_branches, ["8.1"]))

  provider_settings {
    build_branches      = false
    build_tags          = false
    build_pull_requests = false

    trigger_mode = "none"
  }

  team {
    slug = "everyone"
    access_level = "MANAGE_BUILD_AND_READ"
  }
}

resource "buildkite_pipeline_schedule" "kibana_artifacts_snapshot_daily" {
  for_each = toset(local.current_dev_branches)

  pipeline_id = buildkite_pipeline.kibana_artifacts_snapshot.id
  label       = "Daily build"
  cronline    = "0 7 * * * America/New_York"
  branch      = each.value
}

resource "buildkite_pipeline" "kibana_artifacts_staging" {
  name        = "kibana / artifacts staging"
  description = "Kibana staging artifact builds"
  repository  = "https://github.com/elastic/kibana.git"
  steps       = <<-EOT
  env:
    SLACK_NOTIFICATIONS_ENABLED: 'true'
    RELEASE_BUILD: 'true'
  steps:
    - label: ":pipeline: Pipeline upload"
      command: buildkite-agent pipeline upload .buildkite/pipelines/artifacts.yml
      agents:
        queue: kibana-default
  EOT

  default_branch       = "main"
  branch_configuration = join(" ", setsubtract(local.current_dev_branches, ["8.1"]))

  provider_settings {
    build_branches      = false
    build_tags          = false
    build_pull_requests = false

    trigger_mode = "none"
  }

  team {
    slug = "everyone"
    access_level = "MANAGE_BUILD_AND_READ"
  }
}

resource "buildkite_pipeline_schedule" "kibana_artifacts_staging_daily" {
  for_each = toset(local.current_dev_branches)

  pipeline_id = buildkite_pipeline.kibana_artifacts_staging.id
  label       = "Daily build"
  cronline    = "0 7 * * * America/New_York"
  branch      = each.value
}
