resource "aws_instance" "backend" {                       #terraform aws ec2
  ami                    = data.aws_ami.joindevops.id # this is our devops-practice AMI id
  vpc_security_group_ids = [data.aws_ssm_parameter.backend_sg_id.value]
  instance_type          = "t3.micro"
  subnet_id   = local.private_subnet_id  # if we won't give the subnet id, it will take default subnet id 
  tags = merge(
    var.common_tags,
    {
        Name = "${var.project_name}-${var.environment}-backend"
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

  provisioner "remote-exec" {
    # Bootstrap script called with private_ip of each node in the cluster
    inline = [
      "chmod +x /tmp/backend.sh", # it provides execute permission
      "sudo sh /tmp/backend.sh ${var.environment}" # execution of /tmp/backend.sh
    ]
  }
}