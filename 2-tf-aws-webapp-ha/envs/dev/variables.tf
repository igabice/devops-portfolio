variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
}

variable "domain_name" {
  description = "Root domain name (e.g., example.com)"
  type        = string
  default     = null
}

variable "subdomain" {
  description = "Subdomain prefix (e.g., app for app.example.com)"
  type        = string
  default     = "app"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets (one per AZ)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets (one per AZ)"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
}

variable "availability_zones" {
  description = "Availability zones to deploy resources"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "instance_type" {
  description = "EC2 instance type for web servers"
  type        = string
  default     = "t3.micro"
}

variable "min_instances" {
  description = "Minimum number of EC2 instances in ASG"
  type        = number
  default     = 2
}

variable "max_instances" {
  description = "Maximum number of EC2 instances in ASG"
  type        = number
  default     = 4
}

variable "desired_instances" {
  description = "Desired number of EC2 instances in ASG"
  type        = number
  default     = 2
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "Name of the database"
  type        = string
  default     = "webappdb"
}

variable "db_username" {
  description = "Database master username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database master password"
  type        = string
  sensitive   = true
  validation {
    condition     = length(var.db_password) >= 16
    error_message = "Database password must be at least 16 characters."
  }
}

variable "s3_bucket_name" {
  description = "Name suffix for S3 static assets bucket"
  type        = string
  default     = "static-assets"
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    Project    = "tf-aws-webapp-ha"
    ManagedBy  = "terraform"
    Department = "DevSecOps"
  }
}