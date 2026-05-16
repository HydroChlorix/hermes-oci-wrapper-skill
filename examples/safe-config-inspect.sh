#!/usr/bin/env bash
set -euo pipefail

OCI_CONFIG="${HOME}/.oci/config"

if [ ! -f "${OCI_CONFIG}" ]; then
  printf 'oci_config: missing (%s)\n' "${OCI_CONFIG}"
  exit 1
fi

printf 'oci_config_path: %s\n' "${OCI_CONFIG}"
printf 'oci_profiles_redacted:\n'

awk '
  /^\[/ {
    section=$0
    print "  profile=" section
    next
  }
  /^[[:space:]]*region[[:space:]]*=/ {
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", $2)
    print "    region=" $2
    next
  }
  /^[[:space:]]*fingerprint[[:space:]]*=/ {
    fp=$2
    n=length(fp)
    if (n > 4) {
      print "    fingerprint=[REDACTED]..." substr(fp, n-3)
    } else {
      print "    fingerprint=[REDACTED]"
    }
    next
  }
  /^[[:space:]]*(user|tenancy|key_file|pass_phrase|security_token_file)[[:space:]]*=/ {
    split($0, kv, "=")
    key=kv[1]
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", key)
    print "    " key "=[REDACTED]"
    next
  }
' "${OCI_CONFIG}"
