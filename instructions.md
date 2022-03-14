
1. Instalar el cliente de aws siguiendo [estas instrucciones](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) acorde a su sistema
operativo y configurar las credenciales de la cuenta siguiendo estos pasos: [AWS CLI Configuration basics](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html).
2. Instalar el cliente de Kaggle: `pip install kaggle`
3. Configurar las credenciales siguiendo [estas instrucciones](https://github.com/Kaggle/kaggle-api#api-credentials).
4. Instalar el cliente de terraform siguiendo estas instrucciones: [Install Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

--> cuenta de quicksight en AWS con permiso de lectura a RDS

5. Configurar variables para crear la arquitectura:
    Utilizando como template el archivo [terraform.tf.vars.template](./terraform/terraform.tf.vars.template) ubicado en el directorio de terraform, 
    completar con la variables obligatoria para poder correr la arquitectura: account_id. En caso de que se desee, se pueden modificar algunas de las
    siguientes variables:
    - tags: en formato map ("clave": "valor" estilo JSON), las tags que se deberán utilizar en los recursos a crear.
    - env_name: nombre para el entorno de MWAA (Managed Workflows for Apache Airflow)
    - RDSpassword: password para la base de datos donde se almacenará la información.
    - db_schema_name: nombre del schema o database en postgres para almacenar la información.
    
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
    y el aprovisionamiento del entorno de Airflow también puede demorar hasta 40 minutos.

8. Acceder a los servicios:
    