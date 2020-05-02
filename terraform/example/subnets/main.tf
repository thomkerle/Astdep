resource "azurerm_subnet" "internal" {
  count = length(var.subnets)
   
  for_each = var.subnets[count.index]
  name                 = each.value["name"]
  resource_group_name  = each.value["resource_group_name"]
  virtual_network_name = each.value["virtual_network_name"]
  address_prefix       = each.value["address_prefix"]
}
