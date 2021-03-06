output "db_uri" {
  value = "postgres://${aws_db_instance.rdspostgres.username}:${var.RDSpassword}@${aws_db_instance.rdspostgres.endpoint}/${var.db_schema_name}"
}

output "database" {
  value = {}
  depends_on = [aws_db_instance.rdspostgres]
}