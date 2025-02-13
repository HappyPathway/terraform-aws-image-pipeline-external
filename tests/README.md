# Terraform Module Tests

This directory contains tests for the terraform-aws-image-pipeline-external module using Terraform's native testing framework.

## Running the Tests

To run all tests:
```bash
terraform test
```

To run a specific test:
```bash
terraform test -run="bucket_configurations"
```

## Parallel Test Execution

The tests are configured to run in parallel using GitHub Actions. Each test case runs independently:

- basic_resource_creation
- bucket_configurations
- vpc_endpoint_creation
- security_group_rules
- custom_tags

### Coverage Reports

Each test generates its own coverage report that can be found in GitHub Actions artifacts:
- Individual coverage reports: `test-coverage-<test_case>`
- Aggregated summary: `test-coverage-summary`

### Running Parallel Tests Locally

To run a specific test case locally:
```bash
terraform test -test-directory="tests" -filter="<test_case>"
```

Example:
```bash
terraform test -test-directory="tests" -filter="bucket_configurations"
```

## Test Cases

### basic_resource_creation
Tests the basic creation of all resources:
- Assets S3 bucket
- State S3 bucket
- DynamoDB table
- Security group
- Basic tag verification

### bucket_configurations
Verifies S3 bucket security configurations:
- Versioning enabled
- Public access blocking
- Server-side encryption
- Bucket policies

### vpc_endpoint_creation
Tests VPC endpoint creation:
- Correct number of endpoints created
- Proper endpoint types
- VPC configuration

### security_group_rules
Validates security group configuration:
- Outbound rules
- Self-referential rules
- VPC assignment

### custom_tags
Tests custom tag application:
- Tag inheritance
- Project tag presence
- Custom tag application across resources

## Mock Data

The tests use mock data with placeholder values:
- VPC ID: vpc-12345678
- Subnet ID: subnet-12345678
- Security Group ID: sg-12345678
- IAM Role ARN: arn:aws:iam::123456789012:role/test-role

## Notes

- Tests use the `plan` command to validate configurations without actually creating resources
- Provider is configured to skip validations for testing purposes
- Tests can be extended to use localstack if actual resource creation testing is needed
- Test cases run in parallel to speed up execution
- Each test case generates its own coverage report
- Results are aggregated after all tests complete
- Tests continue to run even if one test fails (fail-fast disabled)