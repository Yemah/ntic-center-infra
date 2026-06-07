output "public_ip" {
  value = aws_instance.web_abj.public_ip
}

output "rds_endpoint" {
  value = aws_db_instance.mysql_abj.endpoint
}