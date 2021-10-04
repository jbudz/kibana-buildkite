require('dotenv').config();

const { BuildkiteClient } = require('kibana-buildkite-library');

const { buildNumber, pipelineSlug } = require('./lib/getBuildFromArgs')();

const client = new BuildkiteClient();

(async () => {
  const build = await client.getBuild(pipelineSlug, buildNumber, true);
  console.log(JSON.stringify(build, null, 2));
})();
