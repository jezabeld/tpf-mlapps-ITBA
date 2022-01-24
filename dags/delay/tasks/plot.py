"""Script to plot delay data."""
import argparse
from utils.models import DepDelay
from utils.db_connections import PostgresClient
from utils.functions import save_img_to_bucket, save_img_to_folder

import matplotlib.pyplot as plt
from matplotlib.lines import Line2D
import matplotlib.dates as mdates

def get_data_from_db(db_name, db_conn_id, year, origin=None):
    pg_cli = PostgresClient(db_name, db_conn_id)
    if origin:
        query = f"""SELECT * 
                    FROM dep_delay 
                    WHERE origin = '{origin}'
                        AND SUBSTRING(date, 1, 4) = '{year}' 
                """
    else:
        query = f"""SELECT * 
                    FROM dep_delay 
                    WHERE SUBSTRING(date, 1, 4) = '{year}' 
                """
    df = pg_cli.to_frame(query).squeeze()
    return df

def plot_airport(df, origin, year, location):
    fig, ax = plt.subplots(figsize=(18,9))
    plt.set_loglevel('WARNING')
    ax2 = ax.twinx()
    ax.yaxis.tick_left()
    ax2.yaxis.tick_right()

    ax.bar(df.date, df.num_flights, color= list(map(lambda x: 'blue' if x <= 0 else 'red', df.outlier)) )
    ax2.plot(ax.get_xticks(), df.dep_delay, color='black')

    ax.set_ylabel('Number of flies')
    ax2.set_ylabel('Avg Delay Time')
    plt.title(f'Number of flights by day - {origin} Airport - Year {year}')
    ax.set_ylim(top= (df.num_flights.max() + 2))
    custom_lines = [Line2D([0], [0], color='blue', lw=4), Line2D([0], [0], color='red', lw=4)]
    ax.legend(custom_lines, ['Normal Delays', 'Unusual Delays'])
    plt.setp( ax.xaxis.get_majorticklabels(), rotation=45)

    # change funtion save_img_to_folder to save_img_to_bucket
    res = save_img_to_folder(fig, location, f'plt/{year}-{origin}.jpg')
    plt.close()
    return res

def plot_generator(db_conn_id, db_name, location, year):
    """Program entrypoint."""
    df = get_data_from_db(db_name, db_conn_id, year)

    for airport in df['origin'].unique():
        plot_airport(df[df['origin']== airport], airport, year, location)
    plt.close('all')

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="DB connection")
    parser.add_argument("--db_conn_id", type=str, help="DB_CONN_ID")
    parser.add_argument("--db_name", type=str, help="DB_NAME")
    parser.add_argument("--location", type=str, help="location")
    parser.add_argument("--year", type=str, help="year")
    params = parser.parse_args()

    plot_generator(params.db_conn_id, params.db_name, 
        params.location, params.year)