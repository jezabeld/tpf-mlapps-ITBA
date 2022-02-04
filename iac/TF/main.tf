terraform {
	required_providers {
		aws = {
			source  = "hashicorp/aws"
			version = "3.74"
		}
	}
}

provider "aws" {
	profile = "default"
	region = "us-east-1"
}

# aws_vpc.mwaavpc:
resource "aws_vpc" "mwaavpc" {
    assign_generated_ipv6_cidr_block = false
    cidr_block                       = "10.192.0.0/16"
    enable_classiclink               = false
    enable_classiclink_dns_support   = false
    enable_dns_hostnames             = false
    enable_dns_support               = true
    instance_tenancy                 = "default"
    tags                             = merge({Name = "mwaa-vpc"}, var.tags)
}

# aws_subnet.prisub1:
resource "aws_subnet" "prisub1" {
    assign_ipv6_address_on_creation = false
    availability_zone               = "us-east-1e"
    cidr_block                      = "10.192.20.0/24"
    map_public_ip_on_launch         = false
    tags                             = merge({Name = "mwaa-prisub1"}, var.tags)

    vpc_id                          = aws_vpc.mwaavpc.id
}

# aws_subnet.prisub2:
resource "aws_subnet" "prisub2" {
    assign_ipv6_address_on_creation = false
    availability_zone               = "us-east-1f"
    cidr_block                      = "10.192.21.0/24"
    map_public_ip_on_launch         = false
    tags                             = merge({Name = "mwaa-prisub2"}, var.tags)

    vpc_id                          = aws_vpc.mwaavpc.id
}

# aws_subnet.pubsub1:
resource "aws_subnet" "pubsub1" {
    assign_ipv6_address_on_creation = false
    availability_zone               = "us-east-1e"
    cidr_block                      = "10.192.10.0/24"
    map_public_ip_on_launch         = true
    tags                             = merge({Name = "mwaa-pubsub1"}, var.tags)

    vpc_id                          = aws_vpc.mwaavpc.id

}

# aws_subnet.pubsub2:
resource "aws_subnet" "pubsub2" {
    assign_ipv6_address_on_creation = false
    availability_zone               = "us-east-1f"
    cidr_block                      = "10.192.11.0/24"
    map_public_ip_on_launch         = true
    tags                             = merge({Name = "mwaa-pubsub2"}, var.tags)

    vpc_id                          = aws_vpc.mwaavpc.id
}

# aws_internet_gateway.mwaaig:
resource "aws_internet_gateway" "mwaaig" {
    tags                             = merge({Name = "mwaa-ig"}, var.tags)

    vpc_id   = aws_vpc.mwaavpc.id
}

# aws_eip.eip1:
resource "aws_eip" "eip1" {
    public_ipv4_pool  = "amazon"
    tags              = var.tags
    vpc               = true
}

# aws_eip.eip2:
resource "aws_eip" "eip2" {
    public_ipv4_pool  = "amazon"
    tags              = var.tags
    vpc               = true
}

# aws_nat_gateway.mwaang1:
resource "aws_nat_gateway" "mwaang1" {
    allocation_id        = aws_eip.eip1.id
    subnet_id            = aws_subnet.pubsub1.id
    tags                 = merge({Name = "mwaa-ng1"}, var.tags)

}

# aws_nat_gateway.mwaang2:
resource "aws_nat_gateway" "mwaang2" {
    allocation_id        = aws_eip.eip2.id
    subnet_id            = aws_subnet.pubsub2.id
    tags                 = merge({Name = "mwaa-ng2"}, var.tags)

}

# aws_route_table.priroute1:
resource "aws_route_table" "priroute1" {
    propagating_vgws = []
    route            = [
        {
            cidr_block                = "0.0.0.0/0"
			egress_only_gateway_id    = ""
			gateway_id                = ""
			instance_id               = ""
            ipv6_cidr_block           = ""
            local_gateway_id          = ""
            nat_gateway_id            = aws_nat_gateway.mwaang1.id 
			network_interface_id      = ""
            transit_gateway_id        = ""
            vpc_peering_connection_id = ""
            carrier_gateway_id        = ""
            destination_prefix_list_id = ""
            vpc_endpoint_id           = ""
        },
    ]
    tags             = merge({Name = "mwaa-priroute1"}, var.tags)

    vpc_id           = aws_vpc.mwaavpc.id
}

