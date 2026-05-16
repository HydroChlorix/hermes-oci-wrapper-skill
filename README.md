# Hermes OCI Wrapper Skill

Lightweight Hermes skill wrapper for Oracle Cloud Infrastructure (OCI) work.

This repository does three things:
- uses the local `oci` CLI and local `~/.oci/config` already present on the machine
- keeps the upstream skill source as a live local Git checkout under `~/.hermes/vendor/oracle-skills`
- keeps this wrapper focused on Hermes-specific guardrails, readiness checks, and safe usage patterns instead of copying large OCI docs

The wrapper intentionally delegates detailed OCI domain guidance to `HydroChlorix/oracle-skills`, especially `oci/SKILL.md` and any future OCI sub-skills added upstream.

## Repo contents

- `SKILL.md` — installable Hermes skill wrapper
- `THIRD_PARTY_NOTICES.md` — upstream Oracle Skills attribution and trademark notice
- `install.sh` — clone/update upstream and run non-secret readiness checks
- `update-upstream.sh` — fast-forward-only refresh for the local upstream checkout
- `examples/check-oci-readiness.sh` — standalone readiness probe
- `examples/safe-config-inspect.sh` — redacted local config inspection example
- `docs/design.md` — wrapper design rationale
- `docs/safety.md` — safety policy and confirmation boundaries
- `docs/troubleshooting.md` — common failure modes and operator guidance

## Quick install

Two methods:

**A) Via Hermes skills hub (recommended for users)**

```bash
hermes skills install https://raw.githubusercontent.com/HydroChlorix/hermes-oci-wrapper-skill/main/SKILL.md \
  --category devops
```

This downloads only the SKILL.md. Supporting scripts (`install.sh`, examples) are not included — use inline checks listed in the skill itself.

**B) Full git clone (includes scripts, examples, docs)**

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

## Integration tests

The integration tests prove that Hermes can install and uninstall this skill
through the Skills Hub flow without touching the real user `~/.hermes`. Each
runtime uses an isolated temporary `HERMES_HOME`.

Default discovery is safe and skips the opt-in runtime checks:

```bash
pytest tests/integration -q
```

Machine Hermes runtime:

```bash
RUN_HERMES_MACHINE_INTEGRATION=1 pytest tests/integration/test_hermes_skills_machine.py -q -s
```

Docker Hermes runtime:

```bash
RUN_HERMES_DOCKER_INTEGRATION=1 pytest tests/integration/test_hermes_skills_docker.py -q -s
```

Set `OCI_WRAPPER_SKILL_URL` to test a specific raw `SKILL.md` URL. CI sets it
to the checked-out commit SHA.

## What this wrapper does not do

- it does not replace OCI CLI authentication
- it does not vendor Oracle docs into this repo
- it does not bypass user confirmation for high-impact OCI actions
- it does not print credential values, private keys, auth tokens, or full `~/.oci/config`

## License

This wrapper project is licensed under the Universal Permissive License (UPL), Version 1.0.

Upstream Oracle Skills repositories:

- `oracle/skills`: https://github.com/oracle/skills
- `HydroChlorix/oracle-skills`: https://github.com/HydroChlorix/oracle-skills

The upstream Oracle Skills repository is also licensed under UPL 1.0 and carries this copyright notice:

```text
Copyright (c) 2025 Oracle and/or its affiliates.
```

This wrapper does not vendor Oracle Skills into this Git repository by default. `install.sh` clones or updates it locally at:

```text
~/.hermes/vendor/oracle-skills
```

See `THIRD_PARTY_NOTICES.md` for attribution and trademark notes.

This project is not affiliated with, sponsored by, or endorsed by Oracle.
