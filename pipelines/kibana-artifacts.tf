resource "buildkite_pipeline" "kibana_artifacts_snapshot" {
  name        = "kibana / artifacts snapshot"
  description = "Kibana snapshot artifact builds"
  repository  = "https://github.com/elastic/kibana.git"
  steps       = <<-EOT
  env:
    SLACK_NOTIFICATIONS_ENABLED: 'false'
  steps:
    - label: ":pipeline: Pipeline upload"
      command: buildkite-agent pipeline upload .buildkite/pipelines/artifacts.yml
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

resource "buildkite_pipeline" "kibana_artifacts_release" {
  name        = "kibana / artifacts release"
  description = "Kibana release artifact builds"
  repository  = "https://github.com/elastic/kibana.git"
  steps       = <<-EOT
  env:
    SLACK_NOTIFICATIONS_ENABLED: 'false'
    RELEASE_BUILD: 'true'
  steps:
    - label: ":pipeline: Pipeline upload"
      command: buildkite-agent pipeline upload .buildkite/pipelines/artifacts.yml
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
