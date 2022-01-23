# Steps TEST

## 1) Set testing architecture.
Info about AWS MWAA: [Apache Airflow 2.0 on Amazon MWAA](https://www.youtube.com/watch?v=79IyGdIU7FA)
Tutorial with a local docker container: (https://docs.aws.amazon.com/mwaa/latest/userguide/tutorials-docker.html).

To start testing MWAA, copy the files from [aws-mwaa-local-runner](https://github.com/aws/aws-mwaa-local-runner) and build the image.
NOTE: Original repo rise an error when building image, to fix it is needed to change constraints.txt file in the line for Flask-OpenID and set version 1.3.0.

```bash
# build image
./mwaa-local-env build-image
# start image
./mwaa-local-env start
```

Login to Apache Airflow at http://localhost:8080/:

Username: admin
Password: test

To install libraries in this environment, copy them in ./dags/requirements.txt. This file emulates the requirements file in S3 bucket in the real environment.

