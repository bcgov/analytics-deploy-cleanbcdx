#!/usr/bin/env bash
# Switches to the overlay's target project, then deletes the kustomize-managed resources
# for the named environment (defaults to dev).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OVERLAY_DIR="${SCRIPT_DIR}/../overlays/${1:-dev}"

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

oc delete -k "${OVERLAY_DIR}" --ignore-not-found

echo "Kustomize-managed resources deleted, including the matomo and matomo-mariadb PersistentVolumeClaims." \
     "The matomo-mariadb Secret is provisioned separately and is not managed by kustomize;" \
     "delete it manually (oc delete secret matomo-mariadb) if you also want to discard stored credentials."
