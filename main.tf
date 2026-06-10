# Module VMware désactivé pour Terraform Cloud
# (vCenter local non accessible depuis internet)
module "vm_paris" {
  source = "./modules/vsphere-vm"
}

#module "web_abidjan" {
#  source      = "./modules/aws-ec2"
#  db_password = var.db_password
#}

#module "monitoring" {
#  source         = "./modules/azure-monitoring"
#  azure_location = var.azure_location
#}
