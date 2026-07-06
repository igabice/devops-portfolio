output "rds_id" {
  description = "ID of the RDS instance"
  value       = aws_db_instance.postgres.id
}

output "rds_address" {
  description = "Address of the RDS instance"
  value       = aws_db_instance.postgres.address
}

output "rds_port" {
  description = "Port of the RDS instance"
  value       = aws_db_instance.postgres.port
}

output "rds_endpoint" {
  description = "Endpoint of the RDS instance"
  value       = aws_db_instance.postgres.endpoint
}

output "db_name" {
  description = "Database name"
  value       = aws_db_instance.postgres.db_name
}

output "db_username" {
  description = "Database master username"
  value       = aws_db_instance.postgres.username
}

output "db_security_group_id" {
  description = "ID of the RDS security group"
  value       = aws_security_group.rds.id
}
