resource "aws_db_instance" "expenseflow_db" {
  identifier             = "expenseflow-db"
  allocated_storage      = 20
  max_allocated_storage  = 1000
  engine                 = "postgres"
  engine_version         = "17"
  instance_class         = "db.t4g.micro"
  db_name                = "expenseflow"
  username               = local.db_username
  password               = var.db_password
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.expenseflow_db.id]
  publicly_accessible    = true
}

resource "aws_security_group" "expenseflow_db" {
  name        = "expenseflow-db"
  description = "Allow inbound Postgres traffic"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_secretsmanager_secret" "db_secret" {
  name = "db-secret"
}

resource "aws_secretsmanager_secret_version" "db_secret" {
  secret_id     = aws_secretsmanager_secret.db_secret.id
  secret_string = var.db_password
}
