# Buildkite Tools

Just some quick and dirty tools

## Setup

1. Generate API token
   1. https://buildkite.com/user/api-access-tokens
   2. New API Access Token
   3. Organization Access: Elastic
   4. Scopes: Read Builds, Read Pipelines
   5. Create
2. `cp .env.template .env`
3. Edit `.env` and insert `BUILDKITE_TOKEN`

## Tools

### Build Cost

`node cost <pipeline_slug> <build_number>`

Shows the cost of a build, using the hard-coded costs in `cost.js`

### Slow Jobs

`node slow <pipeline_slug> <build_number>`

Sorts the jobs/steps of a build by duration, and outputs the durations as well

### Failures

`node failures <pipeline_slug> [branch] [count]`

Summarizes step failures across the latest `count` builds, and displays up to 3 example URLs for each.

### JUnit

`node junit <buildkite_step_url>`

(Open a step in a Buildkite build so that the URL contains the build ID in the hash)

Downloads all of the JUnit artifacts for a given build step, and shows a bunch of sorted output based on execution times.
