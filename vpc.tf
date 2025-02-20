locals {
  # Combined variables for portability
  _vpc_config = {
    vpc_id             = local.vpc_id
    region             = var.region
    security_group_ids = local.security_group_ids
    subnets           = local.subnet_ids
  }
}