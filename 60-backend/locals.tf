locals {
    private_subnet_id = split(",", data.aws_ssm_parameter.private_subnet_id.value)[0]
    resource_name = "${var.project_name}-${var.environment}-backend"
} # it will convert terraform string into list , from that list of value we take first public subnet id 