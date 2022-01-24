"""Useful functions."""
from airflow.models import Variable
from airflow.providers.amazon.aws.hooks.base_aws import AwsBaseHook
from airflow.providers.amazon.aws.hooks.s3 import S3Hook
from matplotlib.backends.backend_agg import FigureCanvas
import os
import io

### Gets the secret myconn from Secrets Manager
def read_dbconn_from_var(**kwargs):
    # ### set up Secrets Manager
    # hook = AwsBaseHook(client_type='secretsmanager')
    # client = hook.get_client_type('secretsmanager')
    # response = client.get_secret_value(SecretId=sm_secretId_name) #reeplace with real secret
    db_data = {
        'db_conn_id': Variable.get('DB_CONN_ID'), 
        'db_name': Variable.get('DATABASE_NAME'),
    }

    return db_data

def read_dbconn_from_env(**kwargs):
    db_data = {
        'db_conn_id': os.getenv('DB_CONN_ID'),
        'db_name': os.getenv('DATABASE_NAME'),
    }

    return db_data

def read_from_s3(S3_BUCKET = 'my-export-bucket', S3_KEY = 'folder/file.ext' ):
    s3_hook = S3Hook()
    s3_client = s3_hook.get_conn()
    myfile = s3_client.get_object(Bucket=S3_BUCKET, Key=S3_KEY)
    status = response.get("ResponseMetadata", {}).get("HTTPStatusCode")
    if status == 200:
        print(f"Successful S3 get_object response. Status {status}")
        return myfile.get("Body")
    else:
        print(f"Unsuccessful S3 get_object response. Status {status}")
        return None

def read_from_folder(FOLDER, FILEN ):

    return f'{FOLDER}{FILEN}'

def save_img_to_folder(img, location, name):
    img.savefig(f'{location}{name}', transparent=False, dpi=80, bbox_inches="tight")

    return True

def save_img_to_bucket(img, S3_BUCKET, S3_KEY):
    canvas = FigureCanvas(img) # renders figure onto canvas
    imdata = io.BytesIO() # prepares in-memory binary stream buffer (think of this as a txt file but purely in memory)
    canvas.print_png(imdata) # writes canvas object as a png file to the buffer. You can also use print_jpg, alternatively
    s3_hook = S3Hook()
    s3_client = s3_hook.get_conn()
    response = s3_client.put_object(Bucket=S3_BUCKET, Key=S3_KEY, Body=imdata.getvalue(), ContentType='image/png')
    status = response.get("ResponseMetadata", {}).get("HTTPStatusCode")

    if status == 200:
        print(f"Successful S3 put_object {S3_KEY}. Status {status}")
        return True
    else:
        print(f"Unsuccessful S3 put_object {S3_KEY}. Status {status}")
        return False

