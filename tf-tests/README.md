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
