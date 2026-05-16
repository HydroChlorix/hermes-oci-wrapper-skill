# Safety Rules

## Allowed by Default

Read-only and local-safety operations only:
- `oci --version`
- `oci --help`
- checking whether `~/.oci/config` exists
- redacted profile/region inspection
- cloning or updating the upstream `oracle-skills` repo
- read-only upstream documentation search

## Requires Explicit Confirmation

Do not proceed without the human explicitly approving:
- creating billable OCI resources
- terminating, deleting, or replacing OCI resources
- changing IAM policies, groups, dynamic groups, or compartments
- opening public ingress or broadening network/security-list/NSG rules
- rotating, replacing, exporting, or deleting credentials
- running `terraform apply`
- running `terraform destroy`
- multi-region or multi-compartment mutations

## Secret Handling

Never print:
- private keys
- auth tokens
- full `~/.oci/config`
- full fingerprint values
- user or tenancy OCIDs unless the human explicitly asked and disclosure is safe

Use `[REDACTED]` in logs and examples.
