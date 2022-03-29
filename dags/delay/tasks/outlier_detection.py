"""Departure delay Outlier Detection and load to DB."""
import argparse
import pandas as pd
from sklearn.preprocessing import StandardScaler
import typing

from utils.models import DepDelay
from utils.db_connections import PostgresClient
from utils.functions import read_from_folder, read_from_s3

def process_data(df):
    grouped = df.groupby(['ORIGIN','FL_DATE']).agg({'OP_CARRIER_FL_NUM': 'count', 'DEP_DELAY': 'mean'})

    df_rescaled = (
        grouped.groupby("ORIGIN")
        .apply(SklearnWrapper(StandardScaler()))
        .rename(columns = {'DEP_DELAY': 'DEL_SCALED'})
        .drop(columns=['OP_CARRIER_FL_NUM'])
    )
    df_rescaled = (
        grouped.join(df_rescaled)
        .assign(OUTLIER=(abs(df_rescaled.DEL_SCALED)>=3).astype(int))
        .rename(columns= {'OP_CARRIER_FL_NUM': 'NUM_FLIGHTS'})
    )
    return df_rescaled

def keys_in_db(pg_cli, origin, date):
    query = f"""select count(*) from dep_delay
                where origin = '{origin}' and date = '{date}'"""
    r = pg_cli.execute(query).fetchone()
    rbool = (dict(r)['count'] == 1)
    return rbool

def drop_data_from_db(db_conn_id, db_name, year):
    pg_cli = PostgresClient(db_name, db_conn_id) 
    session = pg_cli.get_session()
    rows_deleted = session.query(DepDelay).filter(DepDelay.date.startswith(f'{year}')).delete(synchronize_session='fetch')
    session.commit()
    print(str(rows_deleted) + " rows were deleted")

def insert_to_db(data, db_conn_id, db_name):
    """Inserts data into db if not exists. """
    pg_cli = PostgresClient(db_name, db_conn_id) 
    session = pg_cli.get_session()
    existing = []
    if isinstance(data,DepDelay) :
        if not keys_in_db(pg_cli, **data.get_keys()):
            session.add(data)
        else:
            existing.append(data)
    elif isinstance(data,list):
        inserted = [session.add(item) if isinstance(item,DepDelay) and (not keys_in_db(pg_cli, **item.get_keys()) ) else existing.append(item) for item in data ]
        print(str(len(inserted)) + ' rows inserted')
    else:
        pass
    session.commit()

    if existing:
        print(str(len(existing)) + ' rows cannot be inserted')
        

# This wrapper will apply any sklearn transform to a group.
class SklearnWrapper:
    def __init__(self, transformation: typing.Callable):
        self.transformation = transformation

    def __call__(self, df):
        transformed = self.transformation.fit_transform(df.values)
        return pd.DataFrame(transformed, columns=df.columns, index=df.index)

def get_data_to_db(db_conn_id, db_name, location, year, bucket_name):
    """Program entrypoint."""
    year = int(year)

    data = pd.read_csv(read_from_s3(bucket_name, f'{location}/{year}.csv'), usecols=['ORIGIN','FL_DATE','OP_CARRIER_FL_NUM', 'DEP_DELAY'])

    processed_df = process_data(data)

    if not processed_df.empty:
        model_data = [DepDelay(origin=item['ORIGIN'], date=item['FL_DATE'], num_flights= item['NUM_FLIGHTS'], dep_delay= item['DEP_DELAY'], del_scaled= item['DEL_SCALED'], outlier= item['OUTLIER']) 
                            for item in processed_df.reset_index().to_dict('records')]
    else:
        print("No data found.")
        model_data = []

    # To emulate insert overwrite partition by year, first delete all previous info
    drop_data_from_db(db_conn_id, db_name, year)
    insert_to_db(model_data, db_conn_id, db_name)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="DB connection")
    parser.add_argument("--db_conn_id", type=str, help="DB_CONN_ID")
    parser.add_argument("--db_name", type=str, help="DB_NAME")
    parser.add_argument("--location", type=str, help="location")
    parser.add_argument("--year", type=str, help="year")
    parser.add_argument("--bucket_name", type=str, help="bucket_name")

    params = parser.parse_args()
    get_data_to_db(params.db_conn_id, params.db_name, 
        params.location, params.year, params.bucket_name)