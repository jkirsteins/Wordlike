#!/usr/bin/env bash
set -euo pipefail

echo "=== Creating Datadog xcconfig ==="
cd "$CI_PRIMARY_REPOSITORY_PATH"
mkdir -p Config
cat > Config/Datadog.xcconfig <<XCCONFIG
DD_CLIENT_TOKEN = ${DD_CLIENT_TOKEN:-}
DD_APPLICATION_ID = ${DD_APPLICATION_ID:-}
DD_SITE = ${DD_SITE:-datadoghq.eu}
XCCONFIG

echo "=== Post-clone complete ==="
