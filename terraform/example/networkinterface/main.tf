resource "azurerm_network_interface" "main" {
  count = length (var.network_interfaces)
 
  for_each = var.network_interfaces[count.index]
  name                = each.value["name"]
  location            = each.value["location"]
  resource_group_name = each.value["resource_group_name"]

  ip_configuration {
    name                          = each.value["ip_configuration_name"]
    subnet_id                     = each.value["ip_configuration_subnet_id"]
    private_ip_address_allocation = each.value["ip_configuration_private_ip_address_allocation"]
  }
}
