resource "azurerm_resource_group" "iso-demo" {
  name = "iso-resources"
  location = "West Europe"
}

resource "azurerm_virtual_network" "iso-network" {
  name = "iso-network"
  address_space = [ "10.0.0.0/16" ]
  location = azurerm_resource_group.iso-demo.location
  resource_group_name = azurerm_resource_group.iso-demo.name
}

resource "azurerm_subnet" "iso-subnet" {
  name = "iso-internal-subnet"
  resource_group_name = azurerm_resource_group.iso-demo.name
  virtual_network_name = azurerm_resource_group.iso-demo.location
  address_prefixes = [ "10.0.2.0/24" ]
}

resource "azurerm_network_interface" "iso-nic" {
  name = "iso-nic"
  location = azurerm_resource_group.iso-demo.location
  resource_group_name = azurerm_resource_group.iso-demo.name

  ip_configuration {
    name = "iso-internal-subnet"
    subnet_id = azurerm_subnet.iso-subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "iso-server" {
  name = "iso-server"
  resource_group_name = azurerm_resource_group.iso-demo.name
  location = azurerm_resource_group.iso-demo.location
  size = "Standard_D2ads_v5"
  admin_username = "kula"
  admin_password = "kula"
  disable_password_authentication = false
  network_interface_ids = [ 
      azurerm_network_interface.iso-nic.id
   ]

   source_image_reference {
     publisher = "Debian"
     offer = "Debian"
     sku = "11"
     version = "lastest"
   }

   os_disk {
     storage_account_type = "Standard_LRS"
     caching = "ReadWrite"
   }
}