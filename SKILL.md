---
name: oci-wrapper
description: Use when inspecting Oracle Cloud Infrastructure safely from Hermes with local OCI CLI credentials and upstream oracle-skills guidance.
version: 0.1.0
author: HydroChlorix
license: MIT
metadata:
  hermes:
    tags: [oci, oracle-cloud, oracle-skills, wrapper, devops, cloud]
    related_skills: [hermes-agent]
---

# OCI Wrapper

## Overview

This wrapper skill helps Hermes work with Oracle Cloud Infrastructure using the local `oci` CLI and local `~/.oci/config` authentication model.

It intentionally avoids duplicating large OCI documentation. Instead, it verifies local readiness, keeps a local clone of `HydroChlorix/oracle-skills` under `~/.hermes/vendor/oracle-skills`, and delegates detailed OCI guidance to that upstream repo when available.

## When to Use

Use this skill when:
- you need safe, read-only OCI readiness checks
- you want Hermes to inspect local OCI CLI/config state without printing secrets
- you want an OCI wrapper that points to upstream `oracle-skills` content instead of vendoring OCI docs
- you need guarded behavior before any billable, destructive, or security-sensitive OCI action

Do not use this skill when:
- you need to store secrets in repo files
- you want this wrapper to replace the OCI CLI
- you want to bypass confirmation for destructive or billable actions

## Readiness Workflow

1. Run `bash ~/.hermes/skills/devops/oci-wrapper/install.sh`.
2. Run `bash ~/.hermes/skills/devops/oci-wrapper/examples/check-oci-readiness.sh`.
3. If needed, run `bash ~/.hermes/skills/devops/oci-wrapper/examples/safe-config-inspect.sh`.
4. Check upstream guidance in `~/.hermes/vendor/oracle-skills`:
   - prefer `~/.hermes/vendor/oracle-skills/oci/SKILL.md` when present
   - otherwise search the upstream repo for OCI-related docs before acting
5. Keep actions read-only unless the human explicitly approves higher-risk changes.

## Wrapper Rules

- Never print private keys, auth tokens, full `~/.oci/config`, unredacted fingerprints, or credential files.
- Prefer discovery commands first: `oci --version`, `oci --help`, `oci iam region list`, `oci os ns get`, or similar read-only commands only after readiness is confirmed.
- If `~/.hermes/vendor/oracle-skills/oci/SKILL.md` is missing, say so explicitly and fall back to targeted upstream repo search instead of inventing OCI procedures.
- Treat OCI changes as high impact unless clearly read-only.

## Allowed Without Extra Confirmation

Read-only checks such as:
- `oci --version`
- `oci --help`
- verifying whether `~/.oci/config` exists
- listing available profile names from `~/.oci/config` in redacted form
- upstream repo sync/read operations
- read-only OCI inspection that does not create cost, modify IAM, or alter network exposure

## Requires Explicit Human Confirmation First

Always ask before:
- creating billable resources
- terminating or deleting resources
- changing IAM policies or identity configuration
- opening public ingress or modifying security lists / NSGs
- rotating, deleting, or replacing credentials
- running `terraform apply`
- running `terraform destroy`
- any bulk mutation across compartments or regions

## Upstream Delegation Pattern

When the upstream repo contains the needed OCI guidance:
- cite the upstream path you used
- follow its guardrails
- keep local output redacted

When the upstream repo does not yet contain the needed OCI guidance:
- report that `oci/SKILL.md` is missing or incomplete
- search the upstream repo for nearby Oracle/OCI content
- limit yourself to readiness checks and safe discovery unless the human provides a narrower request

## Common Pitfalls

1. Assuming `oci` is installed because SSH auth exists. Check `oci --version` directly.
2. Dumping `~/.oci/config` to the screen. Use the redacted inspection example instead.
3. Treating missing upstream `oci/SKILL.md` as permission to invent full OCI runbooks. Do not do that.
4. Performing billable or destructive OCI changes without explicit confirmation.
5. Forgetting that region/profile mismatches can look like auth failures.

## Verification Checklist

- [ ] `install.sh` completed without printing secrets
- [ ] `~/.hermes/vendor/oracle-skills` exists
- [ ] local OCI CLI presence or absence has been reported accurately
- [ ] local `~/.oci/config` presence or absence has been reported accurately
- [ ] upstream `oci/SKILL.md` presence or absence has been reported accurately
- [ ] high-impact OCI actions are gated behind explicit confirmation
