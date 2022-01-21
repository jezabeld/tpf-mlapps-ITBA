# Steps DEV

## 1) Set initial architecture.
Use of Docker containers with python and JupyterLab to start exploring the data: [archivo YML](docker-compose.yml).

## 2) Get the data.
Installing Kaggle client inside container (Linux) and downloading data.

```bash
pip install kaggle
mkdir /root/.kaggle
# cd to your local directory
cd /home
cp kaggle.json /root/.kaggle/kaggle.json
# Download zipped dataset from kaggle
kaggle datasets download -d yuanyuwendymu/airline-delay-and-cancellation-data-2009-2018
# Unzip files
unzip airline-delay-and-cancellation-data-2009-2018.zip -d raw/
# remove zip file
rm airline-delay-and-cancellation-data-2009-2018.zip 
```

## 3) Data Exploration.
Fast exploration of the data: [Jupyter Notebook](./jupyter/Exploratory.ipynb).

## 4) Outlier detection algorithm.
Creation of a very naive outlier detection: [Jupyter Notebook](./jupyter/Outlier_detection.ipynb).

## 5) Local Airflow and Postgres.
Creation of a local architecture to start using Airflow and Postgres. A local folder will replace the bucket for now.

## 6) Data Model Definition.
Data model definition, DB connections.

## 7) Dag to load the data into Postgres.
First version of the DAG.