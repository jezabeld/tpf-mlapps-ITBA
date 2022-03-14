variable "v_tags" {
  type = map(string)
}
variable "profile" {
  type = string
}
variable "dag_s3_path" {
  description = "Relative path of the dags folder within the source bucket"
  type = string
  default = "dags"
}