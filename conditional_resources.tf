# Data sources for lookups
data "aws_vpc" "existing" {
  count = var.create_vpc ? 0 : 1
  id    = var.existing_vpc_id

  # Mock values for testing
  lifecycle {
    postcondition {
      condition     = self.id == var.existing_vpc_id
      error_message = "Mock VPC data source validation"
    }
  }
}

# Resources for creation
resource "aws_vpc" "main" {
  count = var.create_vpc ? 1 : 0
  
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.tags, {
    Name = "${var.project_name}-vpc"
  })
}

resource "aws_security_group" "pipeline" {
  count = var.create_security_groups ? 1 : 0

  name_prefix = "${var.project_name}-pipeline-"
  vpc_id      = local.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-pipeline"
  })
}

resource "aws_subnet" "main" {
  count             = var.create_subnets ? length(var.availability_zones) : 0
  vpc_id            = local.vpc_id
  cidr_block        = cidrsubnet(var.vpc_cidr, 4, count.index)
  availability_zone = var.availability_zones[count.index]

  tags = merge(var.tags, {
    Name = "${var.project_name}-subnet-${count.index + 1}"
  })
}

# VPC endpoints with conditional creation
resource "aws_vpc_endpoint" "endpoints" {
  count               = var.enable_vpc_endpoints && var.create_vpc_endpoints ? length(var.vpc_endpoints) : 0
  vpc_id              = local.vpc_id
  service_name        = "com.amazonaws.${var.region}.${var.vpc_endpoints[count.index]}"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = local.subnet_ids
  security_group_ids  = local.security_group_ids

  tags = var.tags

  # Mock values for testing
  lifecycle {
    postcondition {
      condition     = contains(var.vpc_endpoints, split(".", self.service_name)[3])
      error_message = "VPC endpoint service validation"
    }
  }
}

# Data source for existing VPC endpoints
data "aws_vpc_endpoint" "existing" {
  for_each = var.create_vpc_endpoints ? {} : var.existing_vpc_endpoint_ids
  id       = each.value

  # Mock values for testing
  lifecycle {
    postcondition {
      condition     = self.id == each.value
      error_message = "Mock VPC endpoint data source validation"
    }
  }
}