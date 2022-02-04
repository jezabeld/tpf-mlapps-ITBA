RDSpassword = "postgres"
bucket_name = "mwaa-itba-bucket"
account_id = "101748113520"
conn_var = "RDSpostgres"
db_schema_name = "postgres"

tags = {
        "Project" = "ITBA"
    }
env_name = "mwaaITBAenv"

airflow_config = {"core.dags_are_paused_at_creation" = "False",
                    "secrets.backend" = "airflow.providers.amazon.aws.secrets.secrets_manager.SecretsManagerBackend",#"airflow.contrib.secrets.aws_secrets_manager.SecretsManagerBackend",
                    "secrets.backend_kwargs" = 	"{\"connections_prefix\" : \"mwaa/connections/\", \"variables_prefix\" : \"mwaa/variables/\"}"
}
requirements_s3_path = "config/requirements.txt"
