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