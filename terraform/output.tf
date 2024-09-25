output "vm_public_id" {
  value       = aws_instance.loomi_ec2_instance.public_ip
  description = "Public ip of public instance: "
}

output "DatabaseName" {
  value       = aws_db_instance.loomi_rds.db_name
  description = "The Database Name: "
}

output "DatabaseUserName" {
  value       = aws_db_instance.loomi_rds.username
  description = "The Database Name: "
}

output "DBConnectionString" {
  value       = aws_db_instance.loomi_rds.endpoint
  description = "The Database connection String: "
}
