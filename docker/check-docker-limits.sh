#!/usr/bin/env bash
set -e

TEST_PULL_URL="https://auth.docker.io/token?service=registry.docker.io&scope=repository:ratelimitpreview/test:pull"
TOKEN=$(curl $TEST_PULL_URL | jq -r .token)

curl --head -H "Authorization: Bearer $TOKEN" \
  https://registry-1.docker.io/v2/ratelimitpreview/test/manifests/latest | \
  grep ^ratelimit
