variables {
  project_name = "test-project"
  region = "us-west-2"
  state_bucket_name = "test-state-bucket"
  assets_bucket_name = "test-assets-bucket"
  pipeline_iam_arns = []
  existing_vpc_id = "vpc-12345"
  existing_subnet_ids = ["subnet-12345"]
  existing_security_group_ids = ["sg-12345"]
}

run "test_vpc_endpoint_creation" {
  variables {
    create_vpc_endpoints = true
    enable_vpc_endpoints = true
    vpc_endpoints = ["s3", "ecr.api"]
  }

  plan_options {
    mode = refresh-only
  }

  assert {
    condition     = length(var.vpc_endpoints) == 2
    error_message = "Should configure specified VPC endpoints"
  }

  assert {
    condition     = contains(var.vpc_endpoints, "s3")
    error_message = "S3 endpoint should be included"
  }
}

run "test_vpc_endpoint_lookup" {
  variables {
    create_vpc_endpoints = false
    enable_vpc_endpoints = true
    existing_vpc_endpoint_ids = {
      "s3" = "vpce-12345",
      "ecr.api" = "vpce-67890"
    }
  }

  plan_options {
    mode = refresh-only
  }

  assert {
    condition     = !var.create_vpc_endpoints
    error_message = "Should not create new endpoints when using existing ones"
  }

  assert {
    condition     = length(var.existing_vpc_endpoint_ids) == 2
    error_message = "Should use provided existing endpoint IDs"
  }
}