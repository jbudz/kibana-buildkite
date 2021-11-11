require("dotenv").config();
const { writeFileSync, mkdirSync } = require("fs");
const { resolve } = require("path");
const Buildkite = require("./lib/buildkite");

const { buildNumber, pipelineSlug } = require("./lib/getBuildFromArgs")();

const client = new Buildkite();

const SEARCH = process.argv[3] ? new RegExp(process.argv[3], "i") : null;

(async () => {
  const build = await client.getBuild(pipelineSlug, buildNumber);
  const jobs = build.jobs.filter((job) => job.type === "script");

  const logsDir = `./out/logs/${pipelineSlug}/${buildNumber}`;

  let i = 0;
  for (const job of jobs) {
    i++;

    if (SEARCH && !SEARCH.test(job.name)) {
      continue;
    }

    mkdirSync(logsDir, { recursive: true });
    const jobName = `${i.toString().padStart(2, "0")} ${job.name || job.command} ${
      job.parallel_group_index !== null ? "#" + (job.parallel_group_index + 1) : ""
    }`.trim();

    console.log(`Downloading logs for ${jobName}...`);

    const log = await client.getLogForJob(pipelineSlug, buildNumber, job.id);
    writeFileSync(`${logsDir}/${jobName.replace(/[^a-zA-Z0-9-]/g, "_")}.log`, log);
  }

  console.log("Logs are here: ");
  console.log(resolve(logsDir));
})();
