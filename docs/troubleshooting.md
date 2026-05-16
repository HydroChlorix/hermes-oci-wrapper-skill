# Troubleshooting

## `oci` command not found

Symptom:
- readiness warns that OCI CLI is missing from `PATH`

What to check:
- install OCI CLI separately
- ensure the shell PATH used by Hermes includes the CLI binary
- rerun `bash install.sh`

## `~/.oci/config` missing

Symptom:
- readiness warns that local OCI config is missing

What to check:
- create or restore the local OCI profile configuration
- verify the file path is exactly `~/.oci/config`
- rerun `bash examples/safe-config-inspect.sh`

## Authorization failures

Symptom:
- read-only `oci` commands fail with auth or permission errors

What to check:
- selected `--profile`
- configured `region`
- tenancy and user OCIDs in the profile
- local private key file path exists
- policy permissions for the target compartment or tenancy

## Wrong region or wrong profile

Symptom:
- commands succeed but query the wrong tenancy, region, or resources

What to check:
- use `bash examples/safe-config-inspect.sh`
- specify `--profile <name>` explicitly in `oci` commands
- add `--region <region>` when testing read-only calls

## Upstream skill missing

Symptom:
- `install.sh` warns that `~/.hermes/vendor/oracle-skills/oci/SKILL.md` is missing

What to check:
- network access to GitHub
- the upstream repo URL is reachable
- rerun `bash update-upstream.sh`

## Upstream skill is only a stub

Symptom:
- `install.sh` warns that the upstream OCI skill still looks like a sample skeleton

What to do:
- keep using this wrapper for readiness and safety behavior
- inspect the upstream repo for newly added OCI sub-skills or richer docs
- avoid copying large OCI documentation into this wrapper repo unless the project scope changes
