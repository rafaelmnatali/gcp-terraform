resource "google_storage_bucket" "bucket" {
  name                        = var.name
  location                    = var.location
  force_destroy               = true
  uniform_bucket_level_access = true
  requester_pays              = false
  storage_class               = var.storage_class
  project                     = var.project

  versioning {
    enabled = var.versioning_enabled
  }

  dynamic "lifecycle_rule" {
    for_each = var.lifecycle_policy
    content {
      condition {
        age = lifecycle_rule.value.condition_age
      }
      action {
        type = lifecycle_rule.value.action_type
      }
    }
  }

}

locals {
  internal_roles_fully_qualified_admin = {
    for tenant_role, entities in var.internal_tenant_roles_admin :
    tenant_role => {
      service_accounts : [for k, v in coalesce(entities["service_accounts"], []) : "serviceAccount:${v}@${var.project}.iam.gserviceaccount.com"]
    }
  }

  internal_roles_fully_qualified_viewer = {
    for tenant_role, entities in var.internal_tenant_roles_viewer :
    tenant_role => {
      service_accounts : [for k, v in coalesce(entities["service_accounts"], []) : "serviceAccount:${v}@${var.project}.iam.gserviceaccount.com"]
    }
  }

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

  external_roles_fully_qualified_viewer = {
    for tenant_role, entries in var.external_tenant_roles_viewer :
    tenant_role => {
      service_accounts = flatten([
        for entry in entries : [
          for k, v in coalesce(entry["service_accounts"], []) :
          "serviceAccount:${v}@${entry["project"]}.iam.gserviceaccount.com"
        ]
      ])
    }
  }

}

resource "google_storage_bucket_iam_member" "admin-member-bucket-internal" {
  for_each = toset(local.internal_roles_fully_qualified_admin.objectAdmin.service_accounts)
  bucket   = var.name
  role     = "roles/storage.objectAdmin"
  member   = each.value
  depends_on = [
    google_storage_bucket.bucket
  ]
}

resource "google_storage_bucket_iam_member" "viewer-member-bucket-internal" {
  for_each = toset(local.internal_roles_fully_qualified_viewer.objectViewer.service_accounts)
  bucket   = var.name
  role     = "roles/storage.objectViewer"
  member   = each.value
  depends_on = [
    google_storage_bucket.bucket
  ]
}

resource "google_storage_bucket_iam_member" "admin-member-bucket-external" {
  for_each = toset(local.external_roles_fully_qualified_admin.objectAdmin.service_accounts)
  bucket   = var.name
  role     = "roles/storage.objectAdmin"
  member   = each.value
  depends_on = [
    google_storage_bucket.bucket
  ]
}

resource "google_storage_bucket_iam_member" "viewer-member-bucket-external" {
  for_each = toset(local.external_roles_fully_qualified_viewer.objectViewer.service_accounts)
  bucket   = var.name
  role     = "roles/storage.objectViewer"
  member   = each.value
  depends_on = [
    google_storage_bucket.bucket
  ]
}