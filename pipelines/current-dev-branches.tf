locals {
  current_dev_branches = ["master", "8.0", "7.16", "7.15"]
  hourly_branches      = ["master", "8.0", "7.16"]
  daily_branches       = setsubtract(local.current_dev_branches, local.hourly_branches)
}
