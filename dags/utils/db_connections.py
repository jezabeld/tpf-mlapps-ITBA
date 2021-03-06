"""Database connection handling."""
from sqlalchemy import create_engine, MetaData
from sqlalchemy.orm import sessionmaker
from airflow.providers.postgres.hooks.postgres import PostgresHook
from sqlalchemy.engine import Engine
import pandas as pd

class AbstractDbClient:
    """Base class to implement DB Connection."""
    def __init__(self, db, user= None, passw= None, host=None, driver=None, port=None):
        self.db = db
        self._engine = None
        self._Session_Factory = None

    def _get_engine(self):
        """Abstract method to get engine according to dialects."""
        raise NotImplementedError("Please Implement this method")

    def get_session(self):
        if not self._Session_Factory:
            self._Session_Factory = sessionmaker(bind = self._get_engine())
        return self._Session_Factory()

    def _connect(self):
        return self._get_engine().connect()

    @staticmethod
    def _cursor_columns(cursor):
        if hasattr(cursor, 'keys'):
            return cursor.keys()
        else:
            return [c[0] for c in cursor.description]

    def execute(self, sql, connection=None):
        if connection is None:
            connection = self._connect()
        return connection.execute(sql)

    def insert_from_frame(self, df, table, if_exists='append', index=False, **kwargs):
        connection = self._connect()
        with connection:
            df.to_sql(table, connection, if_exists=if_exists, index=index, **kwargs)

    def to_frame(self, *args, **kwargs):
        cursor = self.execute(*args, **kwargs)
        if not cursor:
            return
        data = cursor.fetchall()
        if data:
            df = pd.DataFrame(data, columns=self._cursor_columns(cursor))
        else:
            df = pd.DataFrame()
        return df

class SqLiteClient(AbstractDbClient):
    def __init__(self, db):
        AbstractDbClient.__init__(self, db)

    def _get_engine(self):
        db_uri = f'sqlite:///{self.db}'
        if not self._engine:
            self._engine = create_engine(db_uri)
        return self._engine

class PostgresClient(AbstractDbClient):
    def __init__(self, db, postgres_conn):
        self.postgres_conn = postgres_conn
        AbstractDbClient.__init__(self, db)

    def _get_engine(self):
        pg_hook = PostgresHook(postgres_conn_id=self.postgres_conn)
        if not self._engine:
            self._engine: Engine = pg_hook.get_sqlalchemy_engine()
        return self._engine