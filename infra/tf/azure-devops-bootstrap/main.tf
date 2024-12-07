resource "azurerm_resource_group" "medfast_rg" {
  name     = var.resource_group_name
  location = var.location
}

// Create a virtual network
resource "azurerm_virtual_network" "current" {
  name                = "${var.app_name}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.medfast_rg.location
  resource_group_name = azurerm_resource_group.medfast_rg.name
}

// Create a subnet
resource "azurerm_subnet" "current" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.medfast_rg.name
  virtual_network_name = azurerm_virtual_network.current.name
  address_prefixes     = ["10.0.2.0/24"]
}

// Create a public IP
resource "azurerm_public_ip" "current" {
  name                = "${var.app_name}-pub-ip"
  resource_group_name = azurerm_resource_group.medfast_rg.name
  location            = azurerm_resource_group.medfast_rg.location
  allocation_method   = "Static"
}

// Create a network interface
resource "azurerm_network_interface" "current" {
  name                = "${var.app_name}-nic"
  location            = azurerm_resource_group.medfast_rg.location
  resource_group_name = azurerm_resource_group.medfast_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.current.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.current.id
  }
}

// Create a security group
resource "azurerm_network_security_group" "my_terraform_nsg" {
  name                = "${var.app_name}NetworkSecurityGroup"
  location            = azurerm_resource_group.medfast_rg.location
  resource_group_name = azurerm_resource_group.medfast_rg.name

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
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "current" {
  network_interface_id      = azurerm_network_interface.current.id
  network_security_group_id = azurerm_network_security_group.my_terraform_nsg.id
}

// Create a virtual machine
resource "azurerm_linux_virtual_machine" "current" {
  name                = "${var.app_name}-machine"
  resource_group_name = azurerm_resource_group.medfast_rg.name
  location            = azurerm_resource_group.medfast_rg.location
  size                = "Standard_DS1_v2"
  admin_username      = var.vm_username
  network_interface_ids = [
    azurerm_network_interface.current.id,
  ]

  admin_ssh_key {
    username   = var.vm_username
    public_key = file("./keys/vm.pub")
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

  identity {
    type = "SystemAssigned"
  }
}
