# Buildkite Tools

Just some quick and dirty tools

## Build Cost

`node cost <pipeline_slug> <build_number>`

Shows the cost of a build, using the hard-coded costs in `cost.js`

## Slow Jobs

`node slow <pipeline_slug> <build_number>`

Sorts the jobs/steps of a build by duration, and outputs the durations as well
