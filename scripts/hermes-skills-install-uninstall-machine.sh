#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
hermes_bin="${HERMES_BIN:-hermes}"
skill_name="${OCI_WRAPPER_SKILL_NAME:-oci-wrapper}"
skill_category="${OCI_WRAPPER_SKILL_CATEGORY:-devops}"

if ! command -v "${hermes_bin}" >/dev/null 2>&1; then
  printf '[integration][error] hermes binary not found: %s\n' "${hermes_bin}" >&2
  exit 127
fi

tmp_parent="${TMPDIR:-/tmp}"
tmp_home="$(mktemp -d "${tmp_parent%/}/oci-wrapper-hermes-home.XXXXXX")"
server_pid=""
cleanup() {
  if [ -n "${server_pid}" ]; then
    kill "${server_pid}" 2>/dev/null || true
  fi
  case "${tmp_home}" in
    "${tmp_parent%/}"/oci-wrapper-hermes-home.*|/tmp/oci-wrapper-hermes-home.*)
      chmod -R u+rwX "${tmp_home}" 2>/dev/null || true
      rm -rf -- "${tmp_home}"
      ;;
    *)
      printf '[integration][warn] refusing to clean unexpected temp path: %s\n' "${tmp_home}" >&2
      ;;
  esac
}
trap cleanup EXIT

install_dir="${tmp_home}/skills/${skill_category}/${skill_name}"
skill_md="${install_dir}/SKILL.md"

run_hermes() {
  HERMES_HOME="${tmp_home}" HERMES_ALLOW_PRIVATE_URLS=true "${hermes_bin}" "$@"
}

python_bin=""
if command -v python3 >/dev/null 2>&1; then
  python_bin="$(command -v python3)"
elif command -v python >/dev/null 2>&1; then
  python_bin="$(command -v python)"
fi

if [ -z "${python_bin}" ]; then
  printf '[integration][error] python3/python is required for the local SKILL.md HTTP fixture\n' >&2
  exit 127
fi

local_http_port="${OCI_WRAPPER_LOCAL_HTTP_PORT:-18765}"
local_http_url="http://127.0.0.1:${local_http_port}/SKILL.md"
(
  cd "${repo_root}"
  exec "${python_bin}" -m http.server "${local_http_port}" --bind 127.0.0.1
) >"${tmp_home}/skill-http.log" 2>&1 &
server_pid="$!"

"${python_bin}" - <<PY
import sys, time, urllib.request
url = "${local_http_url}"
for _ in range(50):
    try:
        with urllib.request.urlopen(url, timeout=0.5) as resp:
            if resp.status == 200:
                sys.exit(0)
    except Exception:
        time.sleep(0.1)
print(f"local skill HTTP fixture did not become ready: {url}", file=sys.stderr)
sys.exit(1)
PY

resolve_default_skill_url() {
  if [ -n "${OCI_WRAPPER_SKILL_URL:-}" ]; then
    printf '%s\n' "${OCI_WRAPPER_SKILL_URL}"
    return
  fi

  # Hermes v0.13 accepts direct HTTP(S) SKILL.md URLs, not local file paths.
  # Default to the public main branch for local opt-in runs. CI can override
  # OCI_WRAPPER_SKILL_URL to the exact checked-out commit SHA.
  printf 'https://raw.githubusercontent.com/HydroChlorix/hermes-oci-wrapper-skill/main/SKILL.md\n'
}

skill_url="$(resolve_default_skill_url)"

printf '[integration] runtime=machine\n'
printf '[integration] repo_root=%s\n' "${repo_root}"
printf '[integration] HERMES_HOME=%s\n' "${tmp_home}"
printf '[integration] skill_url=%s\n' "${skill_url}"
printf '[integration] skill=%s category=%s\n' "${skill_name}" "${skill_category}"
run_hermes --version

install_candidates=("${local_http_url}" "${repo_root}/SKILL.md" "${skill_url}")
installed=0
for candidate in "${install_candidates[@]}"; do
  printf '[integration] installing %s\n' "${candidate}"
  if run_hermes skills install "${candidate}" --category "${skill_category}" --yes --force && [ -f "${skill_md}" ]; then
    installed=1
    break
  fi
  printf '[integration][warn] install candidate failed: %s\n' "${candidate}" >&2
done

if [ "${installed}" -ne 1 ]; then
  printf '[integration][error] all install candidates failed\n' >&2
  exit 1
fi

test -d "${install_dir}"
test -f "${skill_md}"
grep -q "^name: ${skill_name}$" "${skill_md}"
run_hermes skills list | grep -F "${skill_name}"

printf '[integration] uninstalling %s\n' "${skill_name}"
if run_hermes skills uninstall --help | grep -q -- '--yes'; then
  run_hermes skills uninstall "${skill_name}" --yes
else
  printf 'y\n' | run_hermes skills uninstall "${skill_name}"
fi

test ! -e "${install_dir}"
if run_hermes skills list | grep -F "${skill_name}"; then
  printf '[integration][error] skill still appears in skills list after uninstall\n' >&2
  exit 1
fi

printf 'INTEGRATION PASS: %s machine install/uninstall round-trip succeeded\n' "${skill_name}"
