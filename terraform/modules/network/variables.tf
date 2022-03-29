variable "v_tags" {
  type = map(string)
  default = {}
}
variable "region" {
  type = string
}
variable "vpc_cidr" {
  type = string
}

variable "subnet_cidrs" {
  type = list(string)
}