terraform {
	required_providers {
		aws = {
			source  = "hashicorp/aws"
			version = "3.74"
		}
	}
}

provider "aws" {
	profile = "default"
	region  = var.region
}

module "network" {
  source        = "./modules/network"
  v_tags        = var.tags
  region        = var.region
  vpc_cidr      = var.vpc_cidr
  subnet_cidrs  = var.subnet_cidrs
}

module "database" {
  source            = "./modules/database"

  v_tags            = var.tags
  RDSpassword       = var.RDSpassword
  db_schema_name    = var.db_schema_name

  vpc_id            = module.network.vpc_id
  pri_subnet_ids    = module.network.pri_subnet_ids
  securitygroup_id  = module.network.securitygroup_id
}

module "iam" {
  source      = "./modules/iam"

  v_tags      = var.tags
  env_name    = var.env_name
  bucket_name = var.bucket_name
  account_id  = var.account_id
}

module "airflow" {
  source                = "./modules/airflow"

  v_tags                = var.tags
  env_name              = var.env_name
  bucket_name           = var.bucket_name
  requirements_s3_path  = var.requirements_s3_path
  conn_var              = var.conn_var
  db_schema_name        = var.db_schema_name
  airflow_config        = var.airflow_config
  dag_s3_path           = var.dag_s3_path
  data_dir              = var.data_dir
  plot_dir              = var.plot_dir
  
  role_arn              = module.iam.role_arn
  securitygroup_id      = module.network.securitygroup_id
  pri_subnet_ids        = module.network.pri_subnet_ids
}
