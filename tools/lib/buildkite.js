require('dotenv').config();

const axios = require('axios');

class Buildkite {
  http = null;

  constructor() {
    const BUILDKITE_BASE_URL = process.env.BUILDKITE_BASE_URL || 'https://api.buildkite.com';
    const BUILDKITE_TOKEN = process.env.BUILDKITE_TOKEN;

    const BUILDKITE_AGENT_BASE_URL = process.env.BUILDKITE_AGENT_BASE_URL || 'https://agent.buildkite.com/v3';
    const BUILDKITE_AGENT_TOKEN = process.env.BUILDKITE_AGENT_TOKEN;

    this.http = axios.create({
      baseURL: BUILDKITE_BASE_URL,
      headers: {
        Authorization: `Bearer ${BUILDKITE_TOKEN}`,
      },
    });

    // this.agentHttp = axios.create({
    //   baseURL: BUILDKITE_AGENT_BASE_URL,
    //   headers: {
    //     Authorization: `Token ${BUILDKITE_AGENT_TOKEN}`,
    //   },
    // });
  }

  getBuild = async (pipelineSlug, buildNumber) => {
    const link = `v2/organizations/elastic/pipelines/${pipelineSlug}/builds/${buildNumber}?include_retried_jobs=true`;
    const resp = await this.http.get(link);
    return resp.data;
  };

  getBuilds = async (pipelineSlug, count = 10, branch = null) => {
    let link = `v2/organizations/elastic/pipelines/${pipelineSlug}/builds/?include_retried_jobs=true&per_page=${count}`;

    if (branch) {
      link += `&branch=${branch}`;
    }

    const resp = await this.http.get(link);
    return resp.data;
  };
}

module.exports = Buildkite;
