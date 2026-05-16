#!/usr/bin/env bash
set -euo pipefail

HERMES_HOME="${HERMES_HOME:-${HOME}/.hermes}"
OCI_CONFIG="${HOME}/.oci/config"
UPSTREAM_SKILL="${HERMES_HOME}/vendor/oracle-skills/oci/SKILL.md"

failures=0

pass() {
  printf '[readiness][ok] %s\n' "$*"
}

warn() {
  printf '[readiness][warn] %s\n' "$*" >&2
}

if command -v oci >/dev/null 2>&1; then
  pass "oci cli present"
else
  warn 'oci cli missing from PATH'
  failures=$((failures + 1))
fi

if [ -f "$OCI_CONFIG" ]; then
  pass "oci config present at ${OCI_CONFIG}"
else
  warn "oci config missing at ${OCI_CONFIG}"
  failures=$((failures + 1))
fi

if [ -f "$UPSTREAM_SKILL" ]; then
  pass "upstream skill present at ${UPSTREAM_SKILL}"
else
  warn "upstream skill missing at ${UPSTREAM_SKILL}"
  failures=$((failures + 1))
fi

exit "$failures"
