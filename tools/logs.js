require("dotenv").config();
const { execSync } = require("child_process");
const { writeFileSync, readFileSync, mkdirSync } = require("fs");
const Buildkite = require("./lib/buildkite");

const { buildNumber, pipelineSlug, jobId } =
  require("./lib/getBuildFromArgs")();

const client = new Buildkite();

const parseMetadata = (metadata) => {
  const items = metadata.split(";");
  const parsed = {};
  items.forEach((item) => {
    const [key, value] = item.split("=");
    parsed[key] = value;
  });

  return parsed;
};

(async () => {
  const log = await client.getLogForJob(pipelineSlug, buildNumber, jobId);

  mkdirSync("./out", { recursive: true });

  execSync("terminal-to-html > out/logs.html", {
    input: log,
    stdio: "pipe",
  });

  const html = readFileSync("out/logs.html")
    .toString()
    .replace(/<\?bk.+?\?>/gms, '</div><div class="line">');

  const template = readFileSync("logs.html").toString();
  writeFileSync("./out/logs.html", template.replace("$OUTPUT", html));

  execSync("open out/logs.html");

  return;

  const lines = log.split("\n");
  const logs = lines.map((line) => {
    const [metadataLine, logLine] = line.split("\u0007", 2);
    const metadata = parseMetadata(metadataLine);
    if (metadata.t) {
      metadata.timestamp = new Date(parseInt(metadata.t));
    }

    return {
      log: logLine,
      timestamp: metadata.timestamp,
      metadata: metadata,
    };
  });

  for (const log of logs) {
    console.log(log.timestamp, log.log);
  }
})();
