variable "bucket" {
  type = string
  description = "Name of the S3 bucket to hold backups"
}

variable "tags" {
  type = map(string)
  description = "Environment-specific (billing) tags to be applied to resources that accept tags"
  default = {}
}

variable "retention_period" {
  type = number
  description = "Number of days till the backups should be retained"
}
