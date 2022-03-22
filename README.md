# tpf-mlapps-ITBA
TP Final del módulo de Machine Learning Applications de la Diplomatura en Cloud Data Engineering de ITBA

---
## Contexto:

Acaba de ser contratado como el primer ingeniero de datos de una pequeña empresa de viajes.

Su primera tarea para usted fue demostrar el valor y los conocimientos que se
pueden generar a partir de las canalizaciones de datos.

Su plan es que una vez que demuestre lo valiosos que pueden ser los datos,
comenzarán a invertir en el uso de un proveedor de instancias en la nube.
Por ahora, su propia computadora tendrá que hacerlo.

## Objetivo:

Crear un DAG de Airflow que actúe de ETL para extraer datos estáticos de S3
y los cargue en una base de datos de Postgres. Para llevar a cabo el desarrollo se utilizará el dataset de [demoras y cancelaciones de viajes aéreos](https://www.kaggle.com/yuanyuwendymu/airline-delay-and-cancellation-data-2009-2018?select=2009.csv) de Kaggle.
Se deben cumplir los siguientes pasos:
1. Configurar Airflow para que corra en AWS.
2. Crear una instancia RDS de Postgres.
3. Desarrollar un DAG de Airflow con schedule anual que realice detección de anomalías para identificar por cada aeropuerto si hubo algún día con demoras fuera de lo normal, por cada      aeropuerto produzca un gráfico desde Python en el cual se pueda ver la cantidad de vuelos de cada día con alguna indicación en los días que fueron considerados anómalos y almacénelo en S3 en un path fácilmente identificable por año y aeropuerto analizado, luego se debe cargar la data sumarizada junto con un indicador de dato anómalo. 
4. Desarrollar una visualización de los datos cargados. 

Para más detalle sobre las consignas ver el archivo [Consignas.md](./Consignas.md).

