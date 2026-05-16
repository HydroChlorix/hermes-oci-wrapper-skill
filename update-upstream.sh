#!/usr/bin/env bash
set -euo pipefail

UPSTREAM_DIR="${HOME}/.hermes/vendor/oracle-skills"

if [ ! -d "${UPSTREAM_DIR}/.git" ]; then
  printf '[oci-wrapper] upstream repo missing at %s\n' "${UPSTREAM_DIR}" >&2
  printf '[oci-wrapper] run install.sh first\n' >&2
  exit 1
fi

git -C "${UPSTREAM_DIR}" pull --ff-only
printf '[oci-wrapper] upstream update complete: %s\n' "${UPSTREAM_DIR}"
