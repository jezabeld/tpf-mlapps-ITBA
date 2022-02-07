variable "create_bucket" {
  description = "true if bucket should be created."
  type = bool
  default = true
}

variable "bucket_name" {
    type = string
}

variable "v_tags" {
  type = map(string)
}