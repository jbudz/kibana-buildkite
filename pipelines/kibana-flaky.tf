resource "buildkite_pipeline" "flaky_test_suite_runner" {
  name        = "kibana / flaky-test-suite-runner"
  description = "Flaky Test Suite Runner"
  repository  = "https://github.com/elastic/kibana.git"
  steps       = <<-EOT
  steps:
    - command: .buildkite/pipelines/flaky_tests/pipeline.sh
      label: 'Create pipeline'
  EOT

  default_branch = "refs/pull/INSERT_PR_NUMBER/head"

  provider_settings {
    trigger_mode = "none"
  }
}
