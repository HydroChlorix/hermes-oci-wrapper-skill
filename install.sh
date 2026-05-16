#!/usr/bin/env bash
set -euo pipefail

VENDOR_DIR="${HERMES_HOME:-${HOME}/.hermes}/vendor"
UPSTREAM_DIR="${VENDOR_DIR}/oracle-skills"
UPSTREAM_REPO="https://github.com/HydroChlorix/oracle-skills.git"
UPSTREAM_SKILL="${UPSTREAM_DIR}/oci/SKILL.md"
OCI_CONFIG="${HOME}/.oci/config"

note() {
  printf '[oci-wrapper] %s
' "$*"
}

warn() {
  printf '[oci-wrapper][warn] %s
' "$*" >&2
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    warn "required command missing: $1"
    return 1
  }
}

readiness_failures=0

require_cmd git || exit 1
mkdir -p "$VENDOR_DIR"

if [ -d "$UPSTREAM_DIR/.git" ]; then
  note "updating upstream oracle-skills checkout"
  git -C "$UPSTREAM_DIR" pull --ff-only >/dev/null
else
  note "cloning upstream oracle-skills"
  git clone --depth 1 "$UPSTREAM_REPO" "$UPSTREAM_DIR" >/dev/null
fi

if command -v oci >/dev/null 2>&1; then
  OCI_VERSION="$(oci --version 2>/dev/null | head -n 1 || true)"
  note "oci cli detected: ${OCI_VERSION:-present}"
else
  warn "oci cli not found on PATH"
  readiness_failures=$((readiness_failures + 1))
fi

if [ -f "$OCI_CONFIG" ]; then
  note "oci config detected at ${OCI_CONFIG}"
else
  warn "oci config missing at ${OCI_CONFIG}"
  readiness_failures=$((readiness_failures + 1))
fi

if [ -f "$UPSTREAM_SKILL" ]; then
  note "upstream skill detected at ${UPSTREAM_SKILL}"
  if grep -q 'sample domain skeleton' "$UPSTREAM_SKILL"; then
    warn "upstream oci skill appears to be a stub; rely on this wrapper for readiness/safety and monitor upstream for richer OCI content"
  fi
else
  warn "upstream OCI skill missing at ${UPSTREAM_SKILL}"
  readiness_failures=$((readiness_failures + 1))
fi

note "running bundled examples"
bash "$(dirname "$0")/examples/check-oci-readiness.sh"
bash "$(dirname "$0")/examples/safe-config-inspect.sh"

if [ "$readiness_failures" -eq 0 ]; then
  note 'readiness status: PASS'
else
  warn "readiness status: INCOMPLETE (${readiness_failures} issue(s))"
  warn 'fix missing prerequisites before attempting non-read-only OCI actions'
fi
