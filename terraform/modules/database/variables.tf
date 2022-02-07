variable "v_tags" {
  type = map(string)
  default = {}
}

variable "RDSpassword" {
    type = string
}

variable "db_schema_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "pri_subnet_ids" {
  type = list
}

variable "securitygroup_id" {
  type = string
}