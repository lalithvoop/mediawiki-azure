provider "azurerm" {
  features {}
}

variable "prefix" {
    default = "thoughtworks"
}

resource "azurerm_resource_group" "tw-rg" {
  name = "${var.prefix}-rg"
  location = "eastus"
}

resource "azurerm_virtual_network" "tw-vnet" {
  name = "${var.prefix}-tw-vnet"
  address_space = [var.vnet-address-space]
  resource_group_name = azurerm_resource_group.tw-rg.name
  location = azurerm_resource_group.tw-rg.location
}

resource "azurerm_subnet" "tw-subnet" {
  name = "${var.prefix}-tw-subnet"
  address_prefixes = [var.subnet-address-space]
  virtual_network_name = azurerm_virtual_network.tw-vnet.name
  resource_group_name = azurerm_resource_group.tw-rg.name
}

resource "azurerm_network_security_group" "nsg" {
  depends_on=[azurerm_virtual_network.tw-vnet]
  name = "${var.prefix}-nsg"
  location = azurerm_resource_group.tw-rg.location
  resource_group_name = azurerm_resource_group.tw-rg.name
  security_rule {
    name                       = "AllowHTTP"
    description                = "Allow HTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "Internet"
    destination_address_prefix = "VirtualNetwork"
  }
  security_rule {
    name                       = "AllowSSH"
    description                = "Allow SSH"
    priority                   = 150
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "Internet"
    destination_address_prefix = "VirtualNetwork"
  }
}


resource "azurerm_subnet_network_security_group_association" "tw-nsg-association" {
  depends_on=[azurerm_resource_group.tw-rg]
  subnet_id                 = azurerm_subnet.tw-subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}


resource "azurerm_public_ip" "pip" {
  depends_on=[azurerm_resource_group.tw-rg]
  name                = "${var.prefix}-pip"
  location = azurerm_resource_group.tw-rg.location
  resource_group_name = azurerm_resource_group.tw-rg.name
  allocation_method   = "Static"
}


resource "azurerm_network_interface" "tw-nic" {
  depends_on=[azurerm_resource_group.tw-rg]
  name                = "${var.prefix}-tw-nic"
  location = azurerm_resource_group.tw-rg.location
  resource_group_name = azurerm_resource_group.tw-rg.name
  
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.tw-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

resource "azurerm_network_interface_security_group_association" "tw-nsg-nic-association" {
  network_interface_id      = azurerm_network_interface.tw-nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}