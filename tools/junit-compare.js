// Compares junit class names across all xml files in two different builds
// Mostly created to see if https://github.com/elastic/kibana/pull/130983 dropped any tests on accident

const parser = require("fast-xml-parser");
const Buildkite = require("./lib/buildkite");

const getBuildFromArgs = require("./lib/getBuildFromArgs");

const { buildNumber: buildNumberA, pipelineSlug: pipelineSlugA } = getBuildFromArgs(2);

const { buildNumber: buildNumberB, pipelineSlug: pipelineSlugB } = getBuildFromArgs(3);

const getJunits = async (pipelineSlug, buildNumber) => {
  const buildkite = new Buildkite();

  const build = await buildkite.getBuild(pipelineSlug, buildNumber);

  const jobs = build.jobs.filter(
    (job) =>
      job?.name &&
      (job.name.includes("CI Group") ||
        job.name.includes("FTR") ||
        job.name.includes("API Integration") ||
        job.name.includes("Firefox") ||
        job.name.includes("Functional") ||
        job.name.includes("Accessibility") ||
        job.name.includes("Saved Object"))
  );

  const allParsed = [];
  for (const job of jobs) {
    console.log("Downloading for job:", job.name);

    let xmls;
    for (let i = 0; i < 3; i++) {
      try {
        xmls = await buildkite.downloadXmlArtifactsForJob(pipelineSlug, buildNumber, job.id);
        break;
      } catch (ex) {
        console.error(ex.toString());
      }
    }
    const parsed = xmls.map((xml) => parser.parse(xml, { ignoreAttributes: false, arrayMode: true }));

    if (parsed?.length) {
      allParsed.push(parsed);
    }
  }

  const allClasses = new Set();
  allParsed.flat().forEach((junit) => {
    junit.testsuites?.forEach((suites) => {
      suites.testsuite?.forEach((suite) => {
        const suiteName = suite["@_name"];
        suite.testcase?.forEach((test) => {
          const testName = test["@_name"];
          const className = test["@_classname"].replace(/\/group[0-9]+/, "");
          allClasses.add(className);
        });
      });
    });
  });

  return allClasses;
};

(async () => {
  const [junitsA, junitsB] = await Promise.all([
    getJunits(pipelineSlugA, buildNumberA),
    getJunits(pipelineSlugB, buildNumberB),
  ]);

  let a_minus_b = new Set([...junitsA].filter((x) => !junitsB.has(x)));
  let b_minus_a = new Set([...junitsB].filter((x) => !junitsA.has(x)));

  console.log("Removed:");
  console.log(a_minus_b);
  console.log("");
  console.log("Added:");
  console.log(b_minus_a);
})();
