data "vsphere_datacenter" "dc" {
  name = var.vsphere_datacenter
}

data "vsphere_datastore" "datastore" {
  name          = var.vsphere_datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = var.vsphere_network
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.vsphere_cluster
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name          = var.vsphere_template
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "web_paris" {
  name             = "web-paris"
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id
  num_cpus         = 1
  memory           = 1024
  guest_id         = data.vsphere_virtual_machine.template.guest_id
  scsi_type        = data.vsphere_virtual_machine.template.scsi_type

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  disk {
    label            = "disk0"
    size             = 20
    thin_provisioned = true
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
      linux_options {
        host_name = "web-paris"
        domain    = "ntic-paris.local"
      }
      network_interface {
        ipv4_address = "192.168.1.60"
        ipv4_netmask = 24
      }
      ipv4_gateway    = "192.168.1.254"
      dns_server_list = ["192.168.1.100"]
    }
  }

  extra_config = {
    "guestinfo.metadata" = base64encode(jsonencode({
      network = {
        version = 2
        ethernets = {
          eth0 = {
            addresses = ["192.168.1.60/24"]
            gateway4  = "192.168.1.254"
          }
        }
      }
    }))
    "guestinfo.metadata.encoding" = "base64"
    "guestinfo.userdata" = base64encode(<<-EOF
      #cloud-config
      users:
        - name: ubuntu
          sudo: ALL=(ALL) NOPASSWD:ALL
          ssh_authorized_keys:
            - ${file("C:\\Users\\womos\\.ssh\\id_rsa.pub")}
      package_update: true
      packages:
        - open-vm-tools
    EOF
    )
    "guestinfo.userdata.encoding" = "base64"
  }
}