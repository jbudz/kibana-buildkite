resource "buildkite_pipeline" "purge_cloud_deployment" {
  name        = "kibana / purge-cloud-deployment"
  description = "Purge a cloud deployment"
  repository  = "https://github.com/elastic/kibana.git"
  steps       = <<-EOT
  env:
    SLACK_NOTIFICATIONS_ENABLED: 'true'
  steps:
    - label: ":pipeline: Pipeline upload"
      command: buildkite-agent pipeline upload .buildkite/pipelines/purge_cloud_deployment.yml
      agents:
        queue: kibana-default
  EOT

  default_branch       = "main"
  branch_configuration = "main"

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