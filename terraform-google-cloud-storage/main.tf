terraform {
  required_version = "~> 1.1.7"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.13.0"
    }
  }
}

# https://registry.terraform.io/providers/hashicorp/random/latest/docs
resource "random_id" "bucket" {
  keepers = {
    # Generate a new id to uniquely identify the bucket
    bucket_id = "${var.project}"
  }

  byte_length = 8
}

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
