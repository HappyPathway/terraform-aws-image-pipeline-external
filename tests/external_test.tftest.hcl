# Terraform test file for external resources module
mock_provider "aws" {}

variables {
  project_name = "test-project"
  region = "us-west-2"
  state_bucket_name = "test-state-bucket"
  assets_bucket_name = "test-assets-bucket"
  pipeline_iam_arns = ["arn:aws:iam::123456789012:role/test-role"]
  enable_assets_bucket = true
  enable_state_backend = true
}

# Test basic resource creation
run "basic_resource_creation" {
  command = plan

  # Mock data for testing
  variables {
    project_name      = "test-pipeline"
    state_bucket_name = "test-state-bucket"
    assets_bucket_name = "test-assets-bucket"
    pipeline_iam_arns = ["arn:aws:iam::123456789012:role/test-role"]
    vpc_config = {
      vpc_id            = "vpc-12345678"
      region            = "us-west-2"
      security_group_ids = ["sg-12345678"]
      subnets           = ["subnet-12345678"]
    }
  }

  # Verify resource creation
  assert {
    condition     = aws_s3_bucket.state_bucket[0].bucket == "test-state-bucket"
    error_message = "State bucket should be created with correct name"
  }

  assert {
    condition     = aws_dynamodb_table.terraform_state_lock[0].name == "test-project-terraform-state-lock"
    error_message = "DynamoDB table should be created with correct name"
  }
}

# Test bucket configurations
run "bucket_configurations" {
  command = plan

  variables {
    project_name      = "test-pipeline"
    state_bucket_name = "test-state-bucket"
    assets_bucket_name = "test-assets-bucket"
    pipeline_iam_arns = ["arn:aws:iam::123456789012:role/test-role"]
    vpc_config = {
      vpc_id            = "vpc-12345678"
      region            = "us-west-2"
      security_group_ids = ["sg-12345678"]
      subnets           = ["subnet-12345678"]
    }
    enable_assets_bucket = true
    enable_state_backend = true
  }

  assert {
    condition     = aws_s3_bucket_versioning.assets_bucket_versioning[0].versioning_configuration[0].status == "Enabled"
    error_message = "Assets bucket versioning should be enabled"
  }

  assert {
    condition     = aws_s3_bucket_server_side_encryption_configuration.assets_bucket_encryption[0].rule[0].apply_server_side_encryption_by_default[0].sse_algorithm == "aws:kms"
    error_message = "Assets bucket encryption should be enabled with KMS"
  }
}

run "bucket_policies" {
  command = plan

  variables {
    project_name      = "test-pipeline"
    state_bucket_name = "test-state-bucket"
    assets_bucket_name = "test-assets-bucket"
    pipeline_iam_arns = ["arn:aws:iam::123456789012:role/test-role"]
    vpc_config = {
      vpc_id            = "vpc-12345678"
      region            = "us-west-2"
      security_group_ids = ["sg-12345678"]
      subnets           = ["subnet-12345678"]
    }
    enable_assets_bucket = true
    enable_state_backend = true
  }

  assert {
    condition     = can(aws_s3_bucket_policy.assets_bucket_policy[0].policy)
    error_message = "Assets bucket policy should be created"
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.assets_bucket_access[0].block_public_acls
    error_message = "Public access should be blocked on assets bucket"
  }
}

# Test VPC endpoint creation
run "vpc_endpoint_creation" {
  command = plan

  variables {
    project_name      = "test-pipeline"
    state_bucket_name = "test-state-bucket"
    assets_bucket_name = "test-assets-bucket"
    pipeline_iam_arns = ["arn:aws:iam::123456789012:role/test-role"]
    vpc_config = {
      vpc_id            = "vpc-12345678"
      region            = "us-west-2"
      security_group_ids = ["sg-12345678"]
      subnets           = ["subnet-12345678"]
    }
    vpc_endpoints = ["s3", "codecommit"]
  }

  assert {
    condition     = length(aws_vpc_endpoint.endpoints) == 2
    error_message = "Should create exactly 2 VPC endpoints"
  }

  assert {
    condition     = contains(keys(aws_vpc_endpoint.endpoints), "s3")
    error_message = "Should create S3 VPC endpoint"
  }

  assert {
    condition     = contains(keys(aws_vpc_endpoint.endpoints), "codecommit")
    error_message = "Should create CodeCommit VPC endpoint"
  }
}

# Test security group rules
run "security_group_rules" {
  command = plan

  variables {
    project_name      = "test-pipeline"
    state_bucket_name = "test-state-bucket"
    assets_bucket_name = "test-assets-bucket"
    pipeline_iam_arns = ["arn:aws:iam::123456789012:role/test-role"]
    vpc_config = {
      vpc_id            = "vpc-12345678"
      region            = "us-west-2"
      security_group_ids = ["sg-12345678"]
      subnets           = ["subnet-12345678"]
    }
  }

  assert {
    condition     = aws_vpc_security_group_egress_rule.allow_all_traffic_ipv4.cidr_ipv4 == "0.0.0.0/0"
    error_message = "Security group should allow all outbound IPv4 traffic"
  }

  assert {
    condition     = aws_security_group.pipeline_security_group.vpc_id == "vpc-12345678"
    error_message = "Security group should be created in the specified VPC"
  }
}

# Test custom tags
run "custom_tags" {
  command = plan

  variables {
    project_name      = "test-pipeline"
    state_bucket_name = "test-state-bucket"
    assets_bucket_name = "test-assets-bucket"
    pipeline_iam_arns = ["arn:aws:iam::123456789012:role/test-role"]
    vpc_config = {
      vpc_id            = "vpc-12345678"
      region            = "us-west-2"
      security_group_ids = ["sg-12345678"]
      subnets           = ["subnet-12345678"]
    }
    tags = {
      Environment = "test"
      Owner       = "DevOps"
    }
  }

  assert {
    condition     = contains(keys(aws_s3_bucket.state_bucket.tags), "Environment")
    error_message = "Custom tags should be applied to state bucket"
  }

  assert {
    condition     = contains(keys(aws_dynamodb_table.terraform_state_lock.tags), "Environment")
    error_message = "Custom tags should be applied to DynamoDB table"
  }

  assert {
    condition     = aws_s3_bucket.state_bucket.tags["Project"] == "test-pipeline"
    error_message = "Project tag should be set on state bucket"
  }
}