resource "buildkite_pipeline" "pull-request" {
  name        = "kibana / pull request"
  description = "Runs manually for pull requests"
  repository  = "https://github.com/elastic/kibana.git"
  steps       = <<-EOT
  env:
    PR_COMMENTS_ENABLED: 'true'
    GITHUB_COMMIT_STATUS_ENABLED: 'true'
    GITHUB_COMMIT_STATUS_CONTEXT: 'kibana-ci'
  steps:
    - label: ":pipeline: Pipeline upload"
      command: .buildkite/scripts/pipelines/pull_request/pipeline.sh
  EOT

  default_branch       = "master"
  branch_configuration = ""

  cancel_intermediate_builds = true

  provider_settings {
    build_branches      = false
    build_tags          = false
    build_pull_requests = true

    trigger_mode = "none"

    publish_commit_status = false
  }
}

