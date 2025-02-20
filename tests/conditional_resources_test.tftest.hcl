provider "aws" {
  region                      = "us-west-2"
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
  access_key                  = "mock_access_key"
  secret_key                  = "mock_secret_key"
}

variables {
  project_name = "test-project"
  region = "us-west-2"
  state_bucket_name = "test-state-bucket"
  assets_bucket_name = "test-assets-bucket"
  existing_vpc_id = "vpc-12345"
  existing_security_group_ids = ["sg-12345"]
  existing_subnet_ids = ["subnet-12345"]
  enable_vpc_endpoints = true
  enable_security_groups = true
  create_vpc = false
  create_security_groups = false
  create_subnets = false
  create_vpc_endpoints = false
  existing_vpc_endpoint_ids = {
    "s3" = "vpce-12345"
  }
}

run "test_lookup_existing_resources" {
  plan_options {
    mode = refresh-only
  }

  assert {
    condition     = local.vpc_id == "vpc-12345"
    error_message = "VPC ID should match existing VPC"
  }

  assert {
    condition     = length(local.security_group_ids) == 1
    error_message = "Should use existing security groups"
  }
}

run "test_create_new_resources" {
  variables {
    create_vpc = true
    create_security_groups = true
    create_subnets = true
    create_vpc_endpoints = true
    vpc_cidr = "10.0.0.0/16"
    availability_zones = ["us-west-2a", "us-west-2b"]
    vpc_endpoints = ["s3", "ecr.api"]
  }

  assert {
    condition     = length(local.security_group_ids) > 0
    error_message = "Should create security groups"
  }

  assert {
    condition     = length(local.subnet_ids) == 2
    error_message = "Should create subnets in specified AZs"
  }

  assert {
    condition     = length(aws_vpc_endpoint.endpoints) == 2
    error_message = "Should create specified VPC endpoints"
  }
}

run "test_feature_flags" {
  variables {
    project_name = "test-project"
    region = "us-west-2"
    enable_assets_bucket = true
    enable_state_backend = true
    state_bucket_name = "test-state-bucket"
    assets_bucket_name = "test-assets-bucket"
  }

  assert {
    condition     = aws_s3_bucket.assets_bucket[0].bucket == "test-assets-bucket"
    error_message = "Assets bucket should be created when enabled"
  }

  assert {
    condition     = aws_s3_bucket.state_bucket[0].bucket == "test-state-bucket"
    error_message = "State bucket should be created when enabled"
  }

  assert {
    condition     = aws_dynamodb_table.terraform_state_lock[0].name == "test-project-terraform-state-lock"
    error_message = "DynamoDB table should be created for state locking"
  }
}