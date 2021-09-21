const Buildkite = require('./lib/buildkite');

const pipelineSlug = process.argv[2];
const branch = process.argv[3];
const count = (process.argv[4] && parseInt(process.argv[4])) || 10;

(async () => {
  const buildkite = new Buildkite();

  const builds = await buildkite.getBuilds(pipelineSlug, count, branch);
  const jobs = builds.flatMap((build) => build.jobs);

  const failures = jobs
    .filter((job) => job.state === 'failed')
    .map((job) => {
      return {
        id: job.id,
        origName: job.name,
        name: job.name + (job.parallel_group_index !== null ? ` #${job.parallel_group_index}` : ''),
        url: job.web_url,
        parallel_group_index: job.parallel_group_index,
      };
    });

  const failuresByName = {};

  for (const failure of failures) {
    failuresByName[failure.name] = failuresByName[failure.name] || { name: failure.name, count: 0, urls: [] };
    failuresByName[failure.name].count += 1;
    failuresByName[failure.name].urls.push(failure.url);
  }

  const sortedFailures = Object.values(failuresByName).sort((a, b) => b.count - a.count);

  for (const failure of sortedFailures) {
    console.log(`${failure.count.toString().padEnd(sortedFailures[0].count.toString().length, ' ')} ${failure.name}`);
    failure.urls.slice(0, 3).forEach((url) => console.log(`  ${url}`));
  }
})();
