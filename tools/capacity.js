const Buildkite = require("./lib/buildkite");

const { buildNumber, pipelineSlug } = require("./lib/getBuildFromArgs")();

const scale = parseInt(process.argv[3] || 1);

const RESOURCES = {
  default: {
    type: "n2",
    cpu: 2,
    localSsd: 375,
  },
  "c2-16": {
    type: "c2",
    cpu: 16,
    localSsd: 375 * 2,
  },
  "ci-group-6": {
    type: "n2",
    cpu: 6,
    localSsd: 375,
  },
  "ci-group-4d": {
    type: "n2d",
    cpu: 4,
    localSsd: 375,
  },
  "n2-4": {
    type: "n2",
    cpu: 4,
    localSsd: 375,
  },
  "n2-2": {
    type: "n2",
    cpu: 2,
    localSsd: 375,
  },
  "c2-4": {
    type: "c2",
    cpu: 4,
    localSsd: 375,
  },
};

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
  const perResource = {};

  const buildDurationMin =
    (new Date(build.finished_at).getTime() -
      new Date(build.started_at).getTime()) /
    60000;

  for (const step of steps) {
    perAgent[step.agent] = perAgent[step.agent] || {
      count: 0,
    };
    perAgent[step.agent].count += 1;

    const r = RESOURCES[step.agent];
    perResource[`${r.type}-cpu`] = perResource[`${r.type}-cpu`] || 0;
    perResource[`${r.type}-cpu`] +=
      ((r.cpu * step.duration) / buildDurationMin) * scale;

    perResource["local-ssd"] = perResource["local-ssd"] || 0;
    perResource["local-ssd"] +=
      ((r.localSsd * step.duration) / buildDurationMin) * scale;
  }

  for (const resource in perResource) {
    console.log(`${resource} - ${Math.round(perResource[resource])}`);
  }
})();
