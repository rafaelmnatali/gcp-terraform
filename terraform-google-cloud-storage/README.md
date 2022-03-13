# Terraform Google Cloud Storage Module

This module makes it easy to create one or more GCS buckets, and assign basic permissions.

The resources that this module will create/trigger are:

- One or more `GCS buckets`
- Zero or more `IAM bindings` for those buckets

> The module was written to assign permissions to [GCP service accounts](https://cloud.google.com/iam/docs/service-accounts). One can follow the same logic to extend it to [groups](https://cloud.google.com/iam/docs/groups-in-cloud-console) and `users`.

## How it works

A [Terraform module](https://www.terraform.io/language/modules/syntax#module-blocks) was created in the sub-folder `cloud-storage-modules`.

The module is configured to receive the variables defined in the local `terraform.tfvars.json`. Creating the `buckets` and assigning the `roles` as defined.

Refer to the [module documentation](./cloud-storage-module) for a detailed explanation on the module.

> This module does not create roles. It uses the [GCP Predefined roles](https://cloud.google.com/storage/docs/access-control/iam-roles#standard-roles) that already exists.

## Usage

Basic usage of this modules is as follows and can be found in the [main.tf](./main.tf) file:

```hcl
resource "random_id" "bucket" {
  keepers = {
    # Generate a new id to uniquely identify the bucket
    bucket_id = "${var.project}"
  }

  byte_length = 8
}
```

```hcl
module "gcs_bucket" {
  for_each                     = var.gcs_buckets
  source                       = "./cloud-storage-module"
  location                     = each.key
  project                      = var.project
  name                         = "${each.value.name}-${each.key}-${random_id.bucket.hex}"
  storage_class                = each.value.storage_class != "" ? each.value.storage_class : var.storage_class
  versioning_enabled           = each.value.versioning_enabled != "" ? each.value.versioning_enabled : var.versioning_enabled
  lifecycle_policy             = each.value.lifecycle_rule
  internal_tenant_roles_admin  = each.value.internal_tenant_roles_admin
  internal_tenant_roles_viewer = each.value.internal_tenant_roles_viewer
  external_tenant_roles_admin  = each.value.external_tenant_roles_admin
  external_tenant_roles_viewer = each.value.external_tenant_roles_viewer
}
```

### terraform.tfvars.json

This is the `variables` file used to created the resources. This section describes how to declare the `buckets`.

- GCP project name where to create the buckets.

   ```json
   {
       "project": "tenant1",
   ```

- Bucket information in `gcs_buckets` variable.

  ```bash
  "gcs_buckets": {
          "eu": { # GCP region 
              "name": "natali-test", # name of the bucket
              "storage_class": "", # storage class set for an object affects the object's availability and pricing model.
              "versioning_enabled": true, # To support the retrieval of objects that are deleted or replaced
              "lifecycle_rule": { # To support common use cases like setting a Time to Live (TTL) for objects
                  "ttl": {
                      "condition_age": 1, # day(s)
                      "action_type": "Delete" 
                  }
              },
              "internal_tenant_roles_admin": { # service account that belongs to the project defined at the beginning and will have   objectAdmin permission
                  "objectAdmin": {
                      "service_accounts": ["platform-infra", "platform-ko"] # short-name of the service account
                  }
              },
              "internal_tenant_roles_viewer": { # service account that belongs to the project defined at the beginning and will have   objectViewer permission
                  "objectViewer": {
                      "service_accounts": ["viewer-infra", "viewer-ko"] # short-name of the service account
                  }
              },
              "external_tenant_roles_admin": { # service account that belongs to a different project and will have objectAdmin permission
                  "objectAdmin": [
                      {
                          "project": "tenant2", # name of the different project
                          "service_accounts": ["platform-infra", "platform-ko"] # short-name of the service account
                      }
                  ]
              },
              "external_tenant_roles_viewer": { # service account that belongs to a different project and will have objectViewer   permission
                  "objectViewer": [
                      {
                          "project": "tenant2", # name of the different project
                          "service_accounts": ["viewer-infra", "viewer-ko"] # short-name of the service account
                      }
                  ]
              }
          }
  ```
  
## Resources

| Name | Type |
|------|------|
| [google_storage_bucket.bucket](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket) | resource |
| [google_storage_bucket_iam_member.admin-member-bucket-external](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_member) | resource |
| [google_storage_bucket_iam_member.admin-member-bucket-internal](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_member) | resource |
| [google_storage_bucket_iam_member.viewer-member-bucket-external](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_member) | resource |
| [google_storage_bucket_iam_member.viewer-member-bucket-internal](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_member) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| external_tenant_roles_admin | updates the IAM policy to grant ObjectAdmin role to a list of members from a different project | `map(any)` | n/a | yes |
| external_tenant_roles_viewer | updates the IAM policy to grant ObjectViewer role to a list of members from a different project | `map(any)` | n/a | yes |
| internal_tenant_roles_admin | updates the IAM policy to grant ObjectAdmin role to a list of members | `map(any)` | n/a | yes |
| internal_tenant_roles_viewer | updates the IAM policy to grant ObjectViewer role to a list of members | `map(any)` | n/a | yes |
| lifecycle_policy | list of lifecycles rules to configure | `map(any)` | n/a | yes |
| location | GCP location for resources | `string` | n/a | yes |
| name | name of the bucket | `string` | n/a | yes |
| project | full name of the tenant project | `string` | n/a | yes |
| storage_class | target Storage Class of objecs affected by this Lifecycle Rule. Supported values include: STANDARD, MULTI_REGIONAL, REGIONAL, NEARLINE, COLDLINE, ARCHIVE | `string` | n/a | yes |
| versioning_enabled | While set to true, versioning is fully enabled for this bucket | `bool` | n/a | yes |

## References

- [Google Official Documentation for GCS](https://cloud.google.com/storage/docs/how-to) for more information.
- [Terraform GCS Bucket resource](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket)
- [Terraform IAM policy for Cloud Storage Bucket](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam) for more information on the resource usage and configuration.
