output "bucket_name" {
    value = module.bucket.bucket_name
}

output "webserver" {
  value = module.airflow.webserver
}

output "db_uri" {
  value = module.database.db_uri
}

output "superset_dns" {
  value = module.superset.superset_dns
}