#!/usr/bin/env bash
# Switches to the overlay's target project and provisions the matomo-mariadb Secret
# (once), then applies the kustomize overlay for the named environment (defaults to dev).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENVIRONMENT="${1:-dev}"
OVERLAY_DIR="${SCRIPT_DIR}/../overlays/${ENVIRONMENT}"

if [[ ! -d "${OVERLAY_DIR}" ]]; then
  echo "Overlay not found: ${OVERLAY_DIR}" >&2
  exit 1
fi

NAMESPACE="$(awk -F': *' '/^namespace:/ {print $2; exit}' "${OVERLAY_DIR}/kustomization.yaml")"
if [[ -z "${NAMESPACE}" ]]; then
  echo "No 'namespace:' set in ${OVERLAY_DIR}/kustomization.yaml" >&2
  exit 1
fi
oc project "${NAMESPACE}"

if oc get secret matomo-mariadb >/dev/null 2>&1; then
  echo "matomo-mariadb secret already exists, leaving its credentials untouched"
else
  oc process -f "${SCRIPT_DIR}/../secrets/mariadb-secret-template.yaml" | oc apply -f -
fi

sed -i.bak 's/host: .*/host: cleanbcdx-matomo-'${ENVIRONMENT}'.apps.gold.devops.gov.bc.ca/' "${OVERLAY_DIR}/route.yaml"
rm -f "${OVERLAY_DIR}/route.yaml.bak"

oc apply -k "${OVERLAY_DIR}"

echo "Deployed."
echo "To re-build the images manually, run: oc start-build matomo-fpm --follow && oc start-build matomo-nginx --follow"
