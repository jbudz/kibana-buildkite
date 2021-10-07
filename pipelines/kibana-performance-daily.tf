resource "buildkite_pipeline" "performance_daily" {
  name        = "kibana / performance daily"
  description = "Runs performance tests daily"
  repository  = "https://github.com/suchcodemuchwow/kibana"
  steps       = <<-EOT
  env:
    SLACK_NOTIFICATIONS_CHANNEL: '#kibana-operations-alerts'
    SLACK_NOTIFICATIONS_ENABLED: 'false'
  steps:
    - label: ":pipeline: Pipeline upload"
      command: buildkite-agent pipeline upload .buildkite/pipelines/performance/nightly.yml
  EOT

  default_branch       = "06102021-feat-perf-test-nightly"
  branch_configuration = join(" ", local.current_dev_branches)
}

# resource "buildkite_pipeline_schedule" "performance-daily-ci" {
#   for_each = local.daily_branches

#   pipeline_id = buildkite_pipeline.daily.id
#   label       = "Daily build"
#   cronline    = "0 9 * * * Europe/Berlin"
#   branch      = each.value
# }
