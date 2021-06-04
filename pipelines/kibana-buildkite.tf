resource "buildkite_pipeline" "kibana-buildkite-pipelines-deploy" {
  name        = "kibana-buildkite / pipelines / deploy"
  repository  = "https://github.com/elastic/kibana-buildkite.git"
  steps       = <<-EOT
  env:
    SLACK_NOTIFICATIONS_CHANNEL: '#kb-bk'
    SLACK_NOTIFICATIONS_ENABLED: 'true'
  steps:
    - label: ":pipeline: Pipeline upload"
      command: buildkite-agent pipeline upload pipelines/.buildkite/deploy.yml
  EOT

  default_branch       = "main"
  branch_configuration = "main"

  provider_settings {
    build_branches      = false
    build_tags          = false
    build_pull_requests = false

    trigger_mode = "code"
  }
}