require('dotenv').config();

const { BuildkiteClient } = require('kibana-buildkite-library');

const client = new BuildkiteClient();

(async () => {
  const PIPELINE_SLUG = process.argv[2];
  const BUILD_NUMBER = process.argv[3];

  const build = await client.getBuild(PIPELINE_SLUG, BUILD_NUMBER);
  console.log(JSON.stringify(build, null, 2));
})();
