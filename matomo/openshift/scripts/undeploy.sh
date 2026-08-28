#!/usr/bin/env bash
# Deletes the kustomize-managed resources for the named environment (defaults to dev) from
# the namespace currently selected by `oc project`.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OVERLAY_DIR="${SCRIPT_DIR}/../overlays/${1:-dev}"

if [[ ! -d "${OVERLAY_DIR}" ]]; then
  echo "Overlay not found: ${OVERLAY_DIR}" >&2
  exit 1
fi

oc delete -k "${OVERLAY_DIR}" --ignore-not-found

echo "Kustomize-managed resources deleted. The matomo-mariadb Secret and PersistentVolumeClaims" \
     "are not managed by kustomize and are left in place; delete them manually" \
     "(oc delete secret matomo-mariadb; oc delete pvc -l \"app in (matomo,matomo-mariadb)\")" \
     "if you also want to discard stored credentials/data."
