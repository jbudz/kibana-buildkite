const Buildkite = require("./lib/buildkite");

const { buildNumber, pipelineSlug } = require("./lib/getBuildFromArgs")();

(async () => {
  const buildkite = new Buildkite();

  const build = await buildkite.getBuild(pipelineSlug, buildNumber);

  let total = 0;

  const steps = build.jobs
    .filter((job) => job.type === "script")
    .filter((job) => (process.argv[3] ? job.name.match(new RegExp(process.argv[3])) : true))
    .map((job) => {
      const durationMin =
        ((job.finished_at ? new Date(job.finished_at) : new Date()).getTime() - new Date(job.started_at).getTime()) /
        60000;
      total += durationMin;

      return {
        ...job,
        duration: durationMin,
      };
    });

  steps.sort((a, b) => {
    return b.duration - a.duration;
  });

  for (const step of steps) {
    console.log(
      `${step.duration.toString().substr(0, 4)} ${step.name} ${
        step.parallel_group_index !== null ? "#" + (step.parallel_group_index + 1) : ""
      } - ${step.web_url}`
    );
  }

  console.log("");
  console.log(`Total: ${total}`);
})();
