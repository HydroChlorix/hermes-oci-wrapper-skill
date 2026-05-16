#!/usr/bin/env bash
set -euo pipefail

VENDOR_ROOT="${HOME}/.hermes/vendor"
UPSTREAM_DIR="${VENDOR_ROOT}/oracle-skills"
UPSTREAM_URL="https://github.com/HydroChlorix/oracle-skills"
OCI_CONFIG="${HOME}/.oci/config"
UPSTREAM_OCI_SKILL="${UPSTREAM_DIR}/oci/SKILL.md"

log() {
  printf '[oci-wrapper] %s\n' "$*"
}

log "preparing vendor directory: ${VENDOR_ROOT}"
mkdir -p "${VENDOR_ROOT}"

if [ -d "${UPSTREAM_DIR}/.git" ]; then
  log "updating upstream oracle-skills clone"
  git -C "${UPSTREAM_DIR}" pull --ff-only
else
  log "cloning upstream oracle-skills into ${UPSTREAM_DIR}"
  git clone --depth 1 "${UPSTREAM_URL}" "${UPSTREAM_DIR}"
fi

if command -v oci >/dev/null 2>&1; then
  log "oci cli detected: $(oci --version 2>/dev/null | head -n 1)"
else
  log "warning: oci cli not found in PATH"
fi

if [ -f "${OCI_CONFIG}" ]; then
  log "oci config detected at ${OCI_CONFIG}"
else
  log "warning: oci config missing at ${OCI_CONFIG}"
fi

if [ -f "${UPSTREAM_OCI_SKILL}" ]; then
  log "upstream OCI skill detected at ${UPSTREAM_OCI_SKILL}"
else
  log "warning: upstream OCI skill missing at ${UPSTREAM_OCI_SKILL}"
  log "fall back to targeted searches inside ${UPSTREAM_DIR} until upstream OCI skill content exists"
fi

log "install readiness checks complete"
