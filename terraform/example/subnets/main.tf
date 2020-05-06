resource "azurerm_subnet" "internal" {
  count = length(var.subnets)
   
  name                 = var.subnets[count.index]["name"]
  resource_group_name  = var.subnets[count.index]["resource_group_name"]
  virtual_network_name = var.subnets[count.index]["virtual_network_name"]
  address_prefix       = var.subnets[count.index]["address_prefix"]
}

