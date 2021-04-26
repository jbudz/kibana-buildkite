locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
  image_id = "bk-agent-${local.timestamp}"
}

variable "buildkite_token" {
  type = string
  sensitive = true
}

variable "elastic_agent_host" {
  type = string
  sensitive = true
}

variable "elastic_agent_username" {
  type = string
  sensitive = true
}

variable "elastic_agent_password" {
  type = string
  sensitive = true
}

source "googlecompute" "bk_dev" {
  disk_size           = 75
  disk_type           = "pd-ssd"
  image_description   = "${local.image_id}"
  image_family        = "kibana-bk-dev-agents"
  image_name          = "${local.image_id}"
  machine_type        = "n1-standard-8"
  project_id          = "elastic-kibana-184716"
  source_image_family = "ubuntu-2004-lts"
  ssh_username        = "packer"
  zone                = "us-central1-a"
}

build {
  sources = ["source.googlecompute.bk_dev"]

  provisioner "file" {
    destination = "/tmp/bk-startup.sh"
    source      = "startup.sh"
  }

  provisioner "file" {
    destination = "/tmp/bk-hooks"
    source      = "hooks"
  }

  provisioner "file" {
    destination = "/tmp/elastic-agent.yml"
    source      = "elastic-agent.yml"
  }

  provisioner "shell" {
    execute_command  = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    script           = "setup.sh"
    environment_vars = [
      "BUILDKITE_TOKEN=${var.buildkite_token}",
      "ELASTIC_AGENT_HOST=${var.elastic_agent_host}",
      "ELASTIC_AGENT_USERNAME=${var.elastic_agent_username}",
      "ELASTIC_AGENT_PASSWORD=${var.elastic_agent_password}"
    ]
  }

}
