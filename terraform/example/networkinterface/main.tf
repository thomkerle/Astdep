resource "azurerm_network_interface" "main" {
  count = length (var.network_interfaces)
 
  name                = var.network_interfaces[count.index]["name"]
  location            = var.network_interfaces[count.index]["location"]
  resource_group_name = var.network_interfaces[count.index]["resource_group_name"]

  ip_configuration {
    name                          = var.network_interfaces[count.index]["ip_configuration_name"]
    subnet_id                     = var.network_interfaces[count.index]["ip_configuration_subnet_id"]
    private_ip_address_allocation = var.network_interfaces[count.index]["ip_configuration_private_ip_address_allocation"]
  }
}

