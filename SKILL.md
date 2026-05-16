---
name: oci-wrapper
description: Use when the user wants Hermes to work with Oracle Cloud Infrastructure through the local OCI CLI and local ~/.oci/config while delegating detailed OCI guidance to HydroChlorix/oracle-skills.
version: 0.1.3
author: Hermes Agent
license: UPL-1.0
metadata:
  hermes:
    tags: [oci, oracle-cloud, oracle-skills, wrapper, devops, cloud]
    related_skills: [hermes-agent]
---

# OCI Wrapper

## Overview

This wrapper skill keeps OCI enablement lightweight.

It does not duplicate large Oracle Cloud Infrastructure reference material. Instead, it validates the local execution environment, points Hermes at the upstream `HydroChlorix/oracle-skills` repository, and adds safety boundaries for using the local `oci` CLI with the local `~/.oci/config`.

Primary upstream reference:
- `~/.hermes/vendor/oracle-skills/oci/SKILL.md`

Use this wrapper when the machine should rely on its own OCI CLI install and `~/.oci/config`, not on embedded credentials, copied config snippets, or vendor-specific secrets inside the skill repo.

## When to Use

Use when:
- the user wants OCI readiness checks before any cloud action
- the user wants Hermes to inspect OCI configuration safely without printing secrets
- the user wants to use the local `oci` CLI and local `~/.oci/config`
- the user wants Hermes to defer deeper OCI guidance to `HydroChlorix/oracle-skills`
- the user wants explicit confirmation boundaries around billable, destructive, or public-exposure changes

Do not use when:
- the user expects this repo to replace OCI CLI installation or authentication setup entirely
- the user wants copied Oracle documentation inside this wrapper repo
- the user needs fully automated destructive or billable changes without confirmation

## Readiness Workflow

1. Run `bash ~/.hermes/skills/devops/oci-wrapper/install.sh`.
2. Confirm the script can find or update `~/.hermes/vendor/oracle-skills`.
3. Confirm the script can find `oci` on `PATH`.
4. Confirm the script can find `~/.oci/config`.
5. Confirm the script can find `~/.hermes/vendor/oracle-skills/oci/SKILL.md`.
6. If readiness is incomplete, stop and fix the local prerequisite instead of guessing.

Read-only readiness and inspection commands are allowed without extra confirmation.

## Safe Read-Only Operations

Allowed without extra approval:
- `oci --version`
- `oci iam region-subscription list --config-file ~/.oci/config --profile <profile>`
- `oci os ns get --config-file ~/.oci/config --profile <profile>`
- listing compartments, VCNs, subnets, instances, buckets, and policies in read-only mode
- checking current profile names, tenancy OCIDs, user OCIDs, fingerprint presence, key file path existence, and configured regions if values are redacted appropriately
- reading upstream guidance from `~/.hermes/vendor/oracle-skills/oci/SKILL.md`

Always redact secrets. Never print:
- private key contents
- auth tokens
- API keys
- session tokens
- full `~/.oci/config`
- unredacted OCIDs when the user explicitly asked for secret-safe output

## Mandatory Confirmation Boundaries

Get explicit user confirmation before:
- creating billable resources
- terminating, deleting, or replacing resources
- changing IAM policies or group membership
- opening public ingress or widening network exposure
- rotating, generating, exporting, or deleting credentials
- `terraform apply`
- `terraform destroy`
- bulk writes, patches, or lifecycle actions across multiple OCI resources

When approval is granted, restate the exact target scope first.

## Using Upstream Guidance

After readiness passes, use the upstream OCI guidance as the domain source of truth:

1. Read `~/.hermes/vendor/oracle-skills/oci/SKILL.md`.
2. If the upstream repo later adds more OCI sub-skills, prefer those rather than expanding this wrapper with copied docs.
3. Keep this wrapper focused on:
   - readiness
   - safe inspection
   - confirmation boundaries
   - handoff to upstream OCI knowledge

## Troubleshooting Shortlist

- Missing `oci` binary: install OCI CLI separately, then rerun readiness.
- Missing `~/.oci/config`: configure local OCI auth separately, then rerun readiness.
- Wrong region or profile: inspect with `bash examples/safe-config-inspect.sh` and rerun read-only OCI commands with the intended profile.
- Authorization failures: verify the selected profile, region, tenancy, fingerprint, and private key path exist locally.
- Missing upstream skill: rerun `install.sh` or `update-upstream.sh`; if upstream only contains a stub, keep this wrapper minimal and avoid copying large docs.

## Verification Checklist

- [ ] `install.sh` completes and reports readiness status without printing secrets
- [ ] `~/.hermes/vendor/oracle-skills/oci/SKILL.md` exists
- [ ] `bash examples/check-oci-readiness.sh` runs successfully
- [ ] `bash examples/safe-config-inspect.sh` prints only redacted values
- [ ] `hermes chat -s oci-wrapper -q "Use the OCI wrapper skill. Check readiness only. Do not print secrets." -Q` loads the skill
