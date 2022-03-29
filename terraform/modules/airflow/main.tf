# aws_cloudwatch_log_group.scheduler_loggroup
resource "aws_cloudwatch_log_group" "scheduler_loggroup" {
  count             = 5
  name              = "airflow-${var.env_name}-${var.log_group_names[count.index]}"
  retention_in_days = 7
  tags              = var.v_tags
}

# aws_mwaa_environment.mwaaEnv:
resource "aws_mwaa_environment" "mwaaEnv" {
    airflow_configuration_options   = var.airflow_config
    airflow_version                 = "2.2.2"
    dag_s3_path                     = var.dag_s3_path
    environment_class               = "mw1.medium"
    execution_role_arn              = var.role_arn
    max_workers                     = 2
    min_workers                     = 1
    name                            = var.env_name
    requirements_s3_object_version  = ""
    requirements_s3_path            = var.requirements_s3_path
    source_bucket_arn               = "arn:aws:s3:::${var.bucket_name}"
    tags                            = var.v_tags
    tags_all                        = var.v_tags
    webserver_access_mode           = "PUBLIC_ONLY"
    weekly_maintenance_window_start = "THU:16:00"

    logging_configuration {
        dag_processing_logs {
            enabled   = true
            log_level = "WARNING"
        }

        scheduler_logs {
            enabled   = true
            log_level = "WARNING"
        }

        task_logs {
            enabled    = true
            log_level  = "INFO"
        }

        webserver_logs {
            enabled   = true
            log_level = "WARNING"
        }

        worker_logs {
            enabled   = true
            log_level = "WARNING"
        }
    }

    network_configuration {
        security_group_ids = [
            var.securitygroup_id
        ]
        subnet_ids         = var.pri_subnet_ids
    }

    depends_on = [var.db_depends_on, aws_cloudwatch_log_group.scheduler_loggroup]
}

# aws_secretsmanager_secret.var_conn_id:
resource "aws_secretsmanager_secret" "var_conn_id" {
    description      = "Connection ID for DB."
    name             = "mwaa/variables/conn_id"
    recovery_window_in_days = 0
    tags             = var.v_tags
}
resource "aws_secretsmanager_secret_version" "var_conn_id_val" {
  secret_id     = aws_secretsmanager_secret.var_conn_id.id
  secret_string = var.conn_var
}

# aws_secretsmanager_secret.var_db_name:
resource "aws_secretsmanager_secret" "var_db_name" {
    description      = "Database Name/Schema."
    name             = "mwaa/variables/db_name"
    recovery_window_in_days = 0
    tags             = var.v_tags
}
resource "aws_secretsmanager_secret_version" "var_db_name_val" {
  secret_id     = aws_secretsmanager_secret.var_db_name.id
  secret_string = var.db_schema_name
}

# 
resource "aws_secretsmanager_secret" "var_raw_data_dir" {
    description      = "Raw data dir."
    name             = "mwaa/variables/raw_data_dir"
    recovery_window_in_days = 0
    tags             = var.v_tags
}
resource "aws_secretsmanager_secret_version" "var_raw_data_dir_val" {
  secret_id     = aws_secretsmanager_secret.var_raw_data_dir.id
  secret_string = var.data_dir
}

resource "aws_secretsmanager_secret" "var_plot_dir" {
    description      = "Plot dir."
    name             = "mwaa/variables/plot_dir"
    recovery_window_in_days = 0
    tags             = var.v_tags
}
resource "aws_secretsmanager_secret_version" "var_plot_dir_val" {
  secret_id     = aws_secretsmanager_secret.var_plot_dir.id
  secret_string = var.plot_dir
}

resource "aws_secretsmanager_secret" "var_bucket" {
    description      = "Bucket name."
    name             = "mwaa/variables/bucket_name"
    recovery_window_in_days = 0
    tags             = var.v_tags
}
resource "aws_secretsmanager_secret_version" "var_bucket_val" {
  secret_id     = aws_secretsmanager_secret.var_bucket.id
  secret_string = var.bucket_name
}