# aws_route_table.priroute2:
resource "aws_route_table" "priroute2" {
    propagating_vgws = []
    route            = [
        {
            cidr_block                = "0.0.0.0/0"
			egress_only_gateway_id    = ""
			gateway_id                = ""
			instance_id               = ""
            ipv6_cidr_block           = ""
            local_gateway_id          = ""
            nat_gateway_id            = aws_nat_gateway.mwaang2.id
			network_interface_id      = ""
            transit_gateway_id        = ""
            vpc_peering_connection_id = ""
            carrier_gateway_id        = ""
            destination_prefix_list_id = ""
            vpc_endpoint_id           = ""
        },
    ]
    tags             = merge({Name = "mwaa-priroute2"}, var.tags)

    vpc_id           = aws_vpc.mwaavpc.id
}

# aws_route_table.pubroute:
resource "aws_route_table" "pubroute" {
    propagating_vgws = []
    route            = [
        {
            cidr_block                = "0.0.0.0/0"
			egress_only_gateway_id    = ""
            gateway_id                = aws_internet_gateway.mwaaig.id
			instance_id               = ""
            ipv6_cidr_block           = ""
            local_gateway_id          = ""
            nat_gateway_id            = ""
            network_interface_id      = ""
            transit_gateway_id        = ""
            vpc_peering_connection_id = ""
            carrier_gateway_id        = ""
            destination_prefix_list_id = ""
            vpc_endpoint_id           = ""

        },
    ]
    tags             = merge({Name = "mwaa-pubroute"}, var.tags)

    vpc_id           = aws_vpc.mwaavpc.id
}

# aws_route_table_association.a1:
resource "aws_route_table_association" "a1" {
	subnet_id      = aws_subnet.pubsub2.id
	route_table_id = aws_route_table.pubroute.id

	depends_on = [aws_subnet.pubsub2,aws_route_table.pubroute]
}

# aws_route_table_association.a2:
resource "aws_route_table_association" "a2" {
	subnet_id      = aws_subnet.pubsub1.id
	route_table_id = aws_route_table.pubroute.id

	depends_on = [aws_subnet.pubsub1,aws_route_table.pubroute]
}

# aws_route_table_association.a3:
resource "aws_route_table_association" "a3" {
	subnet_id      = aws_subnet.prisub1.id
	route_table_id = aws_route_table.priroute1.id

	depends_on = [aws_subnet.prisub1,aws_route_table.priroute1]
}

# aws_route_table_association.a4:
resource "aws_route_table_association" "a4" {
	subnet_id      = aws_subnet.prisub2.id
	route_table_id = aws_route_table.priroute2.id

	depends_on = [aws_subnet.prisub2,aws_route_table.priroute2]
}

# aws_security_group.mwaasg:
resource "aws_security_group" "mwaasg" {
    description = "Security group with a self-referencing inbound rule."
    egress      = [
        {
            cidr_blocks      = [
                "0.0.0.0/0",
            ]
            description      = ""
            from_port        = 0
            protocol         = "-1"
            to_port          = 0
            ipv6_cidr_blocks = []
            prefix_list_ids  = []
            security_groups  = []
            self             = false
        },
    ]
    ingress     = [
        {
            description      = ""
            from_port        = 0
            protocol         = "-1"
            self             = true
            to_port          = 0
            cidr_blocks      = []
            ipv6_cidr_blocks = []
            prefix_list_ids  = []
            security_groups  = []
        },
    ]
    name        = "mwaa-sg"
    tags        = var.tags
    vpc_id      = aws_vpc.mwaavpc.id

    timeouts {}
}

# aws_db_subnet_group.dbsubnetgroup:
resource "aws_db_subnet_group" "dbsubnetgroup" {
    description = "Subnet group for RDS instance"
    name        = "default-vpc-0af01a8b397cca7ee"
    subnet_ids  = [
		aws_subnet.prisub1.id,
		aws_subnet.prisub2.id
    ]
    tags = var.tags
}

