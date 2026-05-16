#!/usr/bin/env bash
set -euo pipefail

UPSTREAM_DIR="${HOME}/.hermes/vendor/oracle-skills"

if [ ! -d "$UPSTREAM_DIR/.git" ]; then
  printf '[oci-wrapper][error] upstream checkout missing at %s
' "$UPSTREAM_DIR" >&2
  exit 1
fi

git -C "$UPSTREAM_DIR" pull --ff-only
