
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
                resource_group_name ="rsg_number_1"
            }
        ]
    },
    {
        deploy_target = "subnets"

        definitions = [
            {
                name = "mysubnetname"
                resource_group_name = "rsg_number_1"
                virtual_network_name = "myvnet"
                address_prefix = "10.0.2.0/24"
            }
        ]
    }
]
