resource "azurerm_virtual_network" "basic_tmpl" {
  count = length(var.virtual_networks)
  
  name                = var.virtual_networks[count.index]["name"]
  address_space       = var.virtual_networks[count.index]["address_space"]
  location            = var.virtual_networks[count.index]["location"]
  resource_group_name = var.virtual_networks[count.index]["resource_group_name"]
}
