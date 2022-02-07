# aws_vpc.mwaavpc:
resource "aws_vpc" "mwaavpc" {
    assign_generated_ipv6_cidr_block = false
    cidr_block                       = var.vpc_cidr
    enable_classiclink               = false
    enable_classiclink_dns_support   = false
    enable_dns_hostnames             = false
    enable_dns_support               = true
    instance_tenancy                 = "default"
    tags                             = merge({Name = "mwaa-vpc"}, var.v_tags)
}

/*
# .prisub1:
resource "aws_subnet" "prisub1" {
    assign_ipv6_address_on_creation = false
    availability_zone               = "us-east-1e"
    cidr_block                      = var.subnet_cidrs[0]
    map_public_ip_on_launch         = false
    tags                             = merge({Name = "mwaa-prisub1"}, var.v_tags)

    vpc_id                          = aws_vpc.mwaavpc.id
}

# aws_subnet.prisub2:
resource "aws_subnet" "prisub2" {
    assign_ipv6_address_on_creation = false
    availability_zone               = "us-east-1f"
    cidr_block                      = var.subnet_cidrs[1]
    map_public_ip_on_launch         = false
    tags                             = merge({Name = "mwaa-prisub2"}, var.v_tags)

    vpc_id                          = aws_vpc.mwaavpc.id
}
*/
resource "aws_subnet" "prisubnets" {
    count                           = 2
    assign_ipv6_address_on_creation = false
    availability_zone               = count.index % 2 == 0 ? "${var.region}e" : "${var.region}f"
    cidr_block                      = var.subnet_cidrs[count.index]
    map_public_ip_on_launch         = false
    tags                             = merge({Name = "mwaa-prisub${count.index}"}, var.v_tags)

    vpc_id                          = aws_vpc.mwaavpc.id
}
/*
# aws_subnet.pubsub1:
resource "aws_subnet" "pubsub1" {
    assign_ipv6_address_on_creation = false
    availability_zone               = "us-east-1e"
    cidr_block                      = var.subnet_cidrs[2]
    map_public_ip_on_launch         = true
    tags                             = merge({Name = "mwaa-pubsub1"}, var.v_tags)

    vpc_id                          = aws_vpc.mwaavpc.id

}

# aws_subnet.pubsub2:
resource "aws_subnet" "pubsub2" {
    assign_ipv6_address_on_creation = false
    availability_zone               = "us-east-1f"
    cidr_block                      = var.subnet_cidrs[3]
    map_public_ip_on_launch         = true
    tags                             = merge({Name = "mwaa-pubsub2"}, var.v_tags)

    vpc_id                          = aws_vpc.mwaavpc.id
}
*/
resource "aws_subnet" "pubsubnets" {
    count                           = 2
    assign_ipv6_address_on_creation = false
    availability_zone               = count.index % 2 == 0 ? "${var.region}e" : "${var.region}f"
    cidr_block                      = var.subnet_cidrs[count.index + 2]
    map_public_ip_on_launch         = true
    tags                             = merge({Name = "mwaa-pubsub${count.index}"}, var.v_tags)

    vpc_id                          = aws_vpc.mwaavpc.id
}

# aws_internet_gateway.mwaaig:
resource "aws_internet_gateway" "mwaaig" {
    tags                             = merge({Name = "mwaa-ig"}, var.v_tags)
    vpc_id   = aws_vpc.mwaavpc.id
}
/*
# aws_eip.eip1:
resource "aws_eip" "eip1" {
    public_ipv4_pool  = "amazon"
    tags              = var.v_tags
    vpc               = true
}


# aws_eip.eip2:
resource "aws_eip" "eip2" {
    public_ipv4_pool  = "amazon"
    tags              = var.v_tags
    vpc               = true
}
*/
resource "aws_eip" "eips" {
    count             = 2
    public_ipv4_pool  = "amazon"
    tags              = var.v_tags
    vpc               = true
}
/*
# aws_nat_gateway.mwaang1:
resource "aws_nat_gateway" "mwaang1" {
    allocation_id        = aws_eip.eip1.id
    subnet_id            = aws_subnet.pubsub1.id 
    tags                 = merge({Name = "mwaa-ng1"}, var.v_tags)

}

# aws_nat_gateway.mwaang2:
resource "aws_nat_gateway" "mwaang2" {
    allocation_id        = aws_eip.eip2.id
    subnet_id            = aws_subnet.pubsub2.id
    tags                 = merge({Name = "mwaa-ng2"}, var.v_tags)

}
*/
resource "aws_nat_gateway" "mwaanatgateways" {
    count                = 2
    allocation_id        = aws_eip.eips[count.index].id
    subnet_id            = aws_subnet.pubsubnets[count.index].id
    tags                 = merge({Name = "mwaa-ng${count.index}"}, var.v_tags)
}
/*
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
    tags             = merge({Name = "mwaa-priroute1"}, var.v_tags)

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
    tags             = merge({Name = "mwaa-priroute2"}, var.v_tags)

    vpc_id           = aws_vpc.mwaavpc.id
}
*/
resource "aws_route_table" "priroutes" {
    count            = 2
    propagating_vgws = []
    route            = [
        {
            cidr_block                = "0.0.0.0/0"
			egress_only_gateway_id    = ""
			gateway_id                = ""
			instance_id               = ""
            ipv6_cidr_block           = ""
            local_gateway_id          = ""
            nat_gateway_id            = aws_nat_gateway.mwaanatgateways[count.index].id
			network_interface_id      = ""
            transit_gateway_id        = ""
            vpc_peering_connection_id = ""
            carrier_gateway_id        = ""
            destination_prefix_list_id = ""
            vpc_endpoint_id           = ""
        },
    ]
    tags             = merge({Name = "mwaa-priroute${count.index}"}, var.v_tags)
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
    tags             = merge({Name = "mwaa-pubroute"}, var.v_tags)

    vpc_id           = aws_vpc.mwaavpc.id
}
/*
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
*/
resource "aws_route_table_association" "assocpub" {
    count          = 2
	subnet_id      = aws_subnet.pubsubnets[count.index].id
	route_table_id = aws_route_table.pubroute.id

	depends_on = [aws_subnet.pubsubnets,aws_route_table.pubroute]
}
/*
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
*/
resource "aws_route_table_association" "assocpri" {
    count          = 2
	subnet_id      = aws_subnet.prisubnets[count.index].id
	route_table_id = aws_route_table.priroutes[count.index].id

	depends_on = [aws_subnet.prisubnets,aws_route_table.priroutes]
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
    tags        = var.v_tags
    vpc_id      = aws_vpc.mwaavpc.id

    timeouts {}
}