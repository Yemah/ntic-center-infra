resource "azurerm_resource_group" "rg" {
  name     = var.resource_group
  location = var.azure_location
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-monitoring"
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "subnet-monitoring"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.1.1.0/24"]
}

resource "azurerm_public_ip" "pip" {
  name                = "pip-zabbix"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"    # ← Changé de "Basic" à "Standard"
}

resource "azurerm_network_interface" "nic" {
  name                = "nic-zabbix"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

resource "azurerm_linux_virtual_machine" "zabbix" {
  name                = "zabbix-monitor"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B1ms"
  admin_username      = "ansible"
  network_interface_ids = [azurerm_network_interface.nic.id]

  admin_ssh_key {
    username   = "ansible"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDHUlZbld2mBBToa/1JU96nB+WLgCrch4FmV2/pcbUZHBt12v9OYIpf2vmEe5htcIOPk6e4/NJrI/D/BCuqnJavkX5f02ANppMWRWNMMJpEkn70VvVECS3ajDTskNTlpK1HEdNcrWnD6M44dhrG/vOuLuk/kg3pa1Mj0E5f2bBpL7SaNqrdYBkiLg+fCzKTU0vKal/lk0WbKPPpdf3Q8q/7EeOUUFE0/FBc4ZLKXcJfRsHcf9LbEYg2LIeeZ7LkZuSlSz1hTB6p2k34uomi7Ck1xoPq9A59JX+Ti50l+LLTmLJwFBrRX/pT9UgEBjexCBQyO5HoXV89dEz1i4+2NJLdNAn54qfexowUr97v7MfPOM5IGFC1FOaOK2Zasxyu0Lm3tuIqKwBfvvu56lCeiXOyZtEAKzO0Vm28dkUbghVuNJLdjWbi2fVpDzJpaRsSbRsDz5v/EbHgBXvPrAeQwCBbhIINnneLGEB1NU8e1sp5+e6CH26pM/f/eQGvWcsyVPDdETEYwGxulcLOpdYepGkMEQt7r2S58mA9bKHR1QZFIGBKhIukgBTLPEKpcIrsKir8zIInbid1bidfmnljK7nfWlv+JpyjlpOGm1mbpq4+h+b7Rs+M1j0lIduXDb+rt/NcALJq0ReVYEVRWkQLBH36rhwm9kiJ/5+Bc8oygkZP9Q== ntic-center-lab"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}