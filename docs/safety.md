# OCI wrapper safety rules

## Always allowed without extra approval

- checking whether `oci` exists
- checking whether `~/.oci/config` exists
- reading profile names and redacted metadata from local OCI config
- running read-only OCI identity, namespace, compartment, networking, and inventory queries
- pulling upstream skill updates with `update-upstream.sh`

## Explicit confirmation required

Require a clear user confirmation before any of the following:

- creating billable resources
- terminating, deleting, or force-replacing resources
- changing IAM policies, dynamic groups, group membership, or federation rules
- opening public ingress, changing security lists, widening NSGs, or exposing new load balancers
- rotating, generating, exporting, or deleting credentials or keys
- writing Terraform state changes with `terraform apply`
- destroying infrastructure with `terraform destroy`
- modifying many OCI resources in one batch action

## Redaction requirements

Never print:
- private key contents
- auth tokens
- API signing keys
- full `~/.oci/config`
- raw credential files

Prefer:
- existence checks
- profile names
- redacted OCID prefixes when needed
- region names
- filesystem paths without file contents

## Reasoning model

- read-only discovery is low-risk and should be fast
- write actions are medium or high risk and need explicit scope confirmation
- destructive or public-exposure changes must be acknowledged before execution
