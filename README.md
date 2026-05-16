# Hermes OCI Wrapper Skill

Lightweight Hermes skill wrapper for Oracle Cloud Infrastructure (OCI) work.

This repository does three things:
- uses the local `oci` CLI and local `~/.oci/config` already present on the machine
- vendors the upstream skill source as a live Git checkout under `~/.hermes/vendor/oracle-skills`
- keeps this wrapper focused on Hermes-specific guardrails, readiness checks, and safe usage patterns instead of copying large OCI docs

The wrapper intentionally delegates detailed OCI domain guidance to `HydroChlorix/oracle-skills`, especially `oci/SKILL.md` and any future OCI sub-skills added upstream.

## Repo contents

- `SKILL.md` — installable Hermes skill wrapper
- `install.sh` — clone/update upstream and run non-secret readiness checks
- `update-upstream.sh` — fast-forward-only refresh for the vendored upstream checkout
- `examples/check-oci-readiness.sh` — standalone readiness probe
- `examples/safe-config-inspect.sh` — redacted local config inspection example
- `docs/design.md` — wrapper design rationale
- `docs/safety.md` — safety policy and confirmation boundaries
- `docs/troubleshooting.md` — common failure modes and operator guidance

## Quick install

```bash
git clone https://github.com/HydroChlorix/hermes-oci-wrapper-skill.git ~/.hermes/skills/devops/oci-wrapper
bash ~/.hermes/skills/devops/oci-wrapper/install.sh
```

If you run Hermes with a profile-specific `HERMES_HOME`, clone into `$HERMES_HOME/skills/devops/oci-wrapper` instead.

## Quick readiness check

```bash
bash examples/check-oci-readiness.sh
bash examples/safe-config-inspect.sh
```

## Load in Hermes

```bash
hermes chat -s oci-wrapper -q "Use the OCI wrapper skill. Check readiness only. Do not print secrets." -Q
```

## What this wrapper does not do

- it does not replace OCI CLI authentication
- it does not vendor Oracle docs into this repo
- it does not bypass user confirmation for high-impact OCI actions
- it does not print credential values, private keys, auth tokens, or full `~/.oci/config`

## License

MIT. Upstream `HydroChlorix/oracle-skills` remains separately licensed by its own repository.
