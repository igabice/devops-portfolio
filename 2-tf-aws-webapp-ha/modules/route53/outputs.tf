output "zone_id" {
  description = "ID of the Route53 hosted zone"
  value       = data.aws_route53_zone.domain.zone_id
}

output "record_fqdn" {
  description = "FQDN of the Route53 record"
  value       = aws_route53_record.webapp.fqdn
}

output "health_check_id" {
  description = "ID of the Route53 health check"
  value       = aws_route53_health_check.webapp.id
}
