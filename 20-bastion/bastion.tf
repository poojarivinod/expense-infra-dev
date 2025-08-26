resource "aws_instance" "bastion" {                       #terraform aws ec2
  ami                    = data.aws_ami.joindevops.id # this is our devops-practice AMI id
  vpc_security_group_ids = [data.aws_ssm_parameter.bastion_sg_id.value]
  instance_type          = "t3.micro"
  subnet_id   = local.public_subnet_id  # if we won't give the subnet id, it will take default subnet id 
  tags = merge(
    var.common_tags,
    {
        Name = "${var.project_name}-${var.environment}-bastion"
    }
  )
}
