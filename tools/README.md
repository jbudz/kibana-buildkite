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

`node cost <buildkite_build_url>`

Shows the cost of a build, using the hard-coded costs in `cost.js`

### Slow Jobs

`node slow <buildkite_build_url>`

Sorts the jobs/steps of a build by duration, and outputs the durations as well

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
