resource "buildkite_pipeline" "es_snapshot_build" {
  name        = "kibana / elasticsearch snapshot build"
  description = "Build new Elasticsearch snapshots for use by kbn-es / FTR"
  repository  = "https://github.com/elastic/kibana.git"
  steps       = <<-EOT
  steps:
    - label: ":pipeline: Pipeline upload"
      command: buildkite-agent pipeline upload .buildkite/es-snapshot-build.yml
  EOT

  default_branch       = "buildkite-wip"
  branch_configuration = "buildkite-wip"

  provider_settings {
    build_branches      = false
    build_tags          = false
    build_pull_requests = false

    trigger_mode = "code"
  }
}

resource "buildkite_pipeline" "es_snapshot_verify" {
  name        = "kibana / elasticsearch snapshot verify"
  description = "Verify Elasticsearch snapshots for use by kbn-es / FTR"
  repository  = "https://github.com/elastic/kibana.git"
  steps       = <<-EOT
  steps:
    - label: ":pipeline: Pipeline upload"
      command: buildkite-agent pipeline upload .buildkite/es-snapshot-verify.yml
  EOT

  default_branch       = "buildkite-wip"
  branch_configuration = "buildkite-wip"

  provider_settings {
    build_branches      = false
    build_tags          = false
    build_pull_requests = false

    trigger_mode = "code"
  }
}

resource "buildkite_pipeline" "es_snapshot_promote" {
  name        = "kibana / elasticsearch snapshot promote"
  description = "Promote Elasticsearch snapshots for use by kbn-es / FTR"
  repository  = "https://github.com/elastic/kibana.git"
  steps       = <<-EOT
  steps:
    - label: ":pipeline: Pipeline upload"
      command: buildkite-agent pipeline upload .buildkite/es-snapshot-promote.yml
  EOT

  default_branch       = "buildkite-wip"
  branch_configuration = "buildkite-wip"

  provider_settings {
    build_branches      = false
    build_tags          = false
    build_pull_requests = false

    trigger_mode = "code"
  }
}

// resource "buildkite_pipeline_schedule" "es_snapshot_build_daily" {
//   pipeline_id = buildkite_pipeline.es_snapshot_build.id
//   label       = "Daily build"
//   cronline    = "0 12 * * * America/New_York"
//   branch      = buildkite_pipeline.es_snapshot_build.default_branch
// }
