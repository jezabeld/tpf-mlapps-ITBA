# Instrucciones para levantar la arquitectura

1. Instalar el cliente de aws siguiendo [estas instrucciones](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) acorde a su sistema
operativo y configurar las credenciales de la cuenta siguiendo estos pasos: [AWS CLI Configuration basics](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html).
2. Instalar el cliente de Kaggle: `pip install kaggle`
3. Configurar las credenciales siguiendo [estas instrucciones](https://github.com/Kaggle/kaggle-api#api-credentials).
4. Instalar el cliente de terraform siguiendo estas instrucciones: [Install Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

5. Configurar variables para crear la arquitectura:

    Utilizando como ejemplo el archivo [terraform.tf.vars.template](./terraform/terraform.tf.vars.template) ubicado en el directorio de terraform, 
    crear el archivo `terraform.tfvars` en la misma carpeta. En caso de que se desee, se pueden modificar algunas de las variables para sobreescribir sus valores default:
    - tags: en formato map ("clave": "valor" estilo JSON), las tags que se deberán utilizar en los recursos a crear.

    - env_name: nombre para el entorno de MWAA (Managed Workflows for Apache Airflow)

    - RDSpassword: password para la base de datos donde se almacenará la información.
    
6. Incializar terraform:

    Para construir la arquitectura, es necesario abrir una consola en la carpeta [terraform](./terraform) e inicializar terraform: `terraform init`,
    de esta forma se instalarán los modulos del provider AWS y se reconoceran los modulos creados localmente.

7. Aprovisionar la arquitectura:

    Para comenzar el aprovisionamiento se debe correr el comando `terraform apply` dentro de la carpeta [terraform](./terraform), el cual realizará 
    un chequeo del código de implementación de la arquitectura enunciando cuántos recursos se crearán, y luego solicitará confirmación para comenzar 
    a aplicar los cambios.

    Este proyecto comenzará a generar los recursos en la cuenta indicada con las credenciales del perfil utilizado (las que se encuentran configuradas 
    en ~/.aws/credentials). Luego de crear un bucket en s3 comenzará a cargar la data de Kaggle descargándola primero en la máquina local (se generará 
    una carpeta `data` en el directorio principal del proyecto automáticamente). Mientras se carga dicha data también se irán creando los recursos 
    necesarios para el resto del proyecto en la cuenta de AWS (VPC, subnets, instancia de base de datos, environment de Airflow, etc...).

    Nota: este paso lleva bastante tiempo ya que el upload de la data al bucket puede tardar aprox una hora (dependiendo de la conexión a internet disponible)
    y el aprovisionamiento del entorno de Airflow también puede demorar bastante por la instalación de las librerías requeridas.

8. Acceder a los servicios:
    Al finalizar el aprovisionamiento de los servicios, terraform devolverá los siguientes outputs:
    - bucket_name: el nombre del bucket creado donde se subió la data de Kaggle y las configs para Airflow.

    - airflow_webserver: link a la UI de Airflow.

    - db_uri: URI de conexión a la base de datos.

    - superset_dns: link al servicio de superset.

9. Visualizacion en superset:

    Para poder visualizar los datos de generados por el DAG en la base de datos, es necesario conectarse al servicio de Superset con la URL obtenida de terraform (o desde la consola de AWS se puede buscar el dns del load_balancer creado como "superset-alb"). Las credenciales para loguearse son:
     - user: admin
       
     - password: superset

    Luego se pueden seguir las instrucciones encontradas en el archivo [Superset_Istructivo.docx](./Superset_Istructivo.docx) para conectarse a la base de datos y crear visualizaciones a partir de la info allí cargada. 
    Se puede importar el dashboard de ejemplo que se encuentra en la carpeta [superset_example_files](./superset_example_files) con el nombre de archivo [dashboard.json](./superset_example_files/dashboard.jsonl) teniendo en cuenta que se debe crear la conexion a la base de datos con el nombre "DelayDB" primero y luego desde el menu de la UI de superset, ingresar a la opcion "Manage" -> "Import Dashboards". Este método importará la configuración de la tabla, un gráfico y un dashboard con dicho gráfico, que pueden encontrase ingresando a las respectivas secciones desde la UI de superset.
    
    Se debe tener en cuenta que la tabla utilizada en las visualizaciones es generada por el DAG, por lo que no se encontrará disponible antes de que éste haya corrido al menos una vez.

10. Destruccion de los recursos:

    Una vez finalizado el trabajo se puede correr el comando `terraform destroy´ dentro de la crpeta de terraform para destruir todos los recursos creados. Este comando solicitará confirmación para procedeer y luego irá eliminando todos los recursos (incluyendo los archivos en el bucket creado, la instancia de la base de datos, logs y demas elememtos creados).

    
## Posibles inconvenientes

 - Version de la base de datos no disponible:

    Error en terraform: "Error creating DB Instance: InvalidParameterCombination: Cannot find version XX.XX for postgres"
    Solución: en el módulo database en la carpeta de terraform se deberá modificar el archivo main.tf para el recurso aws_db_instance.rdspostgres, reemplazando en la línea 20 el parámetro "engine_version" por una versión de postgres disponible. Se pueden comprobar las versiones desde la consola de AWS o utilizando aws cli: `aws rds describe-db-engine-versions --engine postgres`.
