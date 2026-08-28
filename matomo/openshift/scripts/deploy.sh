#!/usr/bin/env bash
# Provisions the matomo-mariadb Secret (once) and applies the kustomize overlay for the
# named environment (defaults to dev) into the namespace currently selected by `oc project`.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OVERLAY_DIR="${SCRIPT_DIR}/../overlays/${1:-dev}"

if [[ ! -d "${OVERLAY_DIR}" ]]; then
  echo "Overlay not found: ${OVERLAY_DIR}" >&2
  exit 1
fi

if oc get secret matomo-mariadb >/dev/null 2>&1; then
  echo "matomo-mariadb secret already exists, leaving its credentials untouched"
else
  oc process -f "${SCRIPT_DIR}/../secrets/mariadb-secret-template.yaml" | oc apply -f -
fi

oc apply -k "${OVERLAY_DIR}"

echo "Deployed. Start the initial builds with: oc start-build matomo-fpm --follow && oc start-build matomo-nginx --follow"
