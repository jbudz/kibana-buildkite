# buildkite-agent-metrics

Uses https://github.com/buildkite/buildkite-agent-metrics

## Deploy

1. Run `./populate-token.sh` if you need to create/update `.env.secret`
2. Make sure the correct k8s context is chosen
3. Run `kubectl apply -k .`
