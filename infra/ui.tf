resource "aws_ecr_repository" "expenseflow_ui" {
  name = "expenseflow-ui"
}

resource "docker_image" "expenseflow_ui" {
  name = "${aws_ecr_repository.expenseflow_ui.repository_url}:latest"
  build {
    dockerfile = "Dockerfile"
    context    = "${path.root}/../ui"
    platform   = "linux/amd64"
  }
}

resource "docker_registry_image" "expenseflow_ui" {
  name = docker_image.expenseflow_ui.name
}

resource "aws_ecs_service" "expenseflow_ui" {
  name            = "expenseflow-ui"
  cluster         = aws_ecs_cluster.expenseflow.id
  task_definition = aws_ecs_task_definition.expenseflow_ui.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = data.aws_subnets.private.ids
    security_groups  = [aws_security_group.expenseflow_ui.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.expenseflow_ui.arn
    container_name   = "expenseflow-ui"
    container_port   = 3000
  }
}

resource "aws_ecs_task_definition" "expenseflow_ui" {
  family                   = "expenseflow-ui"
  requires_compatibilities = ["FARGATE"]

  network_mode       = "awsvpc"
  cpu                = 1024
  memory             = 2048
  execution_role_arn = data.aws_iam_role.lab.arn
  task_role_arn      = data.aws_iam_role.lab.arn

  container_definitions = jsonencode([
    {
      image       = "${docker_image.expenseflow_ui.name}",
      cpu         = 1024,
      memory      = 2048,
      name        = "expenseflow-ui",
      networkMode = "awsvpc",
      readonlyRootFilesystem = true,

      portMappings = [
        {
          containerPort = 3000,
          hostPort      = 3000
        }
      ],
      environment = [
        {
          name  = "BACKEND_BASE_URL",
          value = local.api_url
        },
        {
          name  = "AUTH0_DOMAIN",
          value = var.auth0_domain
        },
        {
          name  = "AUTH0_CLIENT_ID",
          value = data.auth0_client.expenseflow_ui_client.client_id
        },
        {
          name  = "JWT_AUDIENCE",
          value = data.auth0_resource_server.expenseflow_api.identifier
        },
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = "/expenseflow/ui",
          awslogs-region        = "us-east-1",
          awslogs-stream-prefix = "ecs",
          awslogs-create-group  = "true"
        }
      }
    }
  ])
}


# Security Group
resource "aws_security_group" "expenseflow_ui" {
  name        = "expenseflow-ui"
  description = "Expenseflow UI Security Group"

  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.expenseflow_alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# Load Balancer
resource "aws_lb" "expenseflow_ui" {
  name               = "expenseflow-ui"
  internal           = false
  load_balancer_type = "application"
  subnets            = data.aws_subnets.private.ids
  security_groups    = [aws_security_group.expenseflow_alb.id]
}

resource "aws_lb_target_group" "expenseflow_ui" {
  name        = "expenseflow-ui"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = aws_security_group.expenseflow_ui.vpc_id
  target_type = "ip"

  health_check {
    path                = "/health"
    port                = "3000"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 10
  }
}

resource "aws_lb_listener" "expenseflow_ui_https" {
  load_balancer_arn = aws_lb.expenseflow_ui.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.expenseflow.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.expenseflow_ui.arn
  }
}

resource "aws_lb_listener" "expenseflow_ui_http" {
  load_balancer_arn = aws_lb.expenseflow_ui.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
