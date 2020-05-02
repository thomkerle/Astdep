# Splits up the variables in module definition file
resource "null_resource" "splitter" {
   count = length(var.module)-1
   triggers = {
      sublist = jsonencode(var.module[count.index+1])
   }
}

data "template_file" "variablefiletemplate" {
  count = length(var.module)-1
  template = "$${templateText}"
  vars = {
    templateText = <<EOT
       variables "definition" {
          type = map
       }
    EOT  
  }
  depends_on = ["null_resource.splitter"]
}

resource "local_file" "filecreator_1" {
  count = length(var.module)-1
  content = "${element(data.template_file.variablefiletemplate.*.rendered, count.index)}"
  filename = "../analyze/mdr${count.index}/variables.tf"
  depends_on = ["data.template_file.variablefiletemplate"]
}

resource "local_file" "filecreator_2" {
  count = length(var.module)-1
  content = "${element(data.template_file.variablefiletemplate.*.rendered, count.index)}"
  filename = "../analyze/mdr${count.index}/run/variables.tf"
  depends_on = ["local_file.filecreator_1"]
}

resource "null_resource" "cattotemplate" {
  count = length(var.module)-1
  provisioner "local-exec" {
    working_dir = "."
    command = "cat ../analyze/templates/creationtmpls.templ ../analyze/mdr${count.index}/main.tf"
  }
  depends_on=["local_file.filecreator_2"]
}

resource "null_resource" "terraform-init" {
    count = length(var.module)-1
    provisioner "local-exec" {
      working_dir = "../analyze/mdr{count.index}"
      command = "terraform init"
    }
    depends_on = ["null_resource.catotemplate"]
}

resource "null_resource" "terraform-apply" {
    count = length(var.module)-1
    provisioner "local-exec" {
      working_dir = "../analyze/mdr{count.index}"
      command = "terraform apply -auto-approve"
    }    
    depends_on = ["null_resource.terraform-init"]
}

