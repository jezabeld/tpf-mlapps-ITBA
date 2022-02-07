# aws_db_subnet_group.dbsubnetgroup:
resource "aws_db_subnet_group" "dbsubnetgroup" {
  description = "Subnet group for RDS instance"
  name        = "dbsubnetgroup"
  subnet_ids  = var.pri_subnet_ids
  tags        = var.v_tags
}

# aws_db_instance.rdspostgres:
resource "aws_db_instance" "rdspostgres" {
  allocated_storage                     = 20
  auto_minor_version_upgrade            = false
  backup_retention_period               = 0
  copy_tags_to_snapshot                 = true
  db_subnet_group_name                  = aws_db_subnet_group.dbsubnetgroup.name
  delete_automated_backups              = true
  deletion_protection                   = false
  enabled_cloudwatch_logs_exports       = []
  engine                                = "postgres"
  engine_version                        = "11.1"
  iam_database_authentication_enabled   = false
  identifier                            = "mwaa-postgres"
  instance_class                        = "db.t3.micro"
  iops                                  = 0
  license_model                         = "postgresql-license"
  maintenance_window                    = "tue:10:08-tue:10:38"
  max_allocated_storage                 = 0
  monitoring_interval                   = 0
  multi_az                              = false
  name                                  = "postgres"
  option_group_name                     = "default:postgres-11"
  parameter_group_name                  = "default.postgres11"
  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  port                                  = 5432
  publicly_accessible                   = false
  skip_final_snapshot                   = true
  storage_encrypted                     = false
  storage_type                          = "gp2"
  username                              = "postgres"
  password                    				  = var.RDSpassword
  tags                                  = var.v_tags

  vpc_security_group_ids                = [
      var.securitygroup_id
  ]
}

# aws_secretsmanager_secret.conn_db:
resource "aws_secretsmanager_secret" "conn_db" {
    description             = "Acces to my RDS Postgres database."
    name                    = "mwaa/connections/RDSpostgres"
    recovery_window_in_days = 0
    tags                    = var.v_tags
}

resource "aws_secretsmanager_secret_version" "conn_db_val" {
  secret_id     = aws_secretsmanager_secret.conn_db.id
  secret_string = "postgres://${aws_db_instance.rdspostgres.username}:${var.RDSpassword}@${aws_db_instance.rdspostgres.endpoint}/${var.db_schema_name}"
}
