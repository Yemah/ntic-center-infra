terraform {
  required_providers {
    vsphere = {
      source  = "vmware/vsphere"
      version = "2.6.1"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "5.0.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.88.0"
    }
  }
}

provider "vsphere" {
  user                 = var.vsphere_user
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = true
}

provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

provider "azurerm" {
  features {}
  skip_provider_registration = true
}