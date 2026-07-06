resource "random_password" "db_password" {
  length           = 24
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_db_subnet_group" "rds" {
  name       = "${var.environment}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name        = "${var.environment}-rds-subnet-group"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

resource "aws_security_group" "rds" {
  name        = "${var.environment}-rds-sg"
  description = "Security group for RDS instance"
  vpc_id      = var.vpc_id

  ingress {
    description     = "PostgreSQL from application"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.app_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-rds-sg"
    Environment = var.environment
  }
}

resource "aws_db_instance" "postgres" {
  identifier                = "${var.environment}-webapp-db"
  engine                    = "postgres"
  engine_version            = var.engine_version
  instance_class            = var.instance_class
  allocated_storage         = var.allocated_storage
  max_allocated_storage     = var.max_allocated_storage
  storage_type              = var.storage_type
  storage_encrypted         = var.storage_encrypted
  db_name                   = var.db_name
  username                  = var.db_username
  password                  = var.db_password != null ? var.db_password : random_password.db_password.result
  parameter_group_name      = var.parameter_group_name != null ? var.parameter_group_name : "default.postgres${split(".", var.engine_version)[0]}"
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.environment}-db-final-snapshot"

  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.rds.name

  multi_az                = var.multi_az
  backup_retention_period = var.backup_retention_period
  backup_window           = var.backup_window
  maintenance_window      = var.maintenance_window

  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_retention_period
  auto_minor_version_upgrade            = var.auto_minor_version_upgrade
  deletion_protection                   = var.deletion_protection
  publicly_accessible                   = var.publicly_accessible

  tags = {
    Name        = "${var.environment}-rds"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}
