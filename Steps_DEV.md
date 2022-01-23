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

## 8) Config AWS CLI in docker container.
```bash
# run docker container
docker run -it -v `pwd`/dags/data/:/home/ --name python python:3 bash
cd /home
# download and install CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
# test
which aws
/usr/local/bin/aws --version
# remove the zip file
rm awscliv2.zip
```
Optionally an AWS docker container can be used: [AWS CLI Docker](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-docker.html).

To configure the account:
```bash
aws configure
# AWS Access Key ID [None]: AKIAIOSFODNN7EXAMPLE
# AWS Secret Access Key [None]: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
# Default region name [None]: us-west-2
# Default output format [None]: json
```

## 9) Scketch final architecture.
Info about AWS MWAA: [Apache Airflow 2.0 on Amazon MWAA](https://www.youtube.com/watch?v=79IyGdIU7FA)
Tutorial with a local docker container: (https://docs.aws.amazon.com/mwaa/latest/userguide/tutorials-docker.html).
