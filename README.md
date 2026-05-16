# Hermes OCI Wrapper Skill

A lightweight Hermes skill wrapper for Oracle Cloud Infrastructure (OCI).

This repo does not vendor large OCI docs. Instead, it:
- verifies local OCI prerequisites (`oci` CLI and `~/.oci/config`)
- clones or updates the upstream `HydroChlorix/oracle-skills` repo into `~/.hermes/vendor/oracle-skills`
- points Hermes to upstream OCI guidance when available
- enforces read-only-by-default behavior for OCI inspection

## Install into Hermes skills

Option 1: clone directly into the local Hermes skills tree.

```bash
git clone git@github.com:HydroChlorix/hermes-oci-wrapper-skill.git ~/.hermes/skills/devops/oci-wrapper
bash ~/.hermes/skills/devops/oci-wrapper/install.sh
```

Option 2: clone anywhere and use the skill content as reference.

## What `install.sh` does

- creates `~/.hermes/vendor`
- clones or updates `https://github.com/HydroChlorix/oracle-skills` into `~/.hermes/vendor/oracle-skills`
- checks whether the `oci` CLI is installed
- checks whether `~/.oci/config` exists
- checks whether `~/.hermes/vendor/oracle-skills/oci/SKILL.md` exists
- never prints secrets from local OCI config

## Files

- `SKILL.md` - wrapper skill definition
- `install.sh` - vendor sync + readiness checks
- `update-upstream.sh` - fast-forward upstream updates only
- `examples/check-oci-readiness.sh` - safe prerequisite check
- `examples/safe-config-inspect.sh` - redacted config inspection
- `docs/design.md` - wrapper design notes
- `docs/safety.md` - allowed vs confirmation-required actions
- `docs/troubleshooting.md` - common failure modes

## Validation commands

```bash
bash install.sh
bash examples/check-oci-readiness.sh
bash examples/safe-config-inspect.sh
hermes chat -s oci-wrapper -q "Use the OCI wrapper skill. Check readiness only. Do not print secrets." -Q
```

## Notes

- The wrapper prefers upstream `oci/SKILL.md` when present.
- If upstream OCI skill content is missing or still a stub, the wrapper falls back to targeted upstream repo search and local readiness-only guidance.
- Read-only inspection is allowed by default. Any billable, destructive, IAM-changing, public-ingress, credential-rotating, or Terraform apply/destroy action requires explicit confirmation first.
