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
  region = "us-west-2"
  state_bucket_name = "test-state-bucket"
  assets_bucket_name = "test-assets-bucket"
  pipeline_iam_arns = []
  existing_vpc_id = "vpc-12345"
  existing_security_group_ids = ["sg-12345"]
  existing_subnet_ids = ["subnet-12345"]
}

# Test all features enabled
run "all_features_enabled" {
  variables {
    enable_assets_bucket = true
    enable_vpc_endpoints = true
    enable_security_groups = true
    enable_state_backend = true
  }

  plan_options {
    mode = refresh-only
  }

  assert {
    condition     = length(aws_s3_bucket.assets_bucket) > 0
    error_message = "Assets bucket should be created when enabled"
  }

  assert {
    condition     = length(aws_s3_bucket.state_bucket) > 0
    error_message = "State bucket should be created when enabled"
  }

  assert {
    condition     = length(aws_dynamodb_table.terraform_state_lock) > 0
    error_message = "DynamoDB table should be created when enabled"
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

  plan_options {
    mode = refresh-only
  }

  assert {
    condition     = length(aws_s3_bucket.assets_bucket) == 0
    error_message = "Assets bucket should not be created when disabled"
  }

  assert {
    condition     = length(aws_s3_bucket.state_bucket) == 0
    error_message = "State bucket should not be created when disabled"
  }

  assert {
    condition     = length(aws_dynamodb_table.terraform_state_lock) == 0
    error_message = "DynamoDB table should not be created when disabled"
  }
}