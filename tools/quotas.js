const axios = require('axios');

const CONFIG_URL = 'https://raw.githubusercontent.com/elastic/kibana/buildkite-baseline/.buildkite/agents.json';

// Edit this to include the number of each agent type you'd like to include in capacity planning
// This could be automated in the future when we have real data
const queues = [
  {
    queue: 'default',
    cpus: 2,
    number: 15,
  },
  {
    queue: 'baseline',
    number: 10,
  },
  {
    queue: 'baseline-small',
    number: 20,
  },
  {
    queue: 'ci-group',
    number: 200,
  },
];

const LOCAL_SSD_GB = 375;

const quotas = {};

(async () => {
  const agentConfigs = (await axios.get(CONFIG_URL)).data;
  for (const queue of queues) {
    const { agents, ...agentConfig } = { ...agentConfigs.gcp, ...agentConfigs.gcp.agents.find((c) => c.queue === queue.queue) };

    const parsedType = agentConfig.machineType.split('-');
    const cpuType = parsedType[0];
    const cpuCount = queue.cpus || (parsedType.length === 4 ? parsedType[3] : parsedType[2]);

    quotas[`${cpuType}-cpus`] = quotas[`${cpuType}-cpus`] || 0;
    quotas[`${cpuType}-cpus`] += cpuCount * queue.number;

    quotas['cpus'] = quotas['cpus'] || 0;
    quotas['cpus'] += cpuCount * queue.number;

    if (agentConfig.localSsds) {
      quotas['local-ssd-gbs'] = quotas['local-ssd-gbs'] || 0;
      quotas['local-ssd-gbs'] += agentConfig.localSsds * LOCAL_SSD_GB * queue.number;
    }

    quotas[agentConfig.diskType] = quotas[agentConfig.diskType] || 0;
    quotas[agentConfig.diskType] += agentConfig.diskSizeGb * queue.number;

    quotas['instances'] = quotas['instances'] || 0;
    quotas['instances'] += queue.number;
  }

  console.log(quotas);
})();
