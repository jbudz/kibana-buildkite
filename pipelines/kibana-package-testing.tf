resource "buildkite_pipeline" "package_testing" {
  name        = "kibana / package-testing"
  description = "Daily testing of rpm, deb, docker installs"
  repository  = "https://github.com/elastic/kibana.git"
  steps       = <<-EOT
  env:
    GITHUB_COMMIT_STATUS_ENABLED: 'true'
    SLACK_NOTIFICATIONS_ENABLED: 'true'
  steps:
    - label: ":pipeline: Pipeline upload"
      command: buildkite-agent pipeline upload .buildkite/pipelines/package_testing.yml
      agents:
        queue: kibana-default
  EOT

  default_branch       = "main"
  branch_configuration = join(" ", local.current_dev_branches)

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
