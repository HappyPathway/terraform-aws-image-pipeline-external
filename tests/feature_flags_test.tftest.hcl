provider "aws" {
  region = "us-west-2"
  # Mock provider configuration
  skip_credentials_validation = true
  skip_requesting_account_id = true
  skip_metadata_api_check    = true
  access_key                = "mock_access_key"
  secret_key                = "mock_secret_key"
}

variables {
  project_name = "test-project"
  assets_bucket_name = "test-assets-bucket"
  state_bucket_name = "test-state-bucket"
  pipeline_iam_arns = ["arn:aws:iam::123456789012:role/test-role"]
  vpc_config = {
    vpc_id = "vpc-12345"
    region = "us-west-2"
    security_group_ids = ["sg-12345"]
    subnets = ["subnet-12345"]
  }
  vpc_endpoints = ["s3", "ecr.api"]
  tags = {
    Environment = "test"
  }
}

# Test all features enabled
run "all_features_enabled" {
  variables {
    enable_assets_bucket = true
    enable_vpc_endpoints = true
    enable_security_groups = true
    enable_state_backend = true
  }

  assert {
    condition = aws_s3_bucket.assets_bucket[0].bucket == "test-assets-bucket"
    error_message = "Assets bucket not created correctly"
  }

  assert {
    condition = length(aws_vpc_endpoint.endpoints) == 2
    error_message = "VPC endpoints not created correctly"
  }

  assert {
    condition = aws_security_group.pipeline_security_group[0].name == "test-project-pipeline-security"
    error_message = "Security group not created correctly"
  }

  assert {
    condition = aws_s3_bucket.state_bucket[0].bucket == "test-state-bucket"
    error_message = "State bucket not created correctly"
  }
}

# Test all features disabled
run "all_features_disabled" {
  variables {
    enable_assets_bucket = false
    enable_vpc_endpoints = false
    enable_security_groups = false
    enable_state_backend = false
  }

  assert {
    condition = length(aws_s3_bucket.assets_bucket) == 0
    error_message = "Assets bucket should not exist"
  }

  assert {
    condition = length(aws_vpc_endpoint.endpoints) == 0
    error_message = "VPC endpoints should not exist"
  }

  assert {
    condition = length(aws_security_group.pipeline_security_group) == 0
    error_message = "Security group should not exist"
  }

  assert {
    condition = length(aws_s3_bucket.state_bucket) == 0
    error_message = "State bucket should not exist"
  }
}