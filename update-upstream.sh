#!/usr/bin/env bash
set -euo pipefail

UPSTREAM_DIR="${HERMES_HOME:-${HOME}/.hermes}/vendor/oracle-skills"

if [ ! -d "$UPSTREAM_DIR/.git" ]; then
  printf '[oci-wrapper][error] upstream checkout missing at %s\n' "$UPSTREAM_DIR" >&2
  exit 1
fi

if ! git -C "$UPSTREAM_DIR" pull --ff-only; then
  printf '[oci-wrapper][error] upstream update failed (network error or divergent history)\n' >&2
  exit 1
fi
