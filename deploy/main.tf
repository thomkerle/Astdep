# Splits up the variables in module definition file
resource "null_resource" "splitter" {
   count = length(var.module)
   triggers = {
      sublist = jsonencode(var.module[count.index])
   }
}

# Creates terraform modules for each resource to create in the module definition 
data "template_file" "resourcetaskcreator" {
  count = length(var.module)-1
  
  template = "$${templateText}"
  vars = {
    templateText = <<EOT
      module "create-resource-${count.index}" {
        source = "../analyze/mdr${count.index}/run"
        definiton = local.definition
      }
      
      locals {
        definition = ${null_resource.splitter[count.index+1].triggers.sublist}
      }
   EOT  
  }
  depends_on = ["null_resource.splitter"]
}

# Stores the template for a creation 
resource "local_file" "filecreator" {
  count = length(var.module)-1
  
  content = "${element(data.template_file.resourcetaskcreator.*.rendered, count.index)}"
  filename = "../analyze/mdr${count.index}/main.tf"
  depends_on = ["data.template_file.resourcetaskcreator"]
}

