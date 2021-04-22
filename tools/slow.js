const Buildkite = require('./lib/buildkite');

const PIPELNE_SLUG = process.argv[2] || 'kibana';
const BUILD_ID = process.argv[2] || 166;

(async () => {
  const buildkite = new Buildkite();

  const build = await buildkite.getBuild(PIPELNE_SLUG, BUILD_ID);

  const steps = build.jobs
    .filter((job) => job.type === 'script')
    .map((job) => {
      const durationMin = ((job.finished_at ? new Date(job.finished_at) : new Date()).getTime() - new Date(job.started_at).getTime()) / 60000;

      return {
        ...job,
        duration: durationMin,
      };
    });

  steps.sort((a, b) => {
    return b.duration - a.duration;
  });

  for (const step of steps) {
    console.log(`${step.duration.toString().substr(0, 4)} ${step.name}`);
  }
})();
