from airflow.macros import datetime
import os
from pathlib import Path
from airflow import DAG
from airflow.operators.python import PythonOperator

from delay.tasks.create_tables import init_db
from delay.tasks.outlier_detection import get_data_to_db
from delay.tasks.plot import plot_generator

# Env vars and definitions
db_data = {
    'user': os.getenv('DATABASE_USERNAME'),
    'passw': os.getenv('DATABASE_PASSWORD'),
    'db_url': os.getenv('DATABASE_URL'),
    'db_name': os.getenv('DATABASE_NAME'),
    }

RAW_DATA = os.getenv('DATA_LOCATION')
PLOT_DIR = os.getenv('PLOT_DIR')

ROOT_DIR = Path(__file__).parent.resolve()

# Dag definition
with DAG(
    "delay_dag",
    schedule_interval='0 6 3 1 *',
    start_date=datetime(2009, 1, 1),
    end_date=datetime(2010, 1, 1),
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
        }
    )
    plot_gen = PythonOperator(
        task_id=f'plot_gen',
        python_callable=plot_generator,
        op_kwargs= {
            **db_data,
            'location': PLOT_DIR,
            'year': '{{ macros.ds_format(ds , "%Y-%m-%d", "%Y")}}',
        }
    )
    # Dag workflow
    create_tables >> outlier_detection >> plot_gen