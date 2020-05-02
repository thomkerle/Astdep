resource "azurerm_virtual_machine" "main" {
  count = length(var.virtual_machines)
  
  for_each = var.virtual_machines[count.index]
  
  name                  = each.value["name"]
  location              = each.value["location"]
  resource_group_name   = each.value["resource_group_name"]
  network_interface_ids = each.value[""]
  vm_size               = each.value["vm_size"]

  storage_image_reference {
    publisher = each.value["storage_image_reference_publisher"]
    offer     = each.value["storage_image_reference_offer"]
    sku       = each.value["storage_image_reference_sku"]
    version   = each.value["storage_image_reference_version"]
  }

  storage_os_disk {
    name              = each.value["storage_os_disk_name"]
    caching           = each.value["storage_os_disk_caching"]
    create_option     = each.value["storage_os_disk_create_option"]
    managed_disk_type = each.value["storage_os_disk_managed_disk_type"]
  }
  
  os_profile {
    computer_name  = each.value["os_profile_computer_name"]
    admin_username = each.value["os_profile_admin_username"]
    admin_password = each.value["os_profile_admin_password"]
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  dynamic "storage_data_disk" {
    for_each = [for datadisk in each.value["datadisks"]: {
         name = datadisk.name
         caching = datadisk.caching
         create_option = datadisk.create_option
         disk_size_gb = datadisk.disk_size_gb
         lun = datadisk.lun
         # Optional 
         # write_accelerator_enabled = datadisk.datadisk_write_accelerator_enabled
         managed_disk_type = datadisk.managed_disk_type 
    }]

    content {
         name = storage_data_disk.value.name
         caching = storage_data_disk.value.caching
         create_option = storage_data_disk.value.create_option
         disk_size_gb = storage_data_disk.value.disk_size_gb
         lun = storage_data_disk.value.lun
         managed_disk_type = storage_data_disk.value.managed_disk_type
    }
  }

  tags = each.value["tags"]
}
