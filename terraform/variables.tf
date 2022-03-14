
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
  default = "RDSpostgres"
}

variable "db_schema_name" {
  type = string
}

variable "region" {
  type = string
  default = "us-east-1"
}
variable "vpc_cidr" {
  type = string
  default = "10.192.0.0/16"
}

variable "subnet_cidrs" {
  type = list(string)
  default = ["10.192.10.0/24", "10.192.11.0/24", "10.192.20.0/24", "10.192.21.0/24" ]
}

variable "data_dir" {
  type = string
  default = "data"
}

variable "plot_dir" {
  type = string
  default = "plot"
}

variable "profile" {
  type = string
  default = "default"
}