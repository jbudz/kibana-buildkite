resource "buildkite_pipeline" "es_forward_7" {
  name        = "kibana / 7.latest ES forward compatibility"
  description = "Runs full CI daily using 7.latest kibana and 8.0 ES"
  repository  = "https://github.com/elastic/kibana.git"
  steps       = <<-EOT
  env:
    ES_SNAPSHOT_MANIFEST: 'https://storage.googleapis.com/kibana-ci-es-snapshots-daily/8.0.0/manifest-latest-verified.json'
  steps:
    - label: ":pipeline: Pipeline upload"
      command: buildkite-agent pipeline upload .buildkite/pipelines/hourly.yml
  EOT

  default_branch       = "7.17"
  branch_configuration = "7.17"

  provider_settings {
    build_branches      = false
    build_tags          = false
    build_pull_requests = false

    trigger_mode = "none"
  }
}

resource "buildkite_pipeline_schedule" "es_forward_7" {
  pipeline_id = buildkite_pipeline.es_forward_7.id
  label       = "Daily build"
  cronline    = "0 9 * * * America/New_York"
  branch      = "7.17"
}
