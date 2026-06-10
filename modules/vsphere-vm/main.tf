terraform {
  required_providers {
    vsphere = {
      source  = "vmware/vsphere"
      version = ">= 2.6.1"
    }
  }
}

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

  cdrom {
    client_device = true
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
  }

  extra_config = {
    "guestinfo.metadata" = base64encode(jsonencode({
      "instance-id"    = "web-paris"
      "local-hostname" = "web-paris"
    }))
    "guestinfo.metadata.encoding" = "base64"
    "guestinfo.userdata" = base64encode(<<-EOF
      #cloud-config
      users:
        - name: ubuntu
          sudo: ALL=(ALL) NOPASSWD:ALL
          shell: /bin/bash
          ssh_authorized_keys:
            - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDHUlZbld2mBBToa/1JU96nB+WLgCrch4FmV2/pcbUZHBt12v9OYIpf2vmEe5htcIOPk6e4/NJrI/D/BCuqnJavkX5f02ANppMWRWNMMJpEkn70VvVECS3ajDTskNTlpK1HEdNcrWnD6M44dhrG/vOuLuk/kg3pa1Mj0E5f2bBpL7SaNqrdYBkiLg+fCzKTU0vKal/lk0WbKPPpdf3Q8q/7EeOUUFE0/FBc4ZLKXcJfRsHcf9LbEYg2LIeeZ7LkZuSlSz1hTB6p2k34uomi7Ck1xoPq9A59JX+Ti50l+LLTmLJwFBrRX/pT9UgEBjexCBQyO5HoXV89dEz1i4+2NJLdNAn54qfexowUr97v7MfPOM5IGFC1FOaOK2Zasxyu0Lm3tuIqKwBfvvu56lCeiXOyZtEAKzO0Vm28dkUbghVuNJLdjWbi2fVpDzJpaRsSbRsDz5v/EbHgBXvPrAeQwCBbhIINnneLGEB1NU8e1sp5+e6CH26pM/f/eQGvWcsyVPDdETEYwGxulcLOpdYepGkMEQt7r2S58mA9bKHR1QZFIGBKhIukgBTLPEKpcIrsKir8zIInbid1bidfmnljK7nfWlv+JpyjlpOGm1mbpq4+h+b7Rs+M1j0lIduXDb+rt/NcALJq0ReVYEVRWkQLBH36rhwm9kiJ/5+Bc8oygkZP9Q== ntic-center-lab
      package_update: true
      packages:
        - open-vm-tools
      runcmd:
        - systemctl enable open-vm-tools
        - systemctl start open-vm-tools
    EOF
    )
    "guestinfo.userdata.encoding" = "base64"
  }
}