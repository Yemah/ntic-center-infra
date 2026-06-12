#output "ip_paris" {
#  value = module.vm_paris.ip
#}

output "ip_abidjan" {
  value = module.web_abidjan.public_ip
}

output "ip_zabbix" {
  value = module.monitoring.ip
}

output "rds_endpoint" {
  value = module.web_abidjan.rds_endpoint
}