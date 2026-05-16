#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
image="${HERMES_DOCKER_IMAGE:-nousresearch/hermes-agent:latest}"
skill_name="${OCI_WRAPPER_SKILL_NAME:-oci-wrapper}"
skill_category="${OCI_WRAPPER_SKILL_CATEGORY:-devops}"
skill_url="${OCI_WRAPPER_SKILL_URL:-https://raw.githubusercontent.com/HydroChlorix/hermes-oci-wrapper-skill/main/SKILL.md}"
docker_platform_args=()

if ! command -v docker >/dev/null 2>&1; then
  printf '[integration][error] docker is not available\n' >&2
  exit 127
fi

if [ -n "${DOCKER_PLATFORM:-}" ]; then
  docker_platform_args=(--platform "${DOCKER_PLATFORM}")
fi

printf '[integration] runtime=docker\n'
printf '[integration] image=%s\n' "${image}"
printf '[integration] repo_root=%s\n' "${repo_root}"
printf '[integration] skill_url=%s\n' "${skill_url}"
printf '[integration] skill=%s category=%s\n' "${skill_name}" "${skill_category}"

docker run --rm \
  "${docker_platform_args[@]}" \
  --entrypoint /bin/bash \
  -v "${repo_root}:/workspace:ro" \
  -e OCI_WRAPPER_SKILL_URL="${skill_url}" \
  -e OCI_WRAPPER_SKILL_NAME="${skill_name}" \
  -e OCI_WRAPPER_SKILL_CATEGORY="${skill_category}" \
  "${image}" \
  -lc '
set -euo pipefail

export HOME=/tmp/hermes-user
export HERMES_HOME=/tmp/hermes-data
mkdir -p "${HOME}" "${HERMES_HOME}"
export HERMES_ALLOW_PRIVATE_URLS=true

if command -v hermes >/dev/null 2>&1; then
  HERMES="$(command -v hermes)"
elif [ -x /opt/hermes/.venv/bin/hermes ]; then
  HERMES=/opt/hermes/.venv/bin/hermes
else
  printf "[container][error] hermes binary not found\n" >&2
  exit 127
fi

INSTALL_DIR="${HERMES_HOME}/skills/${OCI_WRAPPER_SKILL_CATEGORY}/${OCI_WRAPPER_SKILL_NAME}"
SKILL_MD="${INSTALL_DIR}/SKILL.md"

printf "[container] id: "
id
printf "[container] HERMES_HOME=%s\n" "${HERMES_HOME}"
"${HERMES}" --version

if command -v python3 >/dev/null 2>&1; then
  PYTHON_BIN="$(command -v python3)"
elif command -v python >/dev/null 2>&1; then
  PYTHON_BIN="$(command -v python)"
else
  printf "[container][error] python3/python is required for the local SKILL.md HTTP fixture\n" >&2
  exit 127
fi

LOCAL_HTTP_PORT="${OCI_WRAPPER_LOCAL_HTTP_PORT:-18765}"
LOCAL_HTTP_URL="http://127.0.0.1:${LOCAL_HTTP_PORT}/SKILL.md"
(
  cd /workspace
  exec "${PYTHON_BIN}" -m http.server "${LOCAL_HTTP_PORT}" --bind 127.0.0.1
) >/tmp/skill-http.log 2>&1 &
SERVER_PID="$!"
trap "kill ${SERVER_PID} 2>/dev/null || true" EXIT

"${PYTHON_BIN}" - <<PY
import sys, time, urllib.request
url = "${LOCAL_HTTP_URL}"
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

install_candidates=("${LOCAL_HTTP_URL}" /workspace/SKILL.md "${OCI_WRAPPER_SKILL_URL}")
installed=0
for candidate in "${install_candidates[@]}"; do
  printf "[container] installing %s\n" "${candidate}"
  if "${HERMES}" skills install "${candidate}" \
    --category "${OCI_WRAPPER_SKILL_CATEGORY}" \
    --yes \
    --force && [ -f "${SKILL_MD}" ]; then
    installed=1
    break
  fi
  printf "[container][warn] install candidate failed: %s\n" "${candidate}" >&2
done

if [ "${installed}" -ne 1 ]; then
  printf "[container][error] all install candidates failed\n" >&2
  exit 1
fi

test -d "${INSTALL_DIR}"
test -f "${SKILL_MD}"
grep -q "^name: ${OCI_WRAPPER_SKILL_NAME}$" "${SKILL_MD}"
"${HERMES}" skills list | grep -F "${OCI_WRAPPER_SKILL_NAME}"

printf "[container] uninstalling %s\n" "${OCI_WRAPPER_SKILL_NAME}"
if "${HERMES}" skills uninstall --help | grep -q -- "--yes"; then
  "${HERMES}" skills uninstall "${OCI_WRAPPER_SKILL_NAME}" --yes
else
  printf "y\n" | "${HERMES}" skills uninstall "${OCI_WRAPPER_SKILL_NAME}"
fi

test ! -e "${INSTALL_DIR}"
if "${HERMES}" skills list | grep -F "${OCI_WRAPPER_SKILL_NAME}"; then
  printf "[container][error] skill still appears in skills list after uninstall\n" >&2
  exit 1
fi

printf "[container] round-trip ok\n"
'

printf 'INTEGRATION PASS: %s Docker install/uninstall round-trip succeeded\n' "${skill_name}"
