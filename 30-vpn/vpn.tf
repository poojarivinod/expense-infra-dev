resource "aws_key_pair" "openvpnas" { #aws key pair terraform
  key_name   = "openvpnas"
  public_key = file("c://Users//Admin//Downloads//devops//openvpnas.pub") # file function in terraform(it will read the content in file) # give path like this manner, otherwise we get the error
}

resource "aws_instance" "openvpn" {                       #terraform aws ec2
  ami                    = data.aws_ami.openvpn.id # this is our devops-practice AMI id
  key_name = aws_key_pair.openvpnas.key_name
  vpc_security_group_ids = [data.aws_ssm_parameter.vpn_sg_id.value]
  instance_type          = "t3.micro"
  subnet_id   = local.public_subnet_id  # if we won't give the subnet id, it will take default subnet id 
  user_data = file("user-data.sh") # After creation of ec2-instanse, it load the content of user-data.sh file #ec2 instanse terraform -->terraform registry
  tags = merge(
    var.common_tags,
    {
        Name = "${var.project_name}-${var.environment}-vpn"
    }
  )
}

# it will gather public ip of openvpn
output "vpn_ip" {
   value = aws_instance.openvpn.public_ip
}
