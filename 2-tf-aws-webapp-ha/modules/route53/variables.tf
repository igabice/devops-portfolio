# modules/route53/variables.tf

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "domain_name" {
  description = "Root domain name (e.g., example.com)"
  type        = string
}

variable "subdomain" {
  description = "Subdomain prefix (e.g., app -> app.example.com)"
  type        = string
  default     = "app"
}

variable "alb_dns_name" {
  description = "DNS name of the ALB"
  type        = string
}

variable "alb_zone_id" {
  description = "Hosted zone ID of the ALB"
  type        = string
}

variable "health_check_path" {
  description = "Path for Route53 health check"
  type        = string
  default     = "/health"
}

variable "health_check_port" {
  description = "Port for Route53 health check"
  type        = number
  default     = 80
}

variable "health_check_protocol" {
  description = "Protocol for Route53 health check"
  type        = string
  default     = "HTTP"
}

variable "health_check_failure_threshold" {
  description = "Number of failures before marking unhealthy"
  type        = number
  default     = 3
}

variable "health_check_request_interval" {
  description = "Interval between health checks (seconds)"
  type        = number
  default     = 30
}

variable "ttl" {
  description = "TTL for DNS record"
  type        = number
  default     = 300
}

variable "failover_type" {
  description = "Failover routing type (PRIMARY or SECONDARY)"
  type        = string
  default     = "PRIMARY"
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}