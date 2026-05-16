# OCI wrapper design

## Goal

Keep the Hermes-facing OCI skill small, auditable, and easy to update while deferring detailed OCI guidance upstream.

## Design choices

1. Wrapper, not forked documentation.
   - The root skill explains how Hermes should operate safely with OCI.
   - The upstream `HydroChlorix/oracle-skills` checkout remains the source for evolving OCI guidance.

2. Local tools and local config only.
   - The wrapper assumes the operator wants to use the machine's existing `oci` CLI and existing `~/.oci/config`.
   - This avoids embedding credentials or machine-specific setup into the repo.

3. Readiness before action.
   - `install.sh` and `examples/check-oci-readiness.sh` verify the minimum prerequisites first.
   - Missing prerequisites are surfaced as actionable warnings instead of triggering unsafe guesses.

4. Safe inspection by default.
   - `examples/safe-config-inspect.sh` reports profile metadata in redacted form.
   - Full config dumps and private key reads are intentionally excluded.

5. Small update surface.
   - `update-upstream.sh` only performs `git -C ~/.hermes/vendor/oracle-skills pull --ff-only`.
   - The wrapper repo remains stable even if the upstream repo grows.

## Expected operator workflow

1. Clone this repo into the Hermes skills tree.
2. Run `install.sh`.
3. Resolve any missing local OCI prerequisites.
4. Use Hermes with `-s oci-wrapper` for read-only checks first.
5. Load upstream OCI guidance when deeper service-specific help is needed.
