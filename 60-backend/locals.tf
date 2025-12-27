locals {
    private_subnet_id = split(",", data.aws_ssm_parameter.private_subnet_id.value)[0]
    private_subnet_ids = split(",", data.aws_ssm_parameter.private_subnet_id.value)
    resource_name = "${var.project_name}-${var.environment}-backend"
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    backend_sg_id = data.aws_ssm_parameter.backend_sg_id.value
    app_alb_listener_arn = data.aws_ssm_parameter.app_alb_listener_arn.value
} # it will convert terraform string into list , from that list of value we take first public subnet id 