# Template related stuff

locals {
    templateText= <<EOT
       variable "definition" {
       }
      
       variable "hasdata" {
       }
    EOT  
}


data "template_file" "variablefiletemplate2" {
  count = length(var.module)-1
  template = "${local.templateText}" 
}


resource "local_file" "filecreator_2" {
  count = length(var.module)-1
  content = "${element(data.template_file.variablefiletemplate2.*.rendered, count.index)}"
  filename = "../analyze/mdr${count.index}/run/variables.tf"
}


resource "null_resource" "cattotemplate" {
  count = length(var.module)-1
  provisioner "local-exec" {
    working_dir = "."
    command = "cat ../analyze/templates/creationtmpls.tmpl ../analyze/mdr${count.index}/main.tf  >> ../analyze/mdr${count.index}/temp.txt && mv ../analyze/mdr${count.index}/temp.txt ../analyze/mdr${count.index}/main.tf"
  }
}