# aws_db_instance.rdspostgres:
resource "aws_db_instance" "rdspostgres" {
    allocated_storage                     = 20
    auto_minor_version_upgrade            = false
    backup_retention_period               = 0
    copy_tags_to_snapshot                 = true
    db_subnet_group_name                  = aws_db_subnet_group.dbsubnetgroup.name
    delete_automated_backups              = true
    deletion_protection                   = false
    enabled_cloudwatch_logs_exports       = []
    engine                                = "postgres"
    engine_version                        = "11.1"
    iam_database_authentication_enabled   = false
    identifier                            = "mwaa-postgres"
    instance_class                        = "db.t3.micro"
    iops                                  = 0
    license_model                         = "postgresql-license"
    maintenance_window                    = "tue:10:08-tue:10:38"
    max_allocated_storage                 = 0
    monitoring_interval                   = 0
    multi_az                              = false
    name                                  = "postgres"
    option_group_name                     = "default:postgres-11"
    parameter_group_name                  = "default.postgres11"
    performance_insights_enabled          = true
    performance_insights_retention_period = 7
    port                                  = 5432
    publicly_accessible                   = false
    skip_final_snapshot                   = true
    storage_encrypted                     = false
    storage_type                          = "gp2"
    username                              = "postgres"
	password             				  = var.RDSpassword
    tags = var.tags

    vpc_security_group_ids                = [
        aws_security_group.mwaasg.id,
    ]

    timeouts {}
}

# aws_secretsmanager_secret.conn_db:
resource "aws_secretsmanager_secret" "conn_db" {
    description      = "Acces to my RDS Postgres database."
    name             = "mwaa/connections/RDSpostgres"
    recovery_window_in_days = 0
    tags             = var.tags
}

resource "aws_secretsmanager_secret_version" "conn_db_val" {
  secret_id = aws_secretsmanager_secret.conn_db.id
  secret_string = "postgres://${aws_db_instance.rdspostgres.username}:${var.RDSpassword}@${aws_db_instance.rdspostgres.endpoint}/${var.db_schema_name}"
}

# aws_secretsmanager_secret.var_conn_id:
resource "aws_secretsmanager_secret" "var_conn_id" {
    description      = "Connection ID for DB."
    name             = "mwaa/variables/conn_id"
    recovery_window_in_days = 0
    tags             = var.tags
}
resource "aws_secretsmanager_secret_version" "var_conn_id_val" {
  secret_id = aws_secretsmanager_secret.var_conn_id.id
  secret_string = var.conn_var
}

# aws_secretsmanager_secret.var_db_name:
resource "aws_secretsmanager_secret" "var_db_name" {
    description      = "Database Name/Schema."
    name             = "mwaa/variables/db_name"
    recovery_window_in_days = 0
    tags             = var.tags
}
resource "aws_secretsmanager_secret_version" "var_db_name_val" {
  secret_id = aws_secretsmanager_secret.var_db_name.id
  secret_string = var.db_schema_name
}

# aws_iam_role.mwaarole:
resource "aws_iam_role" "mwaarole" {
    assume_role_policy    = data.aws_iam_policy_document.assume.json
    
    force_detach_policies = false
#    max_session_duration  = 3600
    name                  = "${var.env_name}-Role"
    path                  = "/service-role/"
    tags                  = var.tags
}


resource "aws_iam_role_policy" "mwaapolicy" {
    name = "mymwaapolicy"
    policy = data.aws_iam_policy_document.this.json
    role = aws_iam_role.mwaarole.id
}

data "aws_iam_policy_document" "assume" {
    version = "2012-10-17"
    statement {
            actions    = ["sts:AssumeRole"]
            effect    = "Allow"
            principals {
                identifiers = [
                    "airflow.amazonaws.com",
                    "airflow-env.amazonaws.com",
                ]
                type = "Service"
            }
        }

}

