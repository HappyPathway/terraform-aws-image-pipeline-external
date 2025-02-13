# Terraform test file for external resources module
provider "aws" {
  region = "us-west-2"
  # Mock provider configuration
  skip_credentials_validation = true
  skip_requesting_account_id = true
  skip_metadata_api_check    = true
  access_key                = "mock_access_key"
  secret_key                = "mock_secret_key"
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
    condition     = aws_s3_bucket.assets_bucket.bucket == "test-assets-bucket"
    error_message = "Assets bucket name does not match expected value"
  }

  assert {
    condition     = aws_s3_bucket.state_bucket.bucket == "test-state-bucket"
    error_message = "State bucket name does not match expected value"
  }

  assert {
    condition     = aws_dynamodb_table.terraform_state_lock.billing_mode == "PAY_PER_REQUEST"
    error_message = "DynamoDB table should use PAY_PER_REQUEST billing mode"
  }

  assert {
    condition     = aws_security_group.pipeline_security_group.vpc_id == "vpc-12345678"
    error_message = "Security group VPC ID does not match expected value"
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
  }

  assert {
    condition     = aws_s3_bucket_versioning.assets_bucket_versioning.versioning_configuration[0].status == "Enabled"
    error_message = "Assets bucket versioning should be enabled"
  }

  assert {
    condition     = aws_s3_bucket_versioning.state_bucket_versioning.versioning_configuration[0].status == "Enabled"
    error_message = "State bucket versioning should be enabled"
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.assets_bucket_access.block_public_acls == true
    error_message = "Assets bucket should block public ACLs"
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.state_bucket_access.block_public_acls == true
    error_message = "State bucket should block public ACLs"
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
    condition     = aws_vpc_security_group_ingress_rule.allow_self_traffic.referenced_security_group_id == aws_security_group.pipeline_security_group.id
    error_message = "Security group should allow self-referential traffic"
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