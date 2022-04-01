data "github_repository_file" "kibana_versions" {
  repository = "kibana"
  branch     = "main"
  file       = "versions.json"
}

locals {
  kibana_versions      = jsondecode(data.github_repository_file.kibana_versions.content)["versions"]
  kibana_branches      = [for k, v in local.kibana_versions : v["branch"]]
  current_dev_branches = local.kibana_branches
}
