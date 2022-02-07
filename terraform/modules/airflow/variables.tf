variable "v_tags" {
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

variable "bucket_name" {
    type = string
}
variable "dag_s3_path" {
  description = "Relative path of the dags folder within the source bucket"
  type = string
}
variable "requirements_s3_path" {
  type = string
  description = "relative path of the requirements.txt (incl. filename) within the source bucket"
}

variable "role_arn" {
  type = string
}

variable "securitygroup_id" {
  type = string
}

variable "pri_subnet_ids" {
  type = list
}

variable "data_dir" {
  type = string
}

variable "plot_dir" {
  type = string
}