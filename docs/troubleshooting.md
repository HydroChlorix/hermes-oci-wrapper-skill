# Troubleshooting

## `oci` command missing

Symptom:
- `oci --version` fails

Action:
- install the OCI CLI on the local machine
- rerun `bash install.sh`
- rerun `bash examples/check-oci-readiness.sh`

## `~/.oci/config` missing

Symptom:
- readiness check reports missing config

Action:
- create or restore the local OCI CLI config under `~/.oci/config`
- rerun the redacted inspection example

## Authorization failures

Symptoms:
- CLI installed and config exists, but OCI API calls fail

Checks:
- confirm the intended profile
- confirm the configured region
- confirm the key file referenced by `~/.oci/config` still exists locally
- confirm the account/user is still authorized

## Wrong region or profile

Symptoms:
- resource lookup fails or appears empty

Action:
- inspect redacted profile names and region values with `examples/safe-config-inspect.sh`
- export the intended `OCI_CLI_PROFILE` before running read-only OCI commands

## Upstream OCI skill missing or stubbed

Symptom:
- `~/.hermes/vendor/oracle-skills/oci/SKILL.md` is absent or insufficient

Action:
- run `bash update-upstream.sh`
- search `~/.hermes/vendor/oracle-skills` for OCI-related docs
- stay in readiness/read-only mode until the upstream OCI skill grows enough guidance for the requested task

## Upstream repo update fails

Symptoms:
- `git pull --ff-only` reports divergence or missing repo

Action:
- rerun `bash install.sh` if the repo is missing
- if the repo diverged locally, resolve manually or reclone the vendor copy
