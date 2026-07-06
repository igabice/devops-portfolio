terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }

  backend "s3" {
    bucket       = "tf-aws-webapp-ha-state"
    key          = "dev/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true

    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_requesting_account_id  = true
    use_path_style              = true
  }
}

# ── VPC ──────────────────────────────────────────────────────────────────────

module "vpc" {
  source = "../../modules/vpc"

  environment = var.environment
  vpc_cidr    = var.vpc_cidr

  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones

  enable_nat_gateway = false
  single_nat_gateway = true

  tags = var.tags
}

# ── S3 (static assets) ───────────────────────────────────────────────────────

module "s3" {
  source = "../../modules/s3"

  environment = var.environment
  bucket_name = var.s3_bucket_name
  tags        = var.tags
}

# ── ALB ──────────────────────────────────────────────────────────────────────

module "alb" {
  source = "../../modules/alb"

  environment       = var.environment
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  tags              = var.tags
}

# ── Application security group (breaks circular dependency between ASG and RDS) ──

resource "aws_security_group" "app" {
  name        = "${var.environment}-app-sg"
  description = "Security group for web application instances"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [module.alb.alb_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.environment}-app-sg"
  })
}

# ── RDS ──────────────────────────────────────────────────────────────────────

module "rds" {
  source = "../../modules/rds"

  environment           = var.environment
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnet_ids
  app_security_group_id = aws_security_group.app.id

  db_name     = var.db_name
  db_username = var.db_username
  db_password = var.db_password

  instance_class = var.db_instance_class
  multi_az       = false

  skip_final_snapshot = true
  deletion_protection = false

  tags = var.tags
}

# ── ASG ──────────────────────────────────────────────────────────────────────

module "asg" {
  source = "../../modules/asg"

  environment            = var.environment
  vpc_id                 = module.vpc.vpc_id
  private_subnet_ids     = module.vpc.private_subnet_ids
  app_security_group_ids = [aws_security_group.app.id]

  instance_type    = var.instance_type
  min_size         = var.min_instances
  max_size         = var.max_instances
  desired_capacity = var.desired_instances

  target_group_arn     = module.alb.target_group_arn
  rds_address          = module.rds.rds_address
  rds_port             = "5432"
  static_assets_bucket = module.s3.bucket_id

  tags = var.tags
}

# ── Route53 (optional, requires domain_name to be set) ───────────────────────

module "route53" {
  count  = var.domain_name != null ? 1 : 0
  source = "../../modules/route53"

  environment  = var.environment
  domain_name  = var.domain_name
  subdomain    = var.subdomain
  alb_dns_name = module.alb.alb_dns_name
  alb_zone_id  = module.alb.alb_zone_id
  tags         = var.tags
}
