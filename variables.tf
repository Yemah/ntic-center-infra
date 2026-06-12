variable "vsphere_server" { default = "vcenter.ntic-paris.local" }
variable "vsphere_user"   { default = "administrator@vsphere.local" }
variable "vsphere_password" { sensitive = true }

variable "aws_region"     { default = "eu-west-1" }
#variable "aws_access_key" {}
#variable "aws_secret_key" { sensitive = true }

variable "azure_location" { default = "swedencentral" }
variable "db_password"    { sensitive = true }