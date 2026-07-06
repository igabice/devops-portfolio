output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnet_ids
}

output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = module.alb.alb_dns_name
}

output "rds_address" {
  description = "Address of the RDS instance"
  value       = module.rds.rds_address
}

output "rds_endpoint" {
  description = "Endpoint of the RDS instance"
  value       = module.rds.rds_endpoint
}

output "bucket_id" {
  description = "ID of the S3 static assets bucket"
  value       = module.s3.bucket_id
}

output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = module.asg.autoscaling_group_name
}

output "route53_record" {
  description = "FQDN of the Route53 record (if domain_name was set)"
  value       = var.domain_name != null ? module.route53[0].record_fqdn : null
}
