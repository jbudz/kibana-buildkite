#!/bin/bash

set -euo pipefail

TERRAFORM_VERSION="$(cat pipelines/.terraform-version)"

cd pipelines

trap "rm -rf .terraform" EXIT

echo --- terraform init

docker run -it --rm --init --volume "$(pwd)":/app --workdir /app \
  hashicorp/terraform:"$TERRAFORM_VERSION" init

echo --- terraform apply

docker run -it --rm --init --volume "$(pwd)":/app --workdir /app \
  -e TF_VAR_buildkite_token -e TF_VAR_github_token \
  hashicorp/terraform:"$TERRAFORM_VERSION" \
  apply -auto-approve -var "github_owner=elastic"