data "aws_iam_policy_document" "base" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      "airflow:PublishMetrics"
    ]
    resources = [
      "arn:aws:airflow:us-east-1:*:environment/${var.env_name}"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject*",
      "s3:GetBucket*",
      "s3:List*"
    ]
    resources = [
      "arn:aws:s3:::${var.bucket_name}",
      "arn:aws:s3:::${var.bucket_name}/*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:PutLogEvents",
      "logs:GetLogEvents",
      "logs:GetLogRecord",
      "logs:GetLogGroupFields",
      "logs:GetQueryResults"
    ]
    resources = [
      "arn:aws:logs:us-east-1:*:log-group:airflow-*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "logs:DescribeLogGroups"
    ]
    resources = [
      "*"
    ]
  }
  statement {

    effect = "Allow"
    actions = [
      "cloudwatch:PutMetricData"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "sqs:ChangeMessageVisibility",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ReceiveMessage",
      "sqs:SendMessage"
    ]
    resources = [
      "arn:aws:sqs:us-east-1:*:airflow-celery-*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:GenerateDataKey*",
      "kms:Encrypt"
    ]
    not_resources = [
      "arn:aws:kms:*:${var.account_id}:key/*"
    ]
    condition {
      test = "StringLike"
      values = [
        "sqs.us-east-1.amazonaws.com"]
      variable = "kms:ViaService"
    }
  }
}
data "aws_iam_policy_document" "aditional" {
    statement {
      effect = "Allow"
      actions = [
            "secretsmanager:GetResourcePolicy",
            "secretsmanager:GetSecretValue",
            "secretsmanager:DescribeSecret",
            "secretsmanager:ListSecretVersionIds"
      ]
      resources = [ "arn:aws:secretsmanager:us-east-1:*:secret:*"]
    }
    statement {
      effect = "Allow"
      actions = [
          "secretsmanager:ListSecrets"
      ]
      resources = [ "*" ]
    }
}
data "aws_iam_policy_document" "this" {
  source_policy_documents = [
    data.aws_iam_policy_document.base.json ,
    data.aws_iam_policy_document.aditional.json
  ]
}

# aws_mwaa_environment.mwaaEnv:
resource "aws_mwaa_environment" "mwaaEnv" {
    airflow_configuration_options   = var.airflow_config
    airflow_version                 = "2.2.2"
    dag_s3_path                     = var.dag_s3_path
    environment_class               = "mw1.small"
    execution_role_arn              = aws_iam_role.mwaarole.arn
    max_workers                     = 2
    min_workers                     = 1
    name                            = var.env_name
    requirements_s3_object_version  = ""
    requirements_s3_path            = var.requirements_s3_path
    source_bucket_arn               = "arn:aws:s3:::${var.bucket_name}"
    tags                            = var.tags
    tags_all                        = var.tags
    webserver_access_mode           = "PUBLIC_ONLY"
    weekly_maintenance_window_start = "THU:16:00"

    logging_configuration {
        dag_processing_logs {
            enabled   = true
            log_level = "WARNING"
        }

        scheduler_logs {
            enabled   = true
            log_level = "WARNING"
        }

        task_logs {
            enabled                   = true
            log_level                 = "INFO"
        }

        webserver_logs {
            enabled   = true
            log_level = "WARNING"
        }

        worker_logs {
            enabled   = true
            log_level = "WARNING"
        }
    }

    network_configuration {
        security_group_ids = [
            aws_security_group.mwaasg.id,
        ]
        subnet_ids         = [
            aws_subnet.prisub1.id,
            aws_subnet.prisub2.id,
        ]
    }

    depends_on = [
      aws_iam_role.mwaarole,
      aws_security_group.mwaasg,
      aws_subnet.prisub1,
      aws_subnet.prisub2,
    ]
}


/*resource "aws_s3_bucket" "mwaabucket" {
	bucket = var.bucket_name

	# required: https://docs.aws.amazon.com/mwaa/latest/userguide/mwaa-s3-bucket.html
	versioning {
		enabled = true
	}
	tags = {
		"Project" = "ITBA"
	}
}

resource "aws_s3_bucket_public_access_block" "mwaa" {
	# required: https://docs.aws.amazon.com/mwaa/latest/userguide/mwaa-s3-bucket.html
	bucket                  = aws_s3_bucket.mwaabucket.id
	block_public_acls       = true
	block_public_policy     = true
	ignore_public_acls      = true
	restrict_public_buckets = true
}
*/