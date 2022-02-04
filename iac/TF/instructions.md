
2. Instalar el cliente de aws siguiendo [estas instrucciones](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) acorde a su sistema
operativo.
Crear el bucket por consola?
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

# ROlName:

AmazonMWAA-MyAirflowEnvironment-nS4BcX

# Connection in Secret manager
mwaa/connections/RDSpostgres


```python3
# Use this code snippet in your app.
# If you need more information about configurations or implementing the sample code, visit the AWS docs:   
# https://aws.amazon.com/developers/getting-started/python/

import boto3
import base64
from botocore.exceptions import ClientError


def get_secret():

    secret_name = "mwaa/connections/RDSpostgres"
    region_name = "us-east-1"

    # Create a Secrets Manager client
    session = boto3.session.Session()
    client = session.client(
        service_name='secretsmanager',
        region_name=region_name
    )

    # In this sample we only handle the specific exceptions for the 'GetSecretValue' API.
    # See https://docs.aws.amazon.com/secretsmanager/latest/apireference/API_GetSecretValue.html
    # We rethrow the exception by default.

    try:
        get_secret_value_response = client.get_secret_value(
            SecretId=secret_name
        )
    except ClientError as e:
        if e.response['Error']['Code'] == 'DecryptionFailureException':
            # Secrets Manager can't decrypt the protected secret text using the provided KMS key.
            # Deal with the exception here, and/or rethrow at your discretion.
            raise e
        elif e.response['Error']['Code'] == 'InternalServiceErrorException':
            # An error occurred on the server side.
            # Deal with the exception here, and/or rethrow at your discretion.
            raise e
        elif e.response['Error']['Code'] == 'InvalidParameterException':
            # You provided an invalid value for a parameter.
            # Deal with the exception here, and/or rethrow at your discretion.
            raise e
        elif e.response['Error']['Code'] == 'InvalidRequestException':
            # You provided a parameter value that is not valid for the current state of the resource.
            # Deal with the exception here, and/or rethrow at your discretion.
            raise e
        elif e.response['Error']['Code'] == 'ResourceNotFoundException':
            # We can't find the resource that you asked for.
            # Deal with the exception here, and/or rethrow at your discretion.
            raise e
    else:
        # Decrypts secret using the associated KMS key.
        # Depending on whether the secret is a string or binary, one of these fields will be populated.
        if 'SecretString' in get_secret_value_response:
            secret = get_secret_value_response['SecretString']
        else:
            decoded_binary_secret = base64.b64decode(get_secret_value_response['SecretBinary'])
            
    # Your code goes here. 
```

# Variables en secret manager
mwaa/variables/conn_id
mwaa/variables/db_name