# modules/asg/variables.tf

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for EC2 instances"
  type        = list(string)
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "Custom AMI ID (optional, uses latest Amazon Linux 2 if not specified)"
  type        = string
  default     = null
}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
  default     = null
}

variable "min_size" {
  description = "Minimum instances in ASG"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum instances in ASG"
  type        = number
  default     = 4
}

variable "desired_capacity" {
  description = "Desired instances in ASG"
  type        = number
  default     = 2
}

variable "target_group_arn" {
  description = "ARN of the ALB target group"
  type        = string
}

variable "rds_address" {
  description = "RDS endpoint address (injected via user_data)"
  type        = string
  default     = ""
}

variable "rds_port" {
  description = "RDS port"
  type        = string
  default     = "5432"
}

variable "s3_bucket" {
  description = "S3 bucket name for static assets (injected via user_data)"
  type        = string
  default     = ""
}

variable "app_security_group_ids" {
  description = "Additional security group IDs to attach to instances"
  type        = list(string)
  default     = []
}

variable "user_data_template" {
  description = "Path to user_data template file"
  type        = string
  default     = null
}

variable "scaling_cpu_threshold" {
  description = "CPU threshold for scaling policy (%)"
  type        = number
  default     = 70
}

variable "scaling_cpu_evaluation_periods" {
  description = "Number of evaluation periods for CPU scaling"
  type        = number
  default     = 2
}

variable "root_volume_size" {
  description = "Root EBS volume size in GB"
  type        = number
  default     = 20
}

variable "root_volume_type" {
  description = "Root EBS volume type"
  type        = string
  default     = "gp3"
}

variable "enable_monitoring" {
  description = "Enable detailed CloudWatch monitoring"
  type        = bool
  default     = true
}

variable "termination_policies" {
  description = "ASG termination policies"
  type        = list(string)
  default     = ["Default"]
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}

variable "static_assets_bucket" {
  description = "S3 bucket name for static assets"
  type        = string
  default     = ""
}