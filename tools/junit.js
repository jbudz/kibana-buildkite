const parser = require('fast-xml-parser');
const Buildkite = require('./lib/buildkite');

const { buildNumber, pipelineSlug, jobId } = require('./lib/getBuildFromArgs')();

if (!pipelineSlug) {
  console.error('Usage: node junit.js <job url>');
  process.exit(1);
}

(async () => {
  const buildkite = new Buildkite();

  const xmls = await buildkite.downloadXmlArtifactsForJob(pipelineSlug, buildNumber, jobId);

  const parsed = xmls.map((xml) => parser.parse(xml, { ignoreAttributes: false, arrayMode: true }));
  const times = {
    bySuite: {},
    byClass: {},
    byTest: {},
    byDir: {},
  };

  parsed?.forEach((junit) => {
    junit.testsuites?.forEach((suites) => {
      suites.testsuite?.forEach((suite) => {
        const suiteName = suite['@_name'];
        const time = parseFloat(suite['@_time']);

        times.bySuite[suiteName] = times.bySuite[suiteName] || {
          suite: suiteName,
          time: 0,
        };

        times.bySuite[suiteName].time += time / 60;

        suite.testcase?.forEach((test) => {
          const testName = test['@_name'];
          const className = test['@_classname'];
          const testTime = parseFloat(test['@_time']) || 0;

          const dir = className.substr(className.indexOf('.') + 1, className.lastIndexOf('/') - className.indexOf('.') - 1);

          times.byDir[dir] = times.byDir[dir] || {
            suite: suiteName,
            time: 0,
            dir: dir,
            tests: [],
          };

          times.byDir[dir].time += testTime / 60;

          times.byTest[className + testName] = {
            suite: suiteName,
            time: testTime / 60,
            class: className,
            test: testName,
            dir: dir,
          };

          times.byDir[dir].tests.push(times.byTest[className + testName]);

          times.byClass[className] = times.byClass[className] || {
            suite: suiteName,
            time: 0,
            class: className,
          };

          times.byClass[className].time += testTime / 60;
        });
      });
    });
  });

  const sorted = {};
  Object.keys(times).forEach((key) => {
    sorted[key] = Object.values(times[key]).sort((a, b) => b.time - a.time);

    if (key !== 'byDir') {
      console.log(key, sorted[key].slice(0, 3));
    }
  });

  sorted.byDir.forEach((dir) => dir.tests.sort((a, b) => b.time - a.time));

  let total = 0;
  for (const dir of sorted.byDir) {
    console.log(dir.time.toString().substr(0, 6).padEnd(8, ' ') + dir.dir);
    total += dir.time;
  }
  console.log('Total', total);
})();
