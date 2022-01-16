# tpf-mlapps-ITBA
TP Final del módulo de Machine Learning Applications de la Diplomatura en Cloud Data Engineering de ITBA

---
## 1) Set initial architecture.
Use of Docker containers with python and JupyterLab to start exploring the data: [archivo YML](docker-compose.yml).

## 2) Get the data.
Installing Kaggle client inside container (Linux) and downloading data.
The main idea is to be able to reuse this code (or part of it) when setting AWS final architecture.

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