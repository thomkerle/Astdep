resource "azurerm_resource_group" "test" {
  count = length (var.resource_groups)
  for_each = var.resource_groups[count.index]
  name     = each.value["name"]
  location = each.value["location"]
}
