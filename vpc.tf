data "aws_security_group" "it_linux_base" {
  name = "it-linux-base"
}

data "aws_vpc" "selected" {
  id = var.vpc_config.vpc_id
}

data "aws_subnet" "selected" {
  count = length(var.vpc_config.subnet_ids)
  id    = var.vpc_config.subnet_ids[count.index]
}

locals {
  vpc_config = {
    vpc_id = var.vpc_config.vpc_id
    region = var.vpc_config.region
    security_group_ids = concat(
      [data.aws_security_group.it_linux_base.id],
      var.additional_security_group_ids
    )
    subnets = var.vpc_config.subnet_ids
  }
}

resource "aws_vpc_endpoint" "endpoints" {
  for_each = var.enable_vpc_endpoints ? toset(var.vpc_endpoints) : toset([])
  
  vpc_id             = var.vpc_config.vpc_id
  service_name       = "com.amazonaws.${var.vpc_config.region}.${each.key}"
  vpc_endpoint_type  = "Gateway"
  route_table_ids    = var.route_table_ids

  tags = {
    Name = "s3-vpc-endpoint"
  }
}