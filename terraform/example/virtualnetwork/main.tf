resource "azurerm_virtual_network" "basic_tmpl" {
  count = length(var.virtual_networks)
  
  for_each = var.virtual_networks[count.index]
  name                = each.value["name"]
  address_space       = each.value["address_space"]
  location            = each.value["location"]
  resource_group_name = each.value["resource_group_name"]
}
