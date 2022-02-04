
variable "RDSpassword" {
    type = string
}
variable "account_id" {
    type = string
}
variable "bucket_name" {
    type = string
}
variable "dag_s3_path" {
  description = "Relative path of the dags folder within the source bucket"
  type = string
  default = "dags"
}
variable "requirements_s3_path" {
  type = string
  description = "relative path of the requirements.txt (incl. filename) within the source bucket"
  default = null
}
variable "tags" {
  type = map(string)
  default = {}
}

variable "env_name" {
    type = string
}

variable "airflow_config" {
  type = map(string)
  default = {}
}

variable "conn_var" {
  type = string
}

variable "db_schema_name" {
  type = string
}