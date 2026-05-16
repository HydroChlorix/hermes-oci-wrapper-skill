# Wrapper Design

## Goal

Provide a small Hermes OCI wrapper skill that depends on local OCI CLI authentication and delegates detailed OCI knowledge to the upstream `HydroChlorix/oracle-skills` repository.

## Design Principles

1. Keep the wrapper small.
2. Do not duplicate large upstream OCI documentation.
3. Keep local readiness checks explicit and safe.
4. Treat OCI write operations as high impact.
5. Make missing upstream OCI content visible instead of hiding it.

## Local Dependency Model

- OCI CLI comes from the local machine.
- OCI auth comes from the local `~/.oci/config`.
- Upstream guidance comes from `~/.hermes/vendor/oracle-skills`.

## Delegation Strategy

Preferred lookup order:
1. `~/.hermes/vendor/oracle-skills/oci/SKILL.md`
2. targeted search under `~/.hermes/vendor/oracle-skills` for OCI-related docs
3. read-only local discovery only

If the upstream `oci/SKILL.md` file is missing, the wrapper should not invent a full OCI operating model. It should explicitly report the gap and stay conservative.

## Why This Wrapper Exists

- lets Hermes reuse local OCI auth without copying secrets
- provides a stable install/readiness workflow
- centralizes safety policy for OCI actions
- keeps upstream Oracle content updateable via `update-upstream.sh`
