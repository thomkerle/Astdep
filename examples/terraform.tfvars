module = [
    {
        name = "mymodule_1"
        purpose = "Provisioning of two Ubuntu VMs"
        description = "A text that describes the module"
    },
    {
        deploy_target = "resourcegroups"

        definitions = [
            {
                name = "rsg_number_1"
                location = "westeurope"
            },
            {
                name = "rsg_number_2"
                location = "westeurope"
            }
        ]
    },
    {
        deploy_target = "virtualnetworks"

        definitions = [
            {
                name = "myvnet"
                address_space = ["10.0.0.0/16"]
                location ="westeurope"
                resourcegroup_name ="rsg_number_1"
            }
        ]
    },
    {
        deploy_target = "subnets"

        definitions = [
            {
                name = "mysubnetname"
                resourcegroup_name = "rsg_number_1"
                virtualnetwork_name = "myvnet"
                address_prefix = "10.0.2.0/24"
            }
        ]
    },
    {
        deploy_target = "network_interfaces"

        datas = [
            {
                template = "azurerm_subnet"
                template_name = "test"
                parameters = {
                    name = "mysubnetname"
                    virtual_network_name = "myvnet"
                    resource_group_name = "rsg_number_1"
                }
            }   
        ]
        definitions = [
            {
                name = "interface1"
                location = "westeurope"
                resourcegroup_name = "rsg_number_1"
                ip_configuration_name = "myipConfig"
                ip_configuration_subnet_id = "data.azurerm_subnet.test.id"
                ip_configuration_private_ip_address_allocation = "Dynamic"
            }
        ]
    },
    {
        deploy_target = "virtual_machines"

        definitions = [
            {
                name = "myvm1"
                resourcegroup_name = "rsg_number_1"
                size = "Standard_DS1_v2"
                storage_image_publisher = "Canonical"
                storage_image_offer = "UbuntuServer"
                storage_image_sku = "16.04-LTS"
                storage_image_version = "latest"
                storage_disk_name = "MYVM-osdisk"
                storage_disk_caching = "ReadWrite"
                storage_disk_create_option = "FromImage"
                storage_disk_managed_disk_typ = "Standard_LRS"

                os_profile_computer_name = "MYVM"
                os_profile_admin_user_name ="testadmin"
                os_profile_admin_password = "Password!1234"
                tags = {
                    "key1" = "value1"
                    "key2" = "value2"
                }
                datadisks = [
                    {
                        datadisk_name ="MYVM-datadisk1"
                        datadisk_caching = "ReadWrite"
                        datadisk_create_option = "Empty"
                        datadisk_disk_size_gb = "20"
                        datadisk_lun = "0"
                        datadisk_managed_disk_type ="Standard_LRS"
                    },
                    {
                        datadisk_name ="MYVM-datadisk2"
                        datadisk_caching = "ReadWrite"
                        datadisk_create_option = "Empty"
                        datadisk_disk_size_gb = "15"
                        datadisk_lun = "1"
                        datadisk_managed_disk_type ="Standard_LRS"
                    }
                 ]
    
                vm_virtual_network_name = "myvnet"
                vm_virtual_network_resource_group_name ="rsg_number_1"
                vm_subnet_name ="mysubnetname"
                vm_subnet_resource_group_name = "rsg_number_1"
                vm_network_interface_name ="interface1"
                vm_network_interface_resource_group_name = "test"
                vm_ip_configuration_name ="myipConfig"
            }
        ]
    }
]
