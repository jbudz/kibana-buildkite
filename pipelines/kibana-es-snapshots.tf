locals {
  # TODO use current_dev_branches var when it exists and es stuff has been backported
  es_snapshot_branches = ["buildkite-es-snapshots"]
}

resource "buildkite_pipeline" "es_snapshot_build" {
  name        = "kibana / elasticsearch snapshot build"
  description = "Build new Elasticsearch snapshots for use by kbn-es / FTR"
  repository  = "https://github.com/elastic/kibana.git"
  steps       = <<-EOT
  steps:
    - label: ":pipeline: Pipeline upload"
      command: buildkite-agent pipeline upload .buildkite/pipelines/es_snapshots/build.yml
  EOT

  default_branch       = "buildkite-es-snapshots"
  branch_configuration = "buildkite-es-snapshots"

  provider_settings {
    build_branches      = false
    build_tags          = false
    build_pull_requests = false

    trigger_mode = "none"
  }
}

resource "buildkite_pipeline" "es_snapshot_verify" {
  name        = "kibana / elasticsearch snapshot verify"
  description = "Verify Elasticsearch snapshots for use by kbn-es / FTR"
  repository  = "https://github.com/elastic/kibana.git"
  steps       = <<-EOT
  steps:
    - label: ":pipeline: Pipeline upload"
      command: buildkite-agent pipeline upload .buildkite/pipelines/es_snapshots/verify.yml
  EOT

  default_branch       = "buildkite-es-snapshots"
  branch_configuration = "buildkite-es-snapshots"

  provider_settings {
    build_branches      = false
    build_tags          = false
    build_pull_requests = false

    trigger_mode = "none"
  }
}

resource "buildkite_pipeline" "es_snapshot_promote" {
  name        = "kibana / elasticsearch snapshot promote"
  description = "Promote Elasticsearch snapshots for use by kbn-es / FTR"
  repository  = "https://github.com/elastic/kibana.git"
  steps       = <<-EOT
  steps:
    - label: ":pipeline: Pipeline upload"
      command: buildkite-agent pipeline upload .buildkite/pipelines/es_snapshots/promote.yml
  EOT

  default_branch       = "buildkite-es-snapshots"
  branch_configuration = "buildkite-es-snapshots"

  provider_settings {
    build_branches      = false
    build_tags          = false
    build_pull_requests = false

    trigger_mode = "none"
  }
}

resource "buildkite_pipeline_schedule" "es_snapshot_build_daily" {
  for_each = toset(local.es_snapshot_branches)

  pipeline_id = buildkite_pipeline.es_snapshot_build.id
  label       = "Daily build"
  // cronline    = "0 12 * * * America/New_York"
  cronline = "0 */4 * * * America/New_York"
  branch   = each.value
}
