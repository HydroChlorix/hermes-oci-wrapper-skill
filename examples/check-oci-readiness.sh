#!/usr/bin/env bash
set -euo pipefail

HOME_DIR="${HOME}"
OCI_CONFIG="${HOME_DIR}/.oci/config"
UPSTREAM_SKILL="${HOME_DIR}/.hermes/vendor/oracle-skills/oci/SKILL.md"

pass() {
  printf '[readiness][ok] %s
' "$*"
}

warn() {
  printf '[readiness][warn] %s
' "$*" >&2
}

if command -v oci >/dev/null 2>&1; then
  pass "oci cli present"
else
  warn 'oci cli missing from PATH'
fi

if [ -f "$OCI_CONFIG" ]; then
  pass "oci config present at ${OCI_CONFIG}"
else
  warn "oci config missing at ${OCI_CONFIG}"
fi

if [ -f "$UPSTREAM_SKILL" ]; then
  pass "upstream skill present at ${UPSTREAM_SKILL}"
else
  warn "upstream skill missing at ${UPSTREAM_SKILL}"
fi
