resource "azurerm_virtual_machine" "main" {
  name                  = var.vm_def.vm_name
  location              = var.vm_def.vm_location
  resource_group_name   = var.vm_def.vm_resource_group_name
  network_interface_ids = ["${azurerm_network_interface.main.id}"]
  vm_size               = var.vm_def.vm_size

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true


  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true


  storage_image_reference {
    publisher = var.vm_def.storage_image_publisher
    offer     = var.vm_def.storage_image_offer
    sku       = var.vm_def.storage_image_sku
    version   = var.vm_def.storage_image_version
  }

  storage_os_disk {
    name              = var.vm_def.storage_disk_name
    caching           = var.vm_def.storage_disk_caching
    create_option     = var.vm_def.sotrage_disk_create_option
    managed_disk_type = var.vm_def.storage_disk_managed_disk_typ
  }
  
  os_profile {
    computer_name  = var.vm_def.os_profile_computer_name
    admin_username = var.vm_def.os_profile_admin_user_name
    admin_password = var.vm_def.os_profile_admin_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  dynamic "storage_data_disk" {
    for_each = [for datadisk in var.vm_def.datadisks: {
         name = datadisk.datadisk_name
         caching = datadisk.datadisk_caching
         create_option = datadisk.datadisk_create_option
         disk_size_gb = datadisk.datadisk_disk_size_gb
         lun = datadisk.datadisk_lun
         # Optional 
         # write_accelerator_enabled = datadisk.datadisk_write_accelerator_enabled
         managed_disk_type = datadisk.datadisk_managed_disk_type 
    }]

    content {
         name = storage_data_disk.value.name
         caching = storage_data_disk.value.caching
         create_option = storage_data_disk.value.create_option
         disk_size_gb = storage_data_disk.value.disk_size_gb
         lun = storage_data_disk.value.lun
         # Optional 
         # write_accelerator_enabled = storage_data_disk.datadisk_write_accelerator_enabled
         managed_disk_type = storage_data_disk.value.managed_disk_type
    }
    
  }

  tags = var.vm_def.vm_tags
  depends_on = [azurerm_network_interface.main]
}
