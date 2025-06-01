resource "aws_ecr_repository" "expenseflow_api" {
  name = "expenseflow-api"
}

resource "docker_image" "expenseflow_api" {
  name = "${aws_ecr_repository.expenseflow_api.repository_url}:latest"
  build {
    context    = "${path.root}/../api"
    dockerfile = "Dockerfile"
    platform   = "linux/amd64"
  }
}


resource "docker_registry_image" "expenseflow_api" {
  name = docker_image.expenseflow_api.name
}

resource "aws_ecs_service" "expenseflow_api" {
  name            = "expenseflow-api"
  cluster         = aws_ecs_cluster.expenseflow.id
  task_definition = aws_ecs_task_definition.expenseflow_api.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = data.aws_subnets.private.ids
    security_groups  = [aws_security_group.expenseflow_api.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.expenseflow_api.arn
    container_name   = "expenseflow-api"
    container_port   = 8080
  }
}

resource "aws_ecs_task_definition" "expenseflow_api" {
  family                   = "expenseflow-api"
  requires_compatibilities = ["FARGATE"]

  network_mode       = "awsvpc"
  cpu                = 1024
  memory             = 2048
  execution_role_arn = data.aws_iam_role.lab.arn
  task_role_arn      = data.aws_iam_role.lab.arn

  container_definitions = jsonencode([
    {
      image       = "${docker_image.expenseflow_api.name}",
      cpu         = 1024,
      memory      = 2048,
      name        = "expenseflow-api",
      networkMode = "awsvpc",
      portMappings = [
        {
          containerPort = 8080,
          hostPort      = 8080
        }
      ],
      environment = [
        {
          name  = "DB_URL",
          value = "postgresql+asyncpg://${local.db_username}:${var.db_password}@${aws_db_instance.expenseflow_db.address}:${aws_db_instance.expenseflow_db.port}/${aws_db_instance.expenseflow_db.db_name}"
        },
        {
          name  = "FRONTEND_URL",
          value = local.ui_url
        },
        {
          name  = "JWT_AUDIENCE",
          value = data.auth0_resource_server.expenseflow_api.identifier
        },
        {
          name  = "AUTH0_DOMAIN",
          value = var.auth0_domain
        },
        {
          name  = "SENTRY_DSN",
          value = var.sentry_dsn
        }
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = "/expenseflow/api",
          awslogs-region        = "us-east-1",
          awslogs-stream-prefix = "ecs",
          awslogs-create-group  = "true"
        }
      }
    }
  ])
}

# Security Group
resource "aws_security_group" "expenseflow_api" {
  name        = "expenseflow-api"
  description = "ExpenseFlow API Security Group"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Scaling
resource "aws_appautoscaling_target" "expenseflow_api" {
  min_capacity       = 1
  max_capacity       = 3
  resource_id        = "service/${aws_ecs_cluster.expenseflow.name}/${aws_ecs_service.expenseflow_api.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "expenseflow_api" {
  name               = "expenseflow-api"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.expenseflow_api.resource_id
  scalable_dimension = aws_appautoscaling_target.expenseflow_api.scalable_dimension
  service_namespace  = aws_appautoscaling_target.expenseflow_api.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value = 50.0
  }
}

# Load Balancer
resource "aws_lb" "expenseflow_api" {
  name               = "expenseflow-api"
  internal           = false
  load_balancer_type = "application"
  subnets            = data.aws_subnets.private.ids
  security_groups    = [aws_security_group.expenseflow_api.id]
}

resource "aws_lb_target_group" "expenseflow_api" {
  name        = "expenseflow-api"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = aws_security_group.expenseflow_api.vpc_id
  target_type = "ip"

  health_check {
    path                = "/health"
    port                = "8080"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 10
  }
}

resource "aws_lb_listener" "expenseflow_api" {
  load_balancer_arn = aws_lb.expenseflow_api.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.expenseflow_api.arn
  }
}


resource "aws_lb_listener" "expenseflow_api_https" {
  load_balancer_arn = aws_lb.expenseflow_api.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "arn:aws:acm:us-east-1:654654409426:certificate/f42ac526-0744-4e99-9cdd-508ca173f310"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.expenseflow_api.arn
  }
}
