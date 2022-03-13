variable "gcs_buckets" {
  type        = map(any)
  description = "GCS bucket list config"
}

variable "project" {
  type        = string
  default     = ""
  description = "Full name of the tenant project"
}

variable "storage_class" {
  type        = string
  default     = "STANDARD"
  description = "The target Storage Class of objecs affected by this Lifecycle Rule. Supported values include: STANDARD, MULTO_REGIONAL, REGIONAL, NEARLINE, COLDLINE, ARCHIVE"
}

variable "versioning_enabled" {
  type        = bool
  default     = true
  description = "While set to true, versioning is fully enabled for this bucket"
}
