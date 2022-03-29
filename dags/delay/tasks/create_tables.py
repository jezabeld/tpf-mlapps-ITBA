"""Script to create DB and tables."""
import argparse
from sqlalchemy import event, DDL
from utils.models import Base
from utils.db_connections import PostgresClient


def init_db(db_conn_id, db_name):
    """Program entrypoint."""
    # crea el schema de la base de datos si no existe antes de crear las tablas:
    stmt = f"CREATE SCHEMA IF NOT EXISTS {db_name}"
    event.listen(Base.metadata, 'before_create', DDL(stmt))
    #crea la connexion a la base
    pg_cli = PostgresClient(db_name, db_conn_id)
    # crea las tablas definidas para la Base
    Base.metadata.create_all(bind=pg_cli._get_engine())


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="DB connection")
    parser.add_argument("--db_conn_id", type=str, help="DB_CONN_ID")
    parser.add_argument("--db_name", type=str, help="DB_NAME")
    params = parser.parse_args()
    init_db(params.db_conn_id, params.db_name)