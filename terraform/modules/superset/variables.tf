variable "v_tags" {
  type = map(string)
}

variable "subnet_ids" {
  type = list
}
variable "pub_subnet_ids" {
  type = list
}
variable "security_groups" {
  type = list
}

variable "region" {
  type = string
}

variable "securitygroup_id" {
  type = string
}

variable "vpc_id" {
  type = string
}