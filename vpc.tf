data "aws_security_group" "it_linux_base" {
  name = "it-linux-base"
}

data "aws_vpc" "selected" {
  id = var.vpc_id
}

data "aws_subnet" "selected" {
  count = length(var.subnet_ids)
  id    = var.subnet_ids[count.index]
}

locals {
  vpc_config = {
    vpc_id = var.vpc_id
    region = var.region
    security_group_ids = concat(
      [data.aws_security_group.it_linux_base.id],
      var.additional_security_group_ids
    )
    subnets = var.subnet_ids
  }
}

resource "aws_vpc_endpoint" "endpoints" {
  count = var.enable_vpc_endpoints ? 1 : 0
  
  vpc_id             = var.vpc_id
  service_name       = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type  = "Gateway"
  route_table_ids    = var.route_table_ids

  tags = {
    Name = "s3-vpc-endpoint"
  }
}