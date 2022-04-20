# Buildkite Tools

Just some quick and dirty tools

## Setup

1. Generate API token
   1. https://buildkite.com/user/api-access-tokens
   2. New API Access Token
   3. Organization Access: Elastic
   4. Scopes: Read Builds, Read Pipelines, Read Artifacts, Read Build Logs
   5. Create
2. `cp .env.template .env`
3. Edit `.env` and insert `BUILDKITE_TOKEN`

## Tools

### Build Cost

`node cost <buildkite_build_url>`

Shows the cost of a build, using the hard-coded costs in `cost.js`

### Slow Jobs

`node slow <buildkite_build_url> [regex]`

Sorts the jobs/steps of a build by duration, and outputs the durations as well. Optional regex to filter the steps, e.g. 'Default CI Group'

### Failures

`node failures <pipeline_slug> [branch] [count]`

Summarizes step failures across the latest `count` builds, and displays up to 3 example URLs for each.

### JUnit

`node junit <buildkite_step_url>`

(Open a step in a Buildkite build so that the URL contains the build ID in the hash)

Downloads all of the JUnit artifacts for a given build step, and shows a bunch of sorted output based on execution times.

### Capacity

`node capacity <buildkite_build_url> [number_to_calculate]`

Tells you approximately how many resources you need to run `number_to_calculate` instances of the given build. Should only pass a finished build to this. Useful for planning GCP quotas.

Averages the resource usages across the duration of a build. E.g. a 1 hour step that uses 16 CPUs in a 2 hour build will contribute 8 CPUs required.

### Compare

`node compare <buildkite_build_url> <buildkite_build_url>`

Compares two Buildkite builds, and outputs the steps whose execution times differed by more than 2 minutes. Useful for seeing why one build may have been faster or slower than another.

### ES Issue

`node es-issue <buildkite_job_url>`

Grabs the test failure from the linked job, and creates a failed ES promotion issue for it.

### Logs

`node logs <buildkite_job_url>`

Grab the full logs from the Buildkite job, renders them into HTML using the same renderer as Buildkite, and opens them in a browser. Includes a basic search bar.

Requires golang and [terminal-to-html](https://github.com/buildkite/terminal-to-html)

```bash
brew install go
GO111MODULE=on go get github.com/buildkite/terminal-to-html/v3/cmd/terminal-to-html
echo 'export PATH=$PATH:$(go env GOPATH)/bin' >> ~/.bash_profile # Or .zshrc, or similar
```

### All Logs

`node all-logs <buildkite_build_url> [optional regex]`

Grabs the logs for all steps in a given build, and writes them to separate files. If a regex is provided, it will filter the jobs to only include those whose name matches the regex. Regex is case-insensitive.

e.g.

```bash
node all-logs https://buildkite.com/elastic/kibana-hourly/builds/3094 "default ci group"
```

### Slow Logs

`node slow-logs <buildkite_build_or_job_url>`

Grabs the logs for all of the steps in a given build, or just the given job, depending on the URL passed in.

It will process the logs for each step, breaking the steps down into smaller steps based on content of the logs, and assigning durations to the chunks. It will then sort everything by duration, and show only chunks that are > 3 minutes. Useful for getting an overview of the slowest parts of a build.

e.g.

```bash
node slow-logs https://buildkite.com/elastic/kibana-hourly/builds/3094
```
