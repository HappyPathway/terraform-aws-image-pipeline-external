# Main module for external AWS Image Pipeline resources

# Assets S3 bucket resources
resource "aws_s3_bucket" "assets_bucket" {
  count  = var.enable_assets_bucket ? 1 : 0
  bucket = var.assets_bucket_name

  tags = {
    Project = var.project_name
  }
}

resource "aws_s3_bucket_versioning" "assets_bucket_versioning" {
  count  = var.enable_assets_bucket ? 1 : 0
  bucket = aws_s3_bucket.assets_bucket[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "assets_bucket_encryption" {
  count  = var.enable_assets_bucket ? 1 : 0
  bucket = aws_s3_bucket.assets_bucket[0].id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "assets_bucket_access" {
  count  = var.enable_assets_bucket ? 1 : 0
  bucket = aws_s3_bucket.assets_bucket[0].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "assets_bucket_policy" {
  count  = var.enable_assets_bucket ? 1 : 0
  bucket = aws_s3_bucket.assets_bucket[0].id
  policy = data.aws_iam_policy_document.assets_bucket_policy_document[0].json
}

data "aws_iam_policy_document" "assets_bucket_policy_document" {
  count  = var.enable_assets_bucket ? 1 : 0
  statement {
    principals {
      type = "AWS"
      identifiers = var.pipeline_iam_arns
    }

    actions = [
      "s3:Get*",
      "s3:List*",
      "s3:ReplicateObject",
      "s3:PutObject",
      "s3:RestoreObject",
      "s3:PutObjectVersionTagging",
      "s3:PutObjectTagging",
      "s3:PutObjectAcl"
    ]

    resources = [
      aws_s3_bucket.assets_bucket[0].arn,
      "${aws_s3_bucket.assets_bucket[0].arn}/*",
    ]
  }
}

# VPC Endpoints
resource "aws_vpc_endpoint" "endpoint" {
  for_each          = var.enable_vpc_endpoints ? toset(var.vpc_endpoints) : []
  vpc_id            = var.vpc_config.vpc_id
  service_name      = "com.amazonaws.${var.vpc_config.region}.${each.value}"
  vpc_endpoint_type = "Interface"

  security_group_ids = var.vpc_config.security_group_ids
  subnet_ids         = var.vpc_config.subnets
}

# Security Groups
resource "aws_security_group" "pipeline_security_group" {
  count       = var.enable_security_groups ? 1 : 0
  name        = "${var.project_name}-pipeline-security"
  description = "Security group for image pipeline components"
  vpc_id      = var.vpc_config.vpc_id

  tags = {
    Name    = "${var.project_name}-pipeline-security"
    Project = var.project_name
  }
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  count             = var.enable_security_groups ? 1 : 0
  security_group_id = aws_security_group.pipeline_security_group[0].id
  cidr_ipv4        = "0.0.0.0/0"
  ip_protocol      = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "allow_self_traffic" {
  count                             = var.enable_security_groups ? 1 : 0
  security_group_id                 = aws_security_group.pipeline_security_group[0].id
  referenced_security_group_id      = aws_security_group.pipeline_security_group[0].id
  ip_protocol                      = "-1"
}

# State Backend Resources
resource "aws_s3_bucket" "state_bucket" {
  count  = var.enable_state_backend ? 1 : 0
  bucket = var.state_bucket_name

  tags = merge(
    var.tags,
    {
      Project = var.project_name
    }
  )
}

resource "aws_s3_bucket_public_access_block" "state_bucket_access" {
  count  = var.enable_state_backend ? 1 : 0
  bucket = aws_s3_bucket.state_bucket[0].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "state_bucket_versioning" {
  count  = var.enable_state_backend ? 1 : 0
  bucket = aws_s3_bucket.state_bucket[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "state_bucket_encryption" {
  count  = var.enable_state_backend ? 1 : 0
  bucket = aws_s3_bucket.state_bucket[0].id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

resource "aws_dynamodb_table" "terraform_state_lock" {
  count        = var.enable_state_backend ? 1 : 0
  name         = "${var.project_name}-terraform-state-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = merge(
    var.tags,
    {
      Project = var.project_name
    }
  )
}

resource "aws_iam_role" "build_user_role" {
  count = var.enable_build_user ? 1 : 0
  name = "${var.project_name}-build-user-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "build_user_policy" {
  count = var.enable_build_user ? 1 : 0
  name = "${var.project_name}-build-user-policy"
  role = aws_iam_role.build_user_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:Get*",
          "s3:List*",
          "s3:ReplicateObject",
          "s3:PutObject",
          "s3:RestoreObject",
          "s3:PutObjectVersionTagging",
          "s3:PutObjectTagging",
          "s3:PutObjectAcl"
        ]
        Resource = [
          aws_s3_bucket.assets_bucket[0].arn,
          "${aws_s3_bucket.assets_bucket[0].arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_instance_profile" "build_user_instance_profile" {
  count = var.enable_build_user ? 1 : 0
  name = "${var.project_name}-instance-profile"
  role = aws_iam_role.build_user_role[0].name
}