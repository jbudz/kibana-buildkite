const Buildkite = require("./lib/buildkite");
const { Octokit } = require("@octokit/rest");

const github = new Octokit({
  auth: process.env.GITHUB_TOKEN,
});

const { buildNumber, pipelineSlug, jobId } =
  require("./lib/getBuildFromArgs")();

if (!pipelineSlug) {
  console.error("Usage: node es-issue.js <job url>");
  process.exit(1);
}

(async () => {
  const buildkite = new Buildkite();
  const artifacts = await buildkite.getArtifactsForJob(
    pipelineSlug,
    buildNumber,
    jobId
  );

  const testFailureFile = artifacts.find((artifact) =>
    artifact.path.match(/test_failures\/.+\.json$/)
  );

  const testFailureHtml = artifacts.find((artifact) =>
    artifact.path.match(/test_failures\/.+\.html$/)
  );

  const testFailure = (await buildkite.http.get(testFailureFile.download_url))
    .data;

  const [classname, filename] = testFailure.classname.split(".", 2);

  const title = `Failing ES Promotion: ${testFailure.name}`;
  const body = `
    **${classname}**
    **${filename.replace("·", ".")}**

    **${testFailure.name}**

    This failure is preventing the promotion of the current Elasticsearch nightly snapshot.

    For more information on the Elasticsearch snapshot promotion process including how to reproduce using the unverified nightly ES build: https://www.elastic.co/guide/en/kibana/master/development-es-snapshots.html

    * [Failed promotion job](${testFailure.jobUrl})
    * [Test Failure](${testFailureHtml.url.replace(
      "api.buildkite.com/v2",
      "buildkite.com"
    )})

    \`\`\`
    ${testFailure.failure}
    \`\`\`
  `
    .replace(/^    /gm, "")
    .trim();

  const resp = await github.issues.create({
    owner: "elastic",
    repo: "kibana",
    title,
    body,
    labels: ["failed-es-promotion"],
  });

  console.log(resp.data.html_url);
})();
