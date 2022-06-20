#!/bin/bash

set -euo pipefail

cd packer

echo --- Building agent base image
packer build ./agent-base.pkr.hcl

echo --- Building agent cache image
packer build ./agent-cache.pkr.hcl
