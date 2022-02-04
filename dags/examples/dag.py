from datetime import datetime
from airflow import DAG
from airflow.operators.dummy_operator import DummyOperator
from airflow.operators.python_operator import PythonOperator
from airflow.models import Variable
from airflow.providers.postgres.hooks.postgres import PostgresHook
from sqlalchemy.engine import Engine
from sqlalchemy import Column, Integer, String, Float
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from sqlalchemy import event, DDL

Base = declarative_base()

class PostgresClient:
    def __init__(self, db, postgres_conn):
        self.postgres_conn = postgres_conn
        self._engine = None
        self._Session_Factory = None

    def _get_engine(self):
        pg_hook = PostgresHook(postgres_conn_id=self.postgres_conn)
        if not self._engine:
            self._engine: Engine = pg_hook.get_sqlalchemy_engine()
        return self._engine

    def get_session(self):
        if not self._Session_Factory:
            self._Session_Factory = sessionmaker(bind = self._get_engine())
        return self._Session_Factory()

    def _connect(self):
        return self._get_engine().connect()

class DepDelay(Base):
    """Departure delay data model."""

    __tablename__ = "dep_delay" #nombre de la tabla en la db 
    origin = Column(String, primary_key=True)
    date = Column(String, primary_key=True) 
    num_flights = Column(Integer)
    dep_delay= Column(Float)
    del_scaled = Column(Float)
    outlier = Column(Integer)

    def __init__(self, origin, date, num_flights, dep_delay, del_scaled, outlier):
        self.origin = origin
        self.date = date
        self.num_flights = num_flights
        self.dep_delay = dep_delay
        self.del_scaled = del_scaled
        self.outlier = outlier

    def __repr__(self):
        return f"<DepDelay(origin='{self.origin}', date='{self.date}', ...)>"

    def __str__(self):
        return f"{self.origin} {self.date}: ${self.num_flights}"

    def get_keys(self):
        return {'origin': self.origin, 'date': self.date}


def print_hello():
    return f"Hello world from first Airflow DAG! Conn_is : {Variable.get('conn_id')}"

def init_db():
    db_conn_id = Variable.get('conn_id') 
    db_name = Variable.get('db_name')
    """Program entrypoint."""
    # crea el schema de la base de datos si no existe antes de crear las tablas:
    stmt = f"CREATE SCHEMA IF NOT EXISTS {db_name}"
    event.listen(Base.metadata, 'before_create', DDL(stmt))
    #crea la connexion a la base
    pg_cli = PostgresClient(db_name, db_conn_id)
    # crea las tablas definidas para la Base
    Base.metadata.create_all(bind=pg_cli._get_engine())


dag = DAG('hello_world', description='Hello World DAG',
          schedule_interval='0 12 * * *',
          start_date=datetime(2017, 3, 20), catchup=False)

hello_operator = PythonOperator(task_id='hello_task', python_callable=print_hello, dag=dag)
create_db_op = PythonOperator(task_id='create_db_task', python_callable=init_db, dag=dag)
hello_operator >> create_db_op