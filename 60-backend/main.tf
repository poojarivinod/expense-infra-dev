resource "aws_instance" "backend" {                       #terraform aws ec2
  ami                    = data.aws_ami.joindevops.id # this is our devops-practice AMI id
  vpc_security_group_ids = [local.backend_sg_id] #backend security group id
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

# this resource created for stopping the instance
resource "aws_ec2_instance_state" "backend" { #terraform stop ec2 instance --> stack overflow
  instance_id = aws_instance.backend.id
  state       = "stopped"
  depends_on  = [null_resource.backend] #terraform executes all resources at a time, so,  this commond tells terraform that this resourse depends on null resouse. so, this will execute after null resourse
}

# this resource created for creating AMI
resource "aws_ami_from_instance" "backend" { #aws ami from instance terraform --> terraform registry
  name               = local.resource_name
  source_instance_id = aws_instance.backend.id
  depends_on  = [aws_ec2_instance_state.backend] # this resource will run after instanse is completly stoped
}

# this is for deleting the old instance
resource "null_resource" "backend-delete" { # we don't have resource to delete ec2 instanse, so we are using null_resource.
    triggers = {
      instance_id = aws_instance.backend.id # it will trigger to terminate the instanse, if we won't give the trigger then instanse just stops it won't terminate 
    }
  
  provisioner "local-exec" { # it will execute aws command in the local laptop
    command =  "aws ec2 terminate-instances --instance-ids ${aws_instance.backend.id}" #aws command line delete instance --> stack overflow 
  }
    depends_on = [aws_ami_from_instance.backend] # it is executed after "aws ami is created".
}

#this resourse is creation for target group
resource "aws_lb_target_group" "backend" { #aws target group terraform --> terraform registry
  name     = local.resource_name
  port     = 8080
  protocol = "HTTP"
  vpc_id   = local.vpc_id
  health_check {
    healthy_threshold = 2 # Number of consecutive health check successes required before considering a target healthy.
    unhealthy_threshold = 2 #  Number of consecutive health check failures required before considering a target unhealthy.
    timeout = 5 #Amount of time, in seconds, during which no response from a target means a failed health check. 
    protocol = "HTTP"
    port = 8080
    path = "/health"
    matcher = "200-299" # success code
    interval = 10 #Approximate amount of time, in seconds, between health checks of an individual target. 
  }
}

# this resource  is creation for launch template 
resource "aws_launch_template" "backend" { #aws launch template terraform --> terraform registry
  name = local.resource_name
  image_id = aws_ami_from_instance.backend.id
  instance_initiated_shutdown_behavior = "terminate" # when downscale the number of instances, then automatically terminate the instances
  instance_type = "t3.micro"
  vpc_security_group_ids = [local.backend_sg_id]
  update_default_version = true # it will take given (what we wrote in this) version automatically
  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = local.resource_name
    }
  }
}

#this resource is for creating autoscaling
resource "aws_autoscaling_group" "backend" { # aws auto scaling group terraform --> terraform registry
  name                      = local.resource_name
  max_size                  = 10
  min_size                  = 2
  health_check_grace_period = 60 #health check of instance will happen after 60sec of its creation
  health_check_type         = "ELB" # load balancer do the health check
  desired_capacity          = 2 # present 2 instances
  target_group_arns      =  [aws_lb_target_group.backend.arn] #set means list
  launch_template {
    id      = aws_launch_template.backend.id
    version = "$Latest"
  }
  vpc_zone_identifier       = local.private_subnet_ids
  
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50 # minimum 50% of the instance should be healthy
    }
    triggers = ["launch_template"] #change in ami, makes changes in launch template, then it triggers autoscalling group --> it wiil delete old instances and create new instances
  }
  
  tag {
    key                 = "Name"
    value               = local.resource_name
    propagate_at_launch = true
  }

  timeouts {
    delete = "5m" # instance is created , if it is not ready to run by 5m, then it is automatically delete the instance
  }

  tag {
    key                 = "project"
    value               = "expense"
    propagate_at_launch = false
  }

   tag {
    key                 = "Environment"
    value               = "dev"
    propagate_at_launch = false
  }
}

# this resource is for creation listener rule
resource "aws_lb_listener_rule" "backend" { # aws_lb_listener_rule terraform --> --> terraform registry
  listener_arn = local.app_alb_listener_ern
  priority     = 10

  action {
    type             = "forward" # action is forwarding to backend target group
    target_group_arn = aws_lb_target_group.backend.arn
  }

  condition {
    host_header {
      values = ["backend.app-${var.environment}.${var.domain_name}"]
    }
  }
}