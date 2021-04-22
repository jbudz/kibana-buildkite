const Buildkite = require('./lib/buildkite');

// https://cloud.google.com/products/calculator
const COSTS_PER_MINUTE = {
  default: 0,
  'ci-group': 0.031 / 4.35,
  'ci-group-4d': 0.0028,
  'ci-group-6': 0.0045,
  bootstrap: 0.0138,
  jest: 0.00166,
};

const JENKINS_COST = (0.242 / 4.35) * 60 * 2 + 0.78;

const PIPELNE_SLUG = process.argv[2] || 'kibana';
const BUILD_ID = process.argv[3] || 166;

(async () => {
  const buildkite = new Buildkite();

  const build = await buildkite.getBuild(PIPELNE_SLUG, BUILD_ID);

  const steps = build.jobs
    .filter((job) => job.type === 'script')
    .map((job) => {
      const durationMin = ((job.finished_at ? new Date(job.finished_at) : new Date()).getTime() - new Date(job.started_at).getTime()) / 60000;

      return {
        agent: job.agent_query_rules?.length ? job.agent_query_rules[0].replace('queue=', '') : 'default',
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
  console.log('Total', totalCost.toString().substr(0, 4));
  console.log('Jenkins', JENKINS_COST.toString().substr(0, 4));

  console.log('Change', ((totalCost * 100) / JENKINS_COST - 100).toString().substr(0, 5) + '%');
})();
