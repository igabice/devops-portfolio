# modules/s3/variables.tf

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "bucket_name" {
  description = "Name of the S3 bucket (will be prefixed with environment)"
  type        = string
}

variable "enable_versioning" {
  description = "Enable bucket versioning"
  type        = bool
  default     = true
}

variable "enable_encryption" {
  description = "Enable server-side encryption"
  type        = bool
  default     = true
}

variable "encryption_algorithm" {
  description = "Encryption algorithm (AES256 or aws:kms)"
  type        = string
  default     = "AES256"
}

variable "kms_key_id" {
  description = "KMS key ID for encryption (if using aws:kms)"
  type        = string
  default     = null
}

variable "block_public_access" {
  description = "Block all public access to bucket"
  type        = bool
  default     = true
}

variable "lifecycle_rules" {
  description = "Lifecycle rules for the bucket"
  type = list(object({
    id                                 = string
    enabled                            = bool
    prefix                             = string
    expiration_days                    = number
    transition_to_standard_ia_days     = number
    transition_to_glacier_days         = number
    noncurrent_version_expiration_days = number
    noncurrent_version_transition_days = number
  }))
  default = []
}

variable "allowed_origins" {
  description = "Allowed origins for CORS (if hosting static website)"
  type        = list(string)
  default     = []
}

variable "attach_bucket_policy" {
  description = "Whether to attach a bucket policy"
  type        = bool
  default     = false
}

variable "bucket_policy" {
  description = "Bucket policy JSON (if attach_bucket_policy is true)"
  type        = string
  default     = null
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}