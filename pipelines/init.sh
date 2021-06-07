#!/bin/bash

# Initializes the bucket where the terraform state will be stored.
# This should match the backend bucket in main.tf

PROJECT_ID=elastic-kibana-ci

gsutil mb gs://${PROJECT_ID}-kibana-pipelines-tfstate
gsutil versioning set on gs://${PROJECT_ID}-kibana-pipelines-tfstate