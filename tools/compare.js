const Buildkite = require("./lib/buildkite");

const getBuildFromArgs = require("./lib/getBuildFromArgs");

const { buildNumber: buildNumberA, pipelineSlug: pipelineSlugA } =
  getBuildFromArgs(2);

const { buildNumber: buildNumberB, pipelineSlug: pipelineSlugB } =
  getBuildFromArgs(3);

(async () => {
  const buildkite = new Buildkite();

  console.log(process.argv);
  console.log({
    buildNumberA,
    buildNumberB,
    pipelineSlugA,
    pipelineSlugB,
  });

  const [buildA, buildB] = await Promise.all([
    buildkite.getBuild(pipelineSlugA, buildNumberA),
    buildkite.getBuild(pipelineSlugB, buildNumberB),
  ]);

  const [stepsA, stepsB] = [buildA, buildB].map((build) =>
    build.jobs
      .filter((job) => job.type === "script")
      .map((job) => {
        const durationMin =
          ((job.finished_at
            ? new Date(job.finished_at)
            : new Date()
          ).getTime() -
            new Date(job.started_at).getTime()) /
          60000;

        return {
          ...job,
          duration: durationMin,
        };
      })
  );

  for (const stepA of stepsA) {
    const stepB = stepsB.find(
      (step) =>
        step.name === stepA.name &&
        step.parallel_group_index === stepA.parallel_group_index
    );
    stepA.durationDifference = (stepB?.duration || 0) - stepA.duration;
    stepA.otherStep = stepB;
  }

  stepsA.sort((a, b) => {
    return Math.abs(b.durationDifference) - Math.abs(a.durationDifference);
  });

  const filteredSteps = stepsA.filter(
    (step) => Math.abs(step.durationDifference) >= 2
  );

  for (const step of filteredSteps) {
    console.log(
      `${step.durationDifference.toString().substr(0, 4)} ${step.name} ${
        step.parallel_group_index !== null
          ? "#" + (step.parallel_group_index + 1)
          : ""
      }`
    );
    console.log(step.web_url);
    step.otherStep && console.log(step.otherStep.web_url);
    console.log("");
  }
})();
