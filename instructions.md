
2. Instalar el cliente de aws siguiendo [estas instrucciones](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) acorde a su sistema
operativo.

Crear el bucket por consola
aws s3api create-bucket --bucket mwaa-itba-bucket --no-object-lock-enabled-for-bucket --region us-east-1 
aws s3api put-bucket-versioning --bucket mwaa-itba-bucket --versioning-configuration Status=Enabled
aws s3api put-public-access-block --bucket mwaa-itba-bucket --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"



obtener los datos siguiendo estos pasos:
1. Instalar el cliente de Kaggle: `pip install kaggle`
3. Configurar las credenciales siguiendo [estas instrucciones](https://github.com/Kaggle/kaggle-api#api-credentials).
4. Bajar datos de Kaggle:

```bash
# cd to your local directory
cd ./dags
mkdir data && cd data
# Download zipped dataset from kaggle
kaggle datasets download -d yuanyuwendymu/airline-delay-and-cancellation-data-2009-2018
# Unzip files
unzip airline-delay-and-cancellation-data-2009-2018.zip -d raw/
# Upload files to bucket
aws s3 sync raw/ s3://mwaa-bucket-itba/data/
# Remove zipped data to save space [optional]
rm airline-delay-and-cancellation-data-2009-2018.zip
```

Upload config files to bucket:
```bash
cd ./dags
aws s3 sync config/ s3://mwaa-bucket-itba/config/ --profile itba
```

Instalar terraform



Configuration option
Custom value
core.dags_are_paused_at_creation	False
secrets.backend	airflow.contrib.secrets.aws_secrets_manager.SecretsManagerBackend
secrets.backend_kwargs	'{"connections_prefix" : "mwaa/connections", "variables_prefix" : "mwaa/variables"}'



# Connection in Secret manager
mwaa/connections/RDSpostgres


# Variables en secret manager
mwaa/variables/conn_id
mwaa/variables/db_name