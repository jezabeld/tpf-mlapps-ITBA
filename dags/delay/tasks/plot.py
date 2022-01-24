"""Script to plot delay data."""
import argparse
from utils.models import DepDelay
from utils.db_connections import PostgresClient

import matplotlib.pyplot as plt
from matplotlib.lines import Line2D

def get_data_from_db(db_name, user, passw, db_url, year, origin=None):
    pg_cli = PostgresClient(db_name, 'RDSpostgres') #user, passw, db_url)
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

    fig.savefig(f'{location}{year}-{origin}.jpg', transparent=False, dpi=80, bbox_inches="tight")
    plt.clf()

def plot_generator(user, passw, db_url, db_name, location, year):
    """Program entrypoint."""
    df = get_data_from_db(db_name, user, passw, db_url, year)

    for airport in df['origin'].unique():
        plot_airport(df[df['origin']== airport], airport, year, location)
    plt.close('all')

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="DB connection")
    parser.add_argument("--user", type=str, help="USER")
    parser.add_argument("--passw", type=str, help="PASSWORD")
    parser.add_argument("--db_url", type=str, help="DB_URL")
    parser.add_argument("--db_name", type=str, help="DB_NAME")
    parser.add_argument("--location", type=str, help="location")
    parser.add_argument("--year", type=str, help="year")
    params = parser.parse_args()

    plot_generator(params.user, params.passw, params.db_urn, params.db_name, 
        params.location, params.year)