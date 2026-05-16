#!/usr/bin/env bash
set -euo pipefail

OCI_CONFIG="${HOME}/.oci/config"
UPSTREAM_OCI_SKILL="${HOME}/.hermes/vendor/oracle-skills/oci/SKILL.md"

status=0

printf 'oci_wrapper_readiness\n'

if command -v oci >/dev/null 2>&1; then
  printf 'oci_cli: present\n'
  oci --version | head -n 1 | sed 's/^/oci_version: /'
else
  printf 'oci_cli: missing\n'
  status=1
fi

if [ -f "${OCI_CONFIG}" ]; then
  printf 'oci_config: present (%s)\n' "${OCI_CONFIG}"
else
  printf 'oci_config: missing (%s)\n' "${OCI_CONFIG}"
  status=1
fi

if [ -f "${UPSTREAM_OCI_SKILL}" ]; then
  printf 'upstream_oci_skill: present (%s)\n' "${UPSTREAM_OCI_SKILL}"
else
  printf 'upstream_oci_skill: missing (%s)\n' "${UPSTREAM_OCI_SKILL}"
  printf 'upstream_fallback: search ~/.hermes/vendor/oracle-skills for OCI-related docs before acting\n'
fi

exit "$status"
