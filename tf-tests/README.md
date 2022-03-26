# Testing Terraform code

Reference: <https://www.hashicorp.com/blog/testing-hashicorp-terraform>

## Unit tests

Unit tests verify individual resources and configurations for expected values.

Configuration parsing, `terraform fmt -check`, and `terraform validate` do not require active infrastructure resources or authentication to an infrastructure provider.

```bash
terraform-2 fmt -check ./terraform-google-cloud-storage
terraform-2 fmt -check ./terraform-google-cloud-storage/cloud-storage-module
```

```bash
cd terraform-google-cloud-storage
terraform-2 validate
terraform-2 validate ./cloud-storage-module
```

## Security Testing

Security Testing is design to uncovers vulnerabilities, threats, and risks in a software application. This is no different when we are doing IaC.

For this testing I'm using the [tfsec](https://aquasecurity.github.io/tfsec/v1.15.0/) from [Aquasec](https://www.aquasec.com). It's a tool designed specifically to review Terraform code.

You can find the installation steps in the [Official Documentation](https://aquasecurity.github.io/tfsec/v1.15.0/guides/installation/).

You can run `tfsec` from the root directory and it will scan all `tf` files:

```bash
tfsec

  timings
  ──────────────────────────────────────────
  disk i/o             703.643µs
  parsing              204.474µs
  adaptation           135.687µs
  checks               10.106125ms
  total                11.149929ms

  counts
  ──────────────────────────────────────────
  blocks               7
  modules              1
  files                2

  results
  ──────────────────────────────────────────
  passed               0
  ignored              0
  critical             0
  high                 0
  medium               0
  low                  0


No problems detected!
```

## Contract testing

Contract tests check that a configuration using a Terraform module passes properly formatted inputs.

For this test the [Module Experiment Testing](https://www.terraform.io/language/modules/testing-experiment) was configured.

This test will validate if the correct `bucket` was created.

Steps to configure:

1. Create an [outputs.tf](../terraform-google-cloud-storage/cloud-storage-module/outputs.tf) file to export the `bucket name`.
2. Within the `terraform-google-cloud-storage/cloud-storage-module` create a new sub-folder `tests/defaults`.
3. In the `defaults` directory create a [defaults.tf](../terraform-google-cloud-storage/cloud-storage-module/tests/defaults/defaults.tf) file.
4. Make sure your [variables.tf](../terraform-google-cloud-storage/cloud-storage-module/variables.tf) has a `default` assigned to each variable.
5. From the `terraform-google-cloud-storage/cloud-storage-module` folder execute:

   ```bash
   terraform-2 test

   Warning: The "terraform test" command is experimental
   │ 
   │ We'd like to invite adventurous module authors to write integration tests for their modules using this command, but all of the     behaviors of this command
   │ are currently experimental and may change based on feedback.
   │ 
   │ For more information on the testing experiment, including ongoing research goals and avenues for feedback, see:
   │     https://www.terraform.io/docs/language/modules/testing-experiment.html
   ╵
   Success! All of the test assertions passed.
   ```
