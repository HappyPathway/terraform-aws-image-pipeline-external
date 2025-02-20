# Main module for external AWS Image Pipeline resources

# Assets S3 bucket resources
resource "aws_s3_bucket" "assets_bucket" {
  count  = var.enable_assets_bucket ? 1 : 0
  bucket = var.assets_bucket_name
  tags   = merge(var.tags, {
    Project = var.project_name
  })
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

# State Backend Resources
resource "aws_s3_bucket" "state_bucket" {
  count  = var.enable_state_backend ? 1 : 0
  bucket = var.state_bucket_name
  tags   = merge(var.tags, {
    Project = var.project_name
  })
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
  count          = var.enable_state_backend ? 1 : 0
  name           = "${var.project_name}-terraform-state-lock"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = merge(var.tags, {
    Project = var.project_name
  })
}