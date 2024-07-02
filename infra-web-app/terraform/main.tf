terraform {
  required_version = ">=0.12"
  required_providers {
    azapi = {
      source = "azure/azapi"
      version = "~>1.5"
    }
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>3.0"
    }
    random = {
      source = "hashicorp/random"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  features {}


}

resource "azurerm_resource_group" "acme" {
  name     = "acme-resources"
  location = var.location
}

resource "azurerm_virtual_network" "acme_vnet" {
  name                = "acme-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.acme.location
  resource_group_name = azurerm_resource_group.acme.name
}

resource "azurerm_subnet" "acme_subnet" {
  name                 = "acme-subnet"
  resource_group_name  = azurerm_resource_group.acme.name
  virtual_network_name = azurerm_virtual_network.acme_vnet.name
  address_prefixes     = ["10.0.10.0/24"]
}

resource "azurerm_network_security_group" "acme_nsg" {
  name                = "acme-nsg"
  location            = azurerm_resource_group.acme.location
  resource_group_name = azurerm_resource_group.acme.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_public_ip" "acme_ip" {
  count               = var.vm_count
  name                = "acme-ip-${count.index + 1}"
  location            = azurerm_resource_group.acme.location
  resource_group_name = azurerm_resource_group.acme.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "acme_nic" {
  count               = var.vm_count
  name                = "acme-nic-${count.index + 1}"
  location            = azurerm_resource_group.acme.location
  resource_group_name = azurerm_resource_group.acme.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.acme_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.acme_ip[count.index].id
  }
}

resource "azurerm_network_interface_security_group_association" "nic_association" {
  count                     = var.vm_count
  network_interface_id      = azurerm_network_interface.acme_nic[count.index].id
  network_security_group_id = azurerm_network_security_group.acme_nsg.id
}

resource "azurerm_virtual_machine" "acme_vm" {
  count                 = var.vm_count
  name                  = "acmeVM${count.index + 1}"
  location              = azurerm_resource_group.acme.location
  resource_group_name   = azurerm_resource_group.acme.name
  network_interface_ids = [azurerm_network_interface.acme_nic[count.index].id]
  vm_size               = "Standard_DS1_v2"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "osdisk-acmeVM${count.index + 1}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "acmeVM${count.index + 1}"
    admin_username = var.admin_username
    admin_password = var.admin_password
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/acmeadmin/.ssh/authorized_keys"
      key_data = azapi_resource_action.ssh_public_key_gen.output.publicKey
    }
  }
}
