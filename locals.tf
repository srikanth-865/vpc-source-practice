locals {
    common_tags = {
    project = var.project
    environment = var.environment
    Name = local.common_name
    }
    az_names = slice(data.aws_availability_zones.available.names,0,2)
    common_name = "${var.project}-${var.environment}"
}