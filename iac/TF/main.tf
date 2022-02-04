terraform {
	required_providers {
		aws = {
			source  = "hashicorp/aws"
			version = "3.7"
		}
	}
}

provider "aws" {
	profile = "itba"
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
    tags                             = {
        "Name"    = "mwaa-vpc"
        "Project" = "itba"
    }
}

# aws_subnet.prisub1:
resource "aws_subnet" "prisub1" {
    assign_ipv6_address_on_creation = false
    availability_zone               = "us-east-1e"
    cidr_block                      = "10.192.20.0/24"
    map_public_ip_on_launch         = false
    tags                            = {
        "Name"    = "mwaa-prisub1"
        "Project" = "ITBA"
    }
    vpc_id                          = aws_vpc.mwaavpc.id

    timeouts {}
}

# aws_subnet.prisub2:
resource "aws_subnet" "prisub2" {
    assign_ipv6_address_on_creation = false
    availability_zone               = "us-east-1f"
    cidr_block                      = "10.192.21.0/24"
    map_public_ip_on_launch         = false
    tags                            = {
        "Name"    = "mwaa-prisub2"
        "Project" = "ITBA"
    }
    vpc_id                          = aws_vpc.mwaavpc.id

    timeouts {}
}

# aws_subnet.pubsub1:
resource "aws_subnet" "pubsub1" {
    assign_ipv6_address_on_creation = false
    availability_zone               = "us-east-1e"
    cidr_block                      = "10.192.10.0/24"
    map_public_ip_on_launch         = false
    tags                            = {
        "Name"    = "mwaa-pubsub1"
        "Project" = "ITBA"
    }
    vpc_id                          = aws_vpc.mwaavpc.id

    timeouts {}
}

# aws_subnet.pubsub2:
resource "aws_subnet" "pubsub2" {
    assign_ipv6_address_on_creation = false
    availability_zone               = "us-east-1f"
    cidr_block                      = "10.192.11.0/24"
    map_public_ip_on_launch         = false
    tags                            = {
        "Name"    = "mwaa-pubsub2"
        "Project" = "ITBA"
    }
    vpc_id                          = aws_vpc.mwaavpc.id

    timeouts {}
}

# aws_internet_gateway.mwaaig:
resource "aws_internet_gateway" "mwaaig" {
    tags     = {
        "Name"    = "mwaa-ig"
        "Project" = "ITBA"
    }
    vpc_id   = aws_vpc.mwaavpc.id
}

# aws_eip.eip1:
resource "aws_eip" "eip1" {
    public_ipv4_pool  = "amazon"
    tags              = {}
    vpc               = true

    timeouts {}
}

# aws_eip.eip2:
resource "aws_eip" "eip2" {
    public_ipv4_pool  = "amazon"
    tags              = {}
    vpc               = true

    timeouts {}
}

# aws_nat_gateway.mwaang1:
resource "aws_nat_gateway" "mwaang1" {
    allocation_id        = aws_eip.eip1.id
    subnet_id            = aws_subnet.pubsub1.id
    tags                 = {
        "Name"    = "mwaa-ng1"
        "Project" = "ITBA"
    }
}

# aws_nat_gateway.mwaang2:
resource "aws_nat_gateway" "mwaang2" {
    allocation_id        = aws_eip.eip2.id
    subnet_id            = aws_subnet.pubsub2.id
    tags                 = {
        "Name"    = "mwaa-ng2"
        "Project" = "ITBA"
    }
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
        },
    ]
    tags             = {
        "Name"    = "mwaa-priroute1"
        "Project" = "ITBA"
    }
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
        },
    ]
    tags             = {
        "Name"    = "mwaa-priroute2"
        "Project" = "ITBA"
    }
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
        },
    ]
    tags             = {
        "Name"    = "mwaa-pubroute"
        "Project" = "ITBA"
    }
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
            ipv6_cidr_blocks = []
            prefix_list_ids  = []
            protocol         = "-1"
            security_groups  = []
            self             = false
            to_port          = 0
        },
    ]
    ingress     = [
        {
            cidr_blocks      = []
            description      = ""
            from_port        = 0
            ipv6_cidr_blocks = []
            prefix_list_ids  = []
            protocol         = "-1"
            security_groups  = []
            self             = true
            to_port          = 0
        },
    ]
    name        = "mwaa-sg"
    tags        = {
        "Project" = "ITBA"
    }
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
    tags = {
		"Project" = "ITBA"
	}
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
    engine_version                        = "13.1"
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
    option_group_name                     = "default:postgres-13"
    parameter_group_name                  = "default.postgres13"
    performance_insights_enabled          = true
    performance_insights_retention_period = 7
    port                                  = 5432
    publicly_accessible                   = false
    skip_final_snapshot                   = true
    storage_encrypted                     = false
    storage_type                          = "gp2"
    username                              = "postgres"
	password             				  = var.RDSpassword
    tags = {
		"Project" = "ITBA"
	}

    vpc_security_group_ids                = [
        aws_security_group.mwaasg.id,
    ]

    timeouts {}
}


/*resource "aws_s3_bucket" "mwaabucket" {
	bucket = "my-tf-test-bucket-itba"

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
