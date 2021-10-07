locals {
  current_dev_branches = ["master", "7.x", "7.15"]
  hourly_branches      = ["master", "7.x"]
  daily_branches       = setsubtract(local.current_dev_branches, local.hourly_branches)
}
