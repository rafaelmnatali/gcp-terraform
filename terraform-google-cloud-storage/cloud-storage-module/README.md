# Terraform Google Cloud Storage Module

## Explaining the gcs_bucket module

This section describes line-by-line how the [gcs_bucket](../main.tf) module works.

The label immediately after the module keyword is a local name. The `source` argument is mandatory for all modules. Meaning we are using the `terraform` code present in the `cloud-storage-module` folder. The `for_each` meta-argument accepts a [map](https://www.terraform.io/language/expressions/types#map) and creates an instance for each item in the map. Each instance has a distinct infrastructure object associated with it, and each is separately created, updated, or destroyed when the configuration is applied. In practice, the `for_each` allow us to create `1 to N` buckets.

```hcl
module "gcs_bucket" {
  for_each                     = var.gcs_buckets
  source                       = "./cloud-storage-module"
```

`location` is the `key` of the `gcs_buckets` variable in the [terraform.tfvars.json](../terraform.tfvars.json).

```hcl
  location                     = each.key
```

`project` is the equivalent entry in the [terraform.tfvars.json](../terraform.tfvars.json).

```hcl
  project                      = var.project
```

`name` is the combination of the `name` entry of the `gcs_buckets` variable in the [terraform.tfvars.json](../terraform.tfvars.json) with the `location` and a [random id](https://registry.terraform.io/providers/hashicorp/random/latest/docs) to make the bucket name unique.

```hcl
  name                         = "${each.value.name}-${each.key}-${random_id.bucket.hex}"
```

Both `storage_class` and `versioning_enabled` use the [simple conditional structure](https://www.terraform.io/language/expressions/conditionals). `If` a value is specified in the [terraform.tfvars.json](../terraform.tfvars.json) use it, otherwise use the default value defined in the [variables.tf](../variables.tf) file.

```hcl
  storage_class                = each.value.storage_class != "" ? each.value.storage_class : var.storage_class
  versioning_enabled           = each.value.versioning_enabled != "" ? each.value.versioning_enabled : var.versioning_enabled
```

When properly defined in the `terraform.tfvars.json` a lifecycle management configuration is added to the bucket.

```hcl
    lifecycle_policy        = each.value.lifecycle_rule
```

The variables `internal_tenant_roles` and `external_tenant_roles` refer to IAM policy for Cloud Storage Bucket within and outside the tenant's project respectively.

```hcl
  internal_tenant_roles_admin  = each.value.internal_tenant_roles_admin
  internal_tenant_roles_viewer = each.value.internal_tenant_roles_viewer
  external_tenant_roles_admin  = each.value.external_tenant_roles_admin
  external_tenant_roles_viewer = each.value.external_tenant_roles_viewer
}
```

### Explaining the management of IAM policies

The management of IAM policies deserves a separate topic because it's not straight-forward terraform configuration. An important requirement for the automation is to keep it as simple as possible for the tenants and to be re-usable in different environments. Therefore, from the tenant point-of-view all configuration necessary is:

- Internal roles:

```json
"internal_tenant_roles_admin": {
    "objectAdmin": {
        "service_accounts": ["platform-infra", "platform-ko"]
    }
},
"internal_tenant_roles_viewer": {
    "objectViewer": {
        "service_accounts": ["viewer-infra", "viewer-ko"]
    }
}
```

- External roles:

```json
"external_tenant_roles_admin": {
    "objectAdmin": [
        {
            "project": "tenant2",
            "service_accounts": ["platform-infra", "platform-ko"]
        }
    ]
},
"external_tenant_roles_viewer": {
    "objectViewer": [
        {
            "project": "tenant2",
            "service_accounts": ["viewer-infra", "viewer-ko"]
        }
    ]
}
```

The tenant only provide the role and a short name for the service account. However, the automation needs to complete the names with the `GCP` fully qualified name, like:

```txt
serviceAccount:platform-infra@tenant1-dev.iam.gserviceaccount.com
```

This transformation is done locally in the [main.tf](./main.tf) file in the `locals` block. The logic is similar for both `internal` and `external` resources.

A new object `<internal/external>_roles_fully_qualified_<admin/viewer>` is created as the result of a `for` in the respective variable. Inside the `for` it does another `for` for each `service_accounts` entry. The [coalesce](https://ww.terraform.io/language/functions/coalesce) function is used to return all non-empty values in the respective entry. For each valid entry it replaces it with the correct `project` and the value (`v`) is inputed by the tenant.

```hcl
internal_roles_fully_qualified_admin = {
  for tenant_role, entities in var.internal_tenant_roles_admin :
  tenant_role => {
    service_accounts : [for k, v in coalesce(entities["service_accounts"], []) : "serviceAccount:${v}@${var.project}.iamgserviceaccount.com"]
  }
}
```

Particularly for the `external` roles the [flatten](https://www.terraform.io/language/functions/flatten) is used to integrate the `projects` entry.

```hcl
external_roles_fully_qualified_admin = {
  for tenant_role, entries in var.external_tenant_roles_admin :
  tenant_role => {
    service_accounts = flatten([
      for entry in entries : [
        for k, v in coalesce(entry["service_accounts"], []) :
        "serviceAccount:${v}@${entry["project"]}.iam.gserviceaccount.com"
      ]
    ])
  }
}
```
