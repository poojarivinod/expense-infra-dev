resource "aws_instance" "backend" {                       #terraform aws ec2
  ami                    = data.aws_ami.joindevops.id # this is our devops-practice AMI id
  vpc_security_group_ids = [data.aws_ssm_parameter.backend_sg_id.value]
  instance_type          = "t3.micro"
  subnet_id   = local.private_subnet_id  # if we won't give the subnet id, it will take default subnet id 
  tags = merge(
    var.common_tags,
    {
        Name = local.resource_name
    }
  )
}

resource "null_resource" "backend" { # null resource in terraform --> terraform registry
  # Changes to instance  requires re-provisioning
  triggers = {
    instance_ids = aws_instance.backend.id
  }

  # Bootstrap script can run on any instance of the cluster
  # So we just choose the first in this case
  connection {
    host = aws_instance.backend.private_ip
    type     = "ssh"
    user     = "ec2-user"
    password = "DevOps321"
  }

   # Copies the backend.sh file to /etc/backend.sh
  provisioner "file" { # copy script from terraform to ec2 --> File Provisioner terraform
    source      = "backend.sh"
    destination = "/tmp/backend.sh"
  }

  provisioner "remote-exec" { # it run in the backend server
    # Bootstrap script called with private_ip of each node in the cluster
    inline = [
      "chmod +x /tmp/backend.sh", # it provides execute permission
      "sudo sh /tmp/backend.sh ${var.environment}" # execution of /tmp/backend.sh
    ]
  }
}

resource "aws_ec2_instance_state" "backend" { #terraform stop ec2 instance --> stack overflow
  instance_id = aws_instance.backend.id
  state       = "stopped"
  depends_on  = [null_resource.backend] #terraform executes all resources at a time, so,  this commond tells terraform that this resourse depends on null resouse. so, this will execute after null resourse
}

resource "aws_ami_from_instance" "backend" { #aws ami from instance terraform --> terraform registry
  name               = local.resource_name
  source_instance_id = aws_instance.backend.id
  depends_on  = [aws_ec2_instance_state.backend] # this resource will run after instanse is completly stoped
}

resource "null_resource" "backend-delete" { # we don't have resource to delete ec2 instanse, so we are using null_resource.
  provisioner "local-exec" { # it will execute aws command in the local laptop
    command =  "aws ec2 terminate-instances --instance-ids ${aws_instance.backend.id}" #aws command line delete instance --> stack overflow 
  }

  depends_on = [aws_ami_from_instance.backend] # it is executed after "aws ami is created".
}