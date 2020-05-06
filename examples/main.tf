
# Splits up the variables in module definition file
resource "null_resource" "splitter" {
   count = length(var.module)-1
   triggers = {
      sublist = jsonencode(var.module[count.index+1])
   }
}

resource "null_resource" "splitter2" {
   count = length(var.module)-1
   triggers = {
      sublist = jsonencode(lookup(var.module[count.index+1],"deploy_target"))
   }
}

resource "null_resource" "keys" {
   count = length(var.module)-1
   triggers = {
      mkeys = join(",", keys(var.module[count.index+1]))
   }
}

locals {
  lbrace = "{"
  rbrace = "}"
  comma = ","
}

data "template_file" "filecontent" {
  count = length(var.module)-1
  template = "echo '$${lbrace}+definition+:$${templateText1},+hasdata+:+$${templateText2}+$${rbrace}' >> ./run/terraform.tfvars.temp"
  vars = {
    templateText1 = "${replace(null_resource.splitter[count.index].triggers.sublist, "\"","+")}"
    templateText2 = "${contains([null_resource.keys[count.index].triggers.mkeys],"data")}"
    lbrace = "${local.lbrace}"
    rbrace = "${local.rbrace}"
  }
  depends_on = [null_resource.splitter]
}


# Creates terraform modules for each resource to create in the module definition 
data "template_file" "resourcetaskcreator" {
  count = length(var.module)-1
  template = "$${templateText}"
  vars = {
    templateText = <<EOT
      locals {
        defs = ${null_resource.splitter[count.index].triggers.sublist}
        hasdatas = ${contains([null_resource.keys[count.index].triggers.mkeys],"data")}
        deploy_target =  ${null_resource.splitter2[count.index].triggers.sublist}
      }

      resource "null_resource" "generatevars" {
        provisioner "local-exec" {
           working_dir = "."
           command = "${data.template_file.filecontent[count.index].rendered}"
           }
      }

      resource "null_resource" "formatvars" {
        provisioner "local-exec" {
           working_dir = "./run"
           command = "sed -e 's/+/\"/g' terraform.tfvars.temp >> terraform.tfvars.json"
           }
           depends_on = [null_resource.generatevars]
      }
   EOT  
  }
  depends_on = [data.template_file.filecontent]
}

# Stores the template for a creation 
resource "local_file" "filecreator" {
  count = length(var.module)-1
  content = "${element(data.template_file.resourcetaskcreator.*.rendered, count.index)}"
  filename = "./analyze/mdr${count.index}/main.tf"
  depends_on = [data.template_file.resourcetaskcreator]
}

resource "null_resource" "movevariables" {
  provisioner "local-exec" {
    working_dir = "."
    command = "cp terraform.tfvars ./analyze/terraform.tfvars"
  }
  depends_on=[local_file.filecreator]
}

resource "null_resource" "terraform-init" {
    provisioner "local-exec" {
      working_dir = "./analyze"
      command = "terraform init"
    }
    depends_on = [null_resource.movevariables]
}

resource "null_resource" "terraform-apply" {
    provisioner "local-exec" {
      working_dir = "./analyze"
      command = "terraform apply -auto-approve"
    }    
    depends_on = [null_resource.terraform-init]
}

# run module creation code
resource "null_resource" "terraform-init-module" {
    count = length(var.module)-1
    provisioner "local-exec" {
      working_dir = "./analyze/mdr${count.index}"
      command = "terraform init"
    }
    depends_on = [null_resource.terraform-apply]
}

resource "null_resource" "terraform-apply-module" {
    count = length(var.module)-1
    provisioner "local-exec" {
      working_dir = "./analyze/mdr${count.index}"
      command = "terraform apply -auto-approve"
    }    
    depends_on = [null_resource.terraform-init-module]
}


# Build control structure

data "template_file" "controlcontent-1" {
  template = "$${templateText}"
  vars = {
     templateText = <<EOT
     
     resource "null_resource" "terraform-init-0" {
        provisioner "local-exec" {
           working_dir = "../mdr0/run"
           command = "terraform init"
        }
     }
    EOT
  }
  depends_on = [null_resource.terraform-apply-module]
}


data "template_file" "controlcontent-2" {
  count = "${length(var.module) == 1 ? 0: length(var.module)-2}"
  template = "$${templateText}"
  vars = {
     templateText = <<EOT

     resource "null_resource" "terraform-init-${count.index+1}" {
        provisioner "local-exec" {
           working_dir = "../mdr${count.index+1}/run"
           command = "terraform init"
        }
        depends_on = [null_resource.terraform-init-${count.index}]
     }
     EOT  
  }
  depends_on = [data.template_file.controlcontent-1]
}


data "template_file" "controlcontent-3" {
  template = "$${templateText}"
  vars = {
     templateText = <<EOT
     
     resource "null_resource" "terraform-apply-0" {
        provisioner "local-exec" {
           working_dir = "../mdr0/run"
           command = "terraform apply -auto-approve"
        }
        depends_on = [null_resource.terraform-init-${length(var.module)-2}]
     }
     EOT
  }
  depends_on = [data.template_file.controlcontent-2]
}

data "template_file" "controlcontent-4" {
  count = "${length(var.module) == 1 ? 0: length(var.module)-2}"
  template = "$${templateText}"
  vars = {
     templateText = <<EOT

     resource "null_resource" "terraform-apply-${count.index+1}" {
        provisioner "local-exec" {
           working_dir = "../mdr${count.index+1}/run"
           command = "terraform apply -auto-approve"
        }
        depends_on = [null_resource.terraform-apply-${count.index}]
     }
     EOT  
  }
  depends_on = [data.template_file.controlcontent-3]
}

resource "local_file" "filecreator-2" {  
  content = "${data.template_file.controlcontent-1.rendered}"
  filename = "./analyze/control/control.tmpl"
  depends_on = [data.template_file.controlcontent-4]
}

resource "null_resource" "merger-1" {
   count = "${length(var.module) == 1 ? 0: length(var.module)-2}" 
   provisioner "local-exec" {
           working_dir = "./analyze/control"
           command = "echo '${data.template_file.controlcontent-2[count.index].rendered}' >> control.tmpl"
   }
   depends_on = [local_file.filecreator-2]
}

resource "null_resource" "merger-2" {
   provisioner "local-exec" {
           working_dir = "./analyze/control"
           command = "echo '${data.template_file.controlcontent-3.rendered}' >> control.tmpl"
   }
   depends_on = [null_resource.merger-1]
}

resource "null_resource" "merger-3" {
   count = "${length(var.module) == 1 ? 0: length(var.module)-2}" 
   provisioner "local-exec" {
           working_dir = "./analyze/control"
           command = "echo '${data.template_file.controlcontent-4[count.index].rendered}' >> control.tmpl"
   }
   depends_on = [null_resource.merger-2]
}

resource "null_resource" "renamer" {
   provisioner "local-exec" {
           working_dir = "./analyze/control"
           command = "mv control.tmpl main.tf"
   }
   depends_on = [null_resource.merger-3]
}

resource "null_resource" "terraform-init-control" {
    provisioner "local-exec" {
      working_dir = "./analyze/control"
      command = "terraform init"
    }
    depends_on = [null_resource.renamer]
}

resource "null_resource" "terraform-apply-control" {
    provisioner "local-exec" {
      working_dir = "./analyze/control"
      command = "terraform apply -auto-approve"
    }    
    depends_on = [null_resource.terraform-init-control]
}
