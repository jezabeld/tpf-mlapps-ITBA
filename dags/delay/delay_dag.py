from airflow.macros import datetime
import os
from pathlib import Path
from airflow import DAG
from airflow.models import Connection, Variable
from airflow.operators.python import PythonOperator

from delay.tasks.create_tables import init_db
from delay.tasks.outlier_detection import get_data_to_db
from delay.tasks.plot import plot_generator

from utils.functions import read_dbconn_from_env, read_dbconn_from_var

# Env vars and definitions
db_data = read_dbconn_from_var()

BUCKET = Variable.get('bucket_name')
RAW_DATA = Variable.get('raw_data_dir') 
PLOT_DIR = Variable.get('plot_dir') 


# Dag definition
with DAG(
    "delay_dag",
    schedule_interval='0 6 3 1 *',
    start_date=datetime(2009, 1, 1),
    end_date=datetime(2019, 1, 1),
    max_active_runs=1,
    catchup=True,
) as dag:
    create_tables = PythonOperator(
        task_id="create_tables",
        python_callable=init_db,
        op_kwargs= db_data,
    )
    outlier_detection = PythonOperator(
        task_id=f'outlier_detection',
        python_callable=get_data_to_db,
        op_kwargs= {
            **db_data,
            'location': RAW_DATA,
            'year': '{{ macros.ds_format(ds , "%Y-%m-%d", "%Y")}}',
            'bucket_name': BUCKET,
        }
    )
    plot_gen = PythonOperator(
        task_id=f'plot_gen',
        python_callable=plot_generator,
        op_kwargs= {
            **db_data,
            'location': PLOT_DIR,
            'year': '{{ macros.ds_format(ds , "%Y-%m-%d", "%Y")}}',
            'bucket_name': BUCKET,
        }
    )
    # Dag workflow
    create_tables >> outlier_detection >> plot_gen