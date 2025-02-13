# Main module for external AWS Image Pipeline resources

# Assets S3 bucket for storing artifacts
resource "aws_s3_bucket" "assets_bucket" {
  bucket = var.assets_bucket_name

  tags = {
    Project = var.project_name
  }
}

resource "aws_s3_bucket_versioning" "assets_bucket_versioning" {
  bucket = aws_s3_bucket.assets_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "assets_bucket_encryption" {
  bucket = aws_s3_bucket.assets_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "assets_bucket_access" {
  bucket = aws_s3_bucket.assets_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "assets_bucket_policy" {
  bucket = aws_s3_bucket.assets_bucket.id
  policy = data.aws_iam_policy_document.assets_bucket_policy_document.json
}

data "aws_iam_policy_document" "assets_bucket_policy_document" {
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
      aws_s3_bucket.assets_bucket.arn,
      "${aws_s3_bucket.assets_bucket.arn}/*",
    ]
  }
}

# VPC Endpoints
resource "aws_vpc_endpoint" "endpoints" {
  for_each          = toset(var.vpc_endpoints)
  vpc_id            = var.vpc_config.vpc_id
  service_name      = "com.amazonaws.${var.vpc_config.region}.${each.value}"
  vpc_endpoint_type = "Interface"

  security_group_ids = var.vpc_config.security_group_ids
  subnet_ids         = var.vpc_config.subnets
}

# Security Groups
resource "aws_security_group" "pipeline_security_group" {
  name        = "${var.project_name}-pipeline-security"
  description = "Security group for image pipeline components"
  vpc_id      = var.vpc_config.vpc_id

  tags = {
    Name = "${var.project_name}-pipeline-security"
    Project = var.project_name
  }
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.pipeline_security_group.id
  cidr_ipv4        = "0.0.0.0/0"
  ip_protocol      = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "allow_self_traffic" {
  security_group_id                  = aws_security_group.pipeline_security_group.id
  referenced_security_group_id       = aws_security_group.pipeline_security_group.id
  ip_protocol                       = "-1"
}

# State Backend Configuration
resource "aws_s3_bucket" "state_bucket" {
  bucket = var.state_bucket_name

  tags = merge(
    var.tags,
    {
      Project = var.project_name
    }
  )
}

resource "aws_s3_bucket_public_access_block" "state_bucket_access" {
  bucket = aws_s3_bucket.state_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "state_bucket_versioning" {
  bucket = aws_s3_bucket.state_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "state_bucket_encryption" {
  bucket = aws_s3_bucket.state_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

# Add DynamoDB table for state locking
resource "aws_dynamodb_table" "terraform_state_lock" {
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