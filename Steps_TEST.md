# Steps TEST

## 1) Set testing architecture.
Info about AWS MWAA: [Apache Airflow 2.0 on Amazon MWAA](https://www.youtube.com/watch?v=79IyGdIU7FA)
Tutorial with a local docker container: (https://docs.aws.amazon.com/mwaa/latest/userguide/tutorials-docker.html).

To start testing MWAA, copy the files from [aws-mwaa-local-runner](https://github.com/aws/aws-mwaa-local-runner) and build the image.
NOTE: Original repo rise an error when building image, to fix it is needed to change constraints.txt file in the line for Flask-OpenID and set version 1.3.0.

```bash
# build image
./mwaa-local-env build-image
# start image
./mwaa-local-env start
```

Login to Apache Airflow at http://localhost:8080/:

Username: admin
Password: test

To install libraries in this environment, copy them in ./dags/requirements.txt. This file emulates the requirements file in S3 bucket in the real environment.

## 2) Emulate final environment.

### Airflow Settings
In the prod env, is going to be needed to configure new DAGs to be created _not paused_ by setting `dags_are_paused_at_creation = False` in order to automatically start when env is created. How to configure this in MWAA: [configuring-env-variables](https://docs.aws.amazon.com/mwaa/latest/userguide/configuring-env-variables.html).

### S3 bucket
To emulate the final S3 bucket, I'm going to be using ./dags/data folder for now.
How to connect to S3: [example code](https://docs.aws.amazon.com/mwaa/latest/userguide/samples-dag-run-info-to-csv.html).
How to read and write from pandas to S3: [example code](https://towardsdatascience.com/reading-and-writing-files-from-to-amazon-s3-with-pandas-ccaf90bfe86c). How to write image to bucket: [example code](https://stackoverflow.com/questions/31485660/python-uploading-a-plot-from-memory-to-s3-using-matplotlib-and-boto).

Functions to read files and write images to bucket and folders created in ./dags/utils/functions.py

### RDS database
To emulate the prod-db, a container named RDSdatabase was added in in docker-compose-local.yml. To be able to store the credentials in a secret manager and use it, it was necessary to use the Airflow Connections. In the local env, the connections was created through de UI, but in the prod env this will be accomplished setiting up a Secret Manager Backend for Airflow: [Move your Apache Airflow connections and variables to AWS Secrets Manager](https://awscloudfeed.com/whats-new/open-source/move-your-apache-airflow-connections-and-variables-to-aws-secrets-manager).

### Environment variables from Secret Manager
In this testing env, I'll just add a .env file in docker-compose-local.yml.
How to set Fernet Key: [secure-connections](https://airflow.apache.org/docs/apache-airflow/1.10.12/howto/secure-connections.html).

How to connect MWAA to Secret Manager: [connections-secrets-manager](https://docs.aws.amazon.com/mwaa/latest/userguide/connections-secrets-manager.html).
How to use variables in Secret Manager: [Airflow connections](https://docs.aws.amazon.com/mwaa/latest/userguide/samples-secrets-manager.html).
```python
# Use this code snippet in your app.
# If you need more information about configurations or implementing the sample code, visit the AWS docs:   
# https://aws.amazon.com/developers/getting-started/python/

import boto3
import base64
from botocore.exceptions import ClientError

def get_secret():

    secret_name = "mwaa-environment/connections/RDSpostgres"
    region_name = "us-east-1"

    # Create a Secrets Manager client
    session = boto3.session.Session()
    client = session.client(
        service_name='secretsmanager',
        region_name=region_name
    )

    # In this sample we only handle the specific exceptions for the 'GetSecretValue' API.
    # See https://docs.aws.amazon.com/secretsmanager/latest/apireference/API_GetSecretValue.html
```

## 3) Architecture sketch.
First architecture diagram in [DrawIO](https://app.diagrams.net/?mode=github#Hjezabeld%2Ftpf-mlapps-ITBA%2Ftest%2FArchitecture.png).


Terraform template: [MWAA Environment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/mwaa_environment). Complete template: [terraform-aws-mwaa](https://github.com/idealo/terraform-aws-mwaa).