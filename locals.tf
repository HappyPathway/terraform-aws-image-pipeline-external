locals {
  # Resource identification
  vpc_id = var.create_vpc ? aws_vpc.main[0].id : data.aws_vpc.existing[0].id
  security_group_ids = var.create_security_groups ? [aws_security_group.pipeline[0].id] : var.existing_security_group_ids
  subnet_ids = var.create_subnets ? aws_subnet.main[*].id : var.existing_subnet_ids
  
  # VPC endpoint handling
  vpc_endpoint_ids = var.create_vpc_endpoints ? { 
    for endpoint in aws_vpc_endpoint.endpoints : 
    split(".", endpoint.service_name)[2] => endpoint.id 
  } : var.existing_vpc_endpoint_ids

  # Combined VPC configuration for use in other modules
  vpc_config = {
    vpc_id             = local.vpc_id
    region             = var.region
    security_group_ids = local.security_group_ids
    subnets           = local.subnet_ids
  }
}