variable "project" {
  type        = string
  description = "full name of the tenant project"
}

variable "name" {
  type        = string
  description = "name of the bucket"
}

variable "lifecycle_policy" {
  type        = map(any)
  description = "list of lifecycles rules to configure"
}

variable "location" {
  type        = string
  description = "GCP location for resources"
}

variable "storage_class" {
  type        = string
  description = "target Storage Class of objecs affected by this Lifecycle Rule. Supported values include: STANDARD, MULTI_REGIONAL, REGIONAL, NEARLINE, COLDLINE, ARCHIVE"
}
variable "versioning_enabled" {
  type        = bool
  description = "While set to true, versioning is fully enabled for this bucket"
}

variable "internal_tenant_roles_admin" {
  type        = map(any)
  description = "updates the IAM policy to grant ObjectAdmin role to a list of members"
}

variable "internal_tenant_roles_viewer" {
  type        = map(any)
  description = "updates the IAM policy to grant ObjectViewer role to a list of members"
}

variable "external_tenant_roles_admin" {
  type        = map(any)
  description = "updates the IAM policy to grant ObjectAdmin role to a list of members from a different project"
}

variable "external_tenant_roles_viewer" {
  type        = map(any)
  description = "updates the IAM policy to grant ObjectViewer role to a list of members from a different project"
}
