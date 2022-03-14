# module.superset.aws_ecs_cluster.cluster:
resource "aws_ecs_cluster" "cluster" {
    capacity_providers = []
    name               = "superset-cluster"
    tags               = {}

    setting {
        name  = "containerInsights"
        value = "disabled"
    }
}

data "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
}

# module.superset.aws_ecs_task_definition.superset_webserver:
resource "aws_ecs_task_definition" "superset_webserver" {
    container_definitions    = jsonencode(
        [
            {
                cpu              = 0
                environment      = []
                essential        = true
                image            = "tylerfowler/superset"
                logConfiguration = {
                    logDriver = "awslogs"
                    options   = {
                        awslogs-group         = "/ecs/superset_webserver"
                        awslogs-region        = "${var.region}"
                        awslogs-create-group  = "true"
                        awslogs-stream-prefix = "ecs"
                    }
                }
                memory           = 2000
                mountPoints      = []
                name             = "superset"
                portMappings     = [
                    {
                        containerPort = 8088
                        hostPort      = 8088
                        protocol      = "tcp"
                    },
                ]
                volumesFrom      = []
            },
        ]
    )
    cpu                      = "1024"
    execution_role_arn       = "${data.aws_iam_role.ecs_task_execution_role.arn}" 
    family                   = "superset_webserver"
    memory                   = "2048"
    network_mode             = "awsvpc"
    requires_compatibilities = [
        "FARGATE",
    ]
    tags                     = {}

    runtime_platform {
        operating_system_family = "LINUX"
    }
    depends_on = [
      aws_ecs_cluster.cluster
    ]

        provisioner "local-exec" {
        when    = destroy
        command = <<EOF
aws logs describe-log-groups --query 'logGroups[*].logGroupName' --output table | \
awk '{print $2}' | grep ^/ecs/superset_webserver | while read x; do  echo "deleting $x"; aws logs delete-log-group --log-group-name $x; done
EOF
    }
}

# module.superset.aws_lb_target_group.target_group:
resource "aws_lb_target_group" "target_group" {
    deregistration_delay          = "300"
    load_balancing_algorithm_type = "round_robin"
    name                          = "superset-tg"
    port                          = 80
    protocol                      = "HTTP"
    protocol_version              = "HTTP1"
    slow_start                    = 0
    tags                          = var.v_tags
    target_type                   = "ip"
    vpc_id                        = var.vpc_id

    health_check {
        enabled             = true
        healthy_threshold   = 5
        interval            = 30
        matcher             = "302"
        path                = "/superset/welcome"
        port                = "traffic-port"
        protocol            = "HTTP"
        timeout             = 5
        unhealthy_threshold = 2
    }

    stickiness {
        cookie_duration = 86400
        enabled         = false
        type            = "lb_cookie"
    }
}

# module.superset.aws_alb.superset_load_balancer:
resource "aws_alb" "superset_load_balancer" {
    desync_mitigation_mode     = "defensive"
    drop_invalid_header_fields = false
    enable_deletion_protection = false
    enable_http2               = true
    enable_waf_fail_open       = false
    idle_timeout               = 60
    internal                   = false
    ip_address_type            = "ipv4"
    load_balancer_type         = "application"
    name                       = "superset-alb"
    security_groups            = var.security_groups
    subnets                    = var.pub_subnet_ids
    tags                       = var.v_tags
    
    access_logs {
        enabled = false
        bucket = ""
    }

}

# module.superset.aws_lb_listener.listener:
resource "aws_lb_listener" "listener" {
    load_balancer_arn = aws_alb.superset_load_balancer.arn
    port              = 80
    protocol          = "HTTP"
    tags              = {}
    tags_all          = {}

    default_action {
        target_group_arn = aws_lb_target_group.target_group.arn
        type             = "forward"
    }

    depends_on = [
      aws_alb.superset_load_balancer,
      aws_lb_target_group.target_group
    ]
}
# module.superset.aws_ecs_service.superset_server:
# module.superset.aws_ecs_service.superset_server:
resource "aws_ecs_service" "superset_server" {
    cluster                            = aws_ecs_cluster.cluster.arn
    deployment_maximum_percent         = 200
    deployment_minimum_healthy_percent = 100
    desired_count                      = 1
    enable_ecs_managed_tags            = true
    enable_execute_command             = false
    health_check_grace_period_seconds  = 0
    #iam_role                           = "aws-service-role"
    launch_type                        = "FARGATE"
    name                               = "superset_server"
    platform_version                   = "LATEST"
    scheduling_strategy                = "REPLICA"
    tags                               = var.v_tags
    task_definition                    = aws_ecs_task_definition.superset_webserver.arn

    deployment_circuit_breaker {
        enable   = false
        rollback = false
    }

    deployment_controller {
        type = "ECS"
    }

    load_balancer {
        container_name   = "superset"
        container_port   = 8088
        target_group_arn = aws_lb_target_group.target_group.arn
    }

    network_configuration {
        assign_public_ip = false
        security_groups  = [var.securitygroup_id]
        subnets          = var.subnet_ids
    }

    depends_on = [
      aws_ecs_cluster.cluster,
      aws_ecs_task_definition.superset_webserver,
      aws_lb_target_group.target_group
    ]
}
