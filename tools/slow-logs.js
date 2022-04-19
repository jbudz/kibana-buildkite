require("dotenv").config();
const { resolve } = require("path");
const Buildkite = require("./lib/buildkite");

const { buildNumber, pipelineSlug, jobId } = require("./lib/getBuildFromArgs")();

const client = new Buildkite();

const SEARCH = process.argv[3] ? new RegExp(process.argv[3], "i") : null;

const parseMetadata = (metadata) => {
  const items = metadata.split(";");
  const parsed = {};
  items.forEach((item) => {
    const [key, value] = item.split("=");
    parsed[key] = value;
  });
  return parsed;
};

const parseLine = (line) => {
  const parsed = {};
  const [metadataLine, logLine] = line.split("\u0007", 2);
  const metadata = parseMetadata(metadataLine);
  if (metadata.t) {
    metadata.timestamp = new Date(parseInt(metadata.t));
  }

  const levelMatchers = [
    /^(---)|(~~~) /,
    /^ └-: /,
    /^   └-: /,
    /^     └-: /,
    /^       └-: /,
    /^         └-: /,
    /^           └-: /,
  ];
  for (const i in levelMatchers) {
    if (levelMatchers[i].test(logLine)) {
      parsed.level = Number(i);
      parsed.isLevel = true;
      break;
    }
  }

  parsed.log = logLine;
  parsed.metadata = metadata;
  parsed.timestamp = metadata.timestamp;

  return parsed;
};

(async () => {
  const build = await client.getBuild(pipelineSlug, buildNumber);
  const jobs = build.jobs
    .filter((job) => job.type === "script")
    .filter((job) => !jobId || job.id === jobId)
    .map((job) => {
      const durationMin =
        ((job.finished_at ? new Date(job.finished_at) : new Date()).getTime() - new Date(job.started_at).getTime()) /
        60000;

      return {
        ...job,
        duration: durationMin,
      };
    });

  jobs.sort((a, b) => {
    return b.duration - a.duration;
  });

  const logsDir = `./out/logs/${pipelineSlug}/${buildNumber}`;

  let i = 0;
  for (const job of jobs) {
    i++;

    if (SEARCH && !SEARCH.test(job.name)) {
      continue;
    }

    const jobName = `${job.name || job.command} ${
      job.parallel_group_index !== null ? "#" + (job.parallel_group_index + 1) : ""
    }`.trim();

    const log = await client.getLogForJob(pipelineSlug, buildNumber, job.id);
    const root = {
      nodes: [],
      parent: null,
      level: -1,
      log: jobName,
    };
    let lastLevelNode = root;
    let lastNode = root;

    log.split("_bk;").forEach((line) => {
      const parsed = parseLine(line);
      if (!root.timestamp) {
        root.timestamp = parsed.timestamp;
      }

      if (parsed.isLevel) {
        let parentNode = lastLevelNode;
        while (parentNode.level >= parsed.level) {
          parentNode = parentNode.parent;
        }
        parsed.parent = parentNode;
        parentNode.nodes = parentNode.nodes ?? [];
        parentNode.nodes.push(parsed);
        lastLevelNode = parsed;
      }

      let node = lastLevelNode;
      while (node) {
        node.lastNode = parsed;
        node = node.parent;
      }

      lastNode = parsed;
    });

    const calculateDurations = (node) => {
      if (node.lastNode) {
        node.duration = new Date(node.lastNode.timestamp).getTime() - new Date(node.timestamp).getTime();
      }

      if (node.nodes) {
        node.nodes.forEach((n) => calculateDurations(n));
        node.nodes.sort((a, b) => b.duration - a.duration);
      }
    };
    calculateDurations(root);

    const printNodes = (node) => {
      if (node.duration > 1000 * 60 * 3) {
        const prefix = [...Array(node.level + 1)].map((x) => "  ").join("");
        console.log(`${prefix}${Math.floor(node.duration / 600) / 100} ${(node.log ?? "").trim()}`);
        if (node.nodes) {
          node.nodes.forEach((n) => printNodes(n));
        }
      }
    };
    printNodes(root);
  }

  console.log("Logs are here: ");
  console.log(resolve(logsDir));
})();
