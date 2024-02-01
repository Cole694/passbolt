resource "azurerm_resource_group" "rg_passbolt" {
  name     = "rg-passbolt-zan"
  location = "South Africa North"
}

resource "azurerm_virtual_network" "vnet_passbolt" {
  name                = "vnet-passbolt-zan-001"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg_passbolt.location
  resource_group_name = azurerm_resource_group.rg_passbolt.name
}

resource "azurerm_public_ip" "pip_passbolt" {
  name                = "pip-passbolt-001"
  resource_group_name = azurerm_resource_group.rg_passbolt.name
  location            = azurerm_resource_group.rg_passbolt.location
  allocation_method   = "Static"
}

resource "azurerm_subnet" "snet_passbolt" {
  name                 = "snet-001"
  resource_group_name  = azurerm_resource_group.rg_passbolt.name
  virtual_network_name = azurerm_virtual_network.vnet_passbolt.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "nic_passbolt" {
  name                = "nic-passbolt-001"
  location            = azurerm_resource_group.rg_passbolt.location
  resource_group_name = azurerm_resource_group.rg_passbolt.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.snet_passbolt.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.pip_passbolt.id
  }
}

resource "azurerm_linux_virtual_machine" "vm_passbolt" {
  name                = "vm-passbolt-zan-001"
  resource_group_name = azurerm_resource_group.rg_passbolt.name
  location            = azurerm_resource_group.rg_passbolt.location
  size                = "Standard_A1_v2"
  admin_username      = "cole"
  network_interface_ids = [
    azurerm_network_interface.nic_passbolt.id,
  ]

  admin_ssh_key {
    username   = "cole"
    public_key = file("~/.ssh/id_rsa.pub")
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