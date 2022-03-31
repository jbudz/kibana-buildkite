resource "buildkite_pipeline" "es_forward_7_83" {
  name        = "kibana / 7.latest ES 8.3 forward compatibility"
  description = "Runs full CI daily using 7.latest kibana and 8.3 ES"
  repository  = "https://github.com/elastic/kibana.git"
  steps       = <<-EOT
  env:
    SLACK_NOTIFICATIONS_ENABLED: 'true'
    ES_SNAPSHOT_MANIFEST: 'https://storage.googleapis.com/kibana-ci-es-snapshots-daily/8.3.0/manifest-latest-verified.json'
  steps:
    - label: ":pipeline: Pipeline upload"
      command: buildkite-agent pipeline upload .buildkite/pipelines/es_forward.yml
      agents:
        queue: kibana-default
  EOT

  default_branch       = "7.17"
  branch_configuration = "7.17"

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

resource "buildkite_pipeline_schedule" "es_forward_7_83" {
  pipeline_id = buildkite_pipeline.es_forward_7_83.id
  label       = "Daily build"
  cronline    = "0 9 * * * America/New_York"
  branch      = "7.17"
}

resource "buildkite_pipeline" "es_forward_7_82" {
  name        = "kibana / 7.latest ES 8.2 forward compatibility"
  description = "Runs full CI daily using 7.latest kibana and 8.2 ES"
  repository  = "https://github.com/elastic/kibana.git"
  steps       = <<-EOT
  env:
    SLACK_NOTIFICATIONS_ENABLED: 'true'
    ES_SNAPSHOT_MANIFEST: 'https://storage.googleapis.com/kibana-ci-es-snapshots-daily/8.2.0/manifest-latest-verified.json'
  steps:
    - label: ":pipeline: Pipeline upload"
      command: buildkite-agent pipeline upload .buildkite/pipelines/es_forward.yml
      agents:
        queue: kibana-default
  EOT

  default_branch       = "7.17"
  branch_configuration = "7.17"

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

resource "buildkite_pipeline_schedule" "es_forward_7_82" {
  pipeline_id = buildkite_pipeline.es_forward_7_82.id
  label       = "Daily build"
  cronline    = "0 9 * * * America/New_York"
  branch      = "7.17"
}

resource "buildkite_pipeline" "es_forward_7_81" {
  name        = "kibana / 7.latest ES 8.1 forward compatibility"
  description = "Runs full CI daily using 7.latest kibana and 8.1 ES"
  repository  = "https://github.com/elastic/kibana.git"
  steps       = <<-EOT
  env:
    SLACK_NOTIFICATIONS_ENABLED: 'true'
    ES_SNAPSHOT_MANIFEST: 'https://storage.googleapis.com/kibana-ci-es-snapshots-daily/8.1.2/manifest-latest-verified.json'
  steps:
    - label: ":pipeline: Pipeline upload"
      command: buildkite-agent pipeline upload .buildkite/pipelines/es_forward.yml
      agents:
        queue: kibana-default
  EOT

  default_branch       = "7.17"
  branch_configuration = "7.17"

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

resource "buildkite_pipeline_schedule" "es_forward_7_81" {
  pipeline_id = buildkite_pipeline.es_forward_7_81.id
  label       = "Daily build"
  cronline    = "0 9 * * * America/New_York"
  branch      = "7.17"
}
