# Terraform Testing Instructions

When working with AWS provider in test files, use the following mock configuration to avoid requiring real credentials:

```hcl
provider "aws" {
  region = "us-west-2"
  # Mock provider configuration
  skip_credentials_validation = true
  skip_requesting_account_id = true
  skip_metadata_api_check    = true
  access_key                = "mock_access_key"
  secret_key                = "mock_secret_key"
}
```

This configuration allows tests to run without requiring real AWS credentials while still validating the infrastructure logic.