const Buildkite = require("./lib/buildkite");

const { buildNumber, pipelineSlug } = require("./lib/getBuildFromArgs")();

// https://cloud.google.com/products/calculator
const COSTS_PER_MINUTE = {
  default: 0.00002698 * 60,
  "ci-group": 0.031 / 4.35,
  "ci-group-4d": 0.0028,
  "ci-group-6": 0.0045,
  jest: 0.00002698 * 60,
  "n2-2": 0.00002698 * 60,
  "n2-4": 0.00002698 * 60 * 2,
  "c2-16": 0.00023192 * 60,
  "c2-8": 0.00011596 * 60,
  "c2-4": 0.00005798 * 60,
};

const JENKINS_COST = (0.242 / 4.35) * 140 + 0.78;

(async () => {
  const buildkite = new Buildkite();

  const build = await buildkite.getBuild(pipelineSlug, buildNumber);

  const steps = build.jobs
    .filter((job) => job.type === "script")
    .map((job) => {
      const durationMin =
        ((job.finished_at ? new Date(job.finished_at) : new Date()).getTime() -
          new Date(job.started_at).getTime()) /
        60000;

      return {
        agent: job.agent_query_rules?.length
          ? job.agent_query_rules[0].replace("queue=", "")
          : "default",
        duration: durationMin,
      };
    });

  const perAgent = {};

  let totalCost = 0;

  for (const step of steps) {
    perAgent[step.agent] = perAgent[step.agent] || { duration: 0, cost: 0 };
    perAgent[step.agent].duration += step.duration;
    const cost = step.duration * COSTS_PER_MINUTE[step.agent] || 0;
    perAgent[step.agent].cost += cost;

    totalCost += cost;
  }

  console.log(perAgent);
  console.log("Total", totalCost.toString().substr(0, 4));
  console.log("Jenkins", JENKINS_COST.toString().substr(0, 4));

  console.log(
    "Change",
    ((totalCost * 100) / JENKINS_COST - 100).toString().substr(0, 5) + "%"
  );
})();
