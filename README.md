[![Terraform Validation](https://github.com/HappyPathway/terraform-aws-image-pipeline-external/actions/workflows/terraform.yaml/badge.svg)](https://github.com/HappyPathway/terraform-aws-image-pipeline-external/actions/workflows/terraform.yaml)


[![Terraform Doc](https://github.com/HappyPathway/terraform-aws-image-pipeline-external/actions/workflows/terraform-doc.yaml/badge.svg)](https://github.com/HappyPathway/terraform-aws-image-pipeline-external/actions/workflows/terraform-doc.yaml)

[![Terraform Test](https://github.com/HappyPathway/terraform-aws-image-pipeline-external/actions/workflows/terraform-test.yaml/badge.svg)](https://github.com/HappyPathway/terraform-aws-image-pipeline-external/actions/workflows/terraform-test.yaml)

# Terraform AWS Image Pipeline External Module

[![Test Coverage](https://img.shields.io/badge/dynamic/json?url=https://raw.githubusercontent.com/HappyPathway/terraform-aws-image-pipeline-external/main/coverage-badge.json&label=test%20coverage&query=$.coverage&color=brightgreen)](https://github.com/HappyPathway/terraform-aws-image-pipeline-external/actions/workflows/terraform-test.yaml)

This Terraform module manages external resources required for the AWS Image Pipeline that are not part of the core pipeline module. This includes shared infrastructure components like S3 buckets, VPC endpoints, and security groups.

## Features

- Assets S3 bucket for storing pipeline artifacts with versioning and encryption
- State backend S3 bucket configuration with versioning and encryption
- DynamoDB table for Terraform state locking
- VPC endpoints for AWS services
- Security group for pipeline components
- Public access blocking for all S3 buckets

## Usage

```hcl
module "image_pipeline_external" {
  source = "git::https://github.com/your-org/terraform-aws-image-pipeline-external.git"

  project_name      = "my-image-pipeline"
  assets_bucket_name = "my-pipeline-assets"
  state_bucket_name = "my-pipeline-state"
  
  pipeline_iam_arns = [
    "arn:aws:iam::123456789012:role/pipeline-role"
  ]

  vpc_config = {
    vpc_id             = "vpc-12345678"
    region             = "us-west-2"
    security_group_ids = ["sg-12345678"]
    subnets           = ["subnet-12345678"]
  }

  tags = {
    Environment = "production"
  }
}
```

## Security Features

- S3 bucket versioning enabled for both assets and state buckets
- Server-side encryption using AWS KMS for all S3 buckets
- Public access blocking enabled for all S3 buckets
- State locking using DynamoDB to prevent concurrent modifications
- IAM-based access control for the assets bucket
- VPC endpoints for secure AWS service access
- Security group with minimal required access

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0.0 |
| aws | >= 4.20.1 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 4.20.1 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project_name | Name of the project to be used as prefix for resources | `string` | n/a | yes |
| assets_bucket_name | Name of the S3 bucket for storing pipeline artifacts | `string` | `"image-pipeline-assets"` | no |
| state_bucket_name | Name of the S3 bucket for storing terraform state | `string` | n/a | yes |
| pipeline_iam_arns | List of IAM ARNs that need access to the assets bucket | `list(string)` | n/a | yes |
| vpc_config | VPC configuration for the pipeline resources | <pre>object({<br>  vpc_id = string<br>  region = string<br>  security_group_ids = list(string)<br>  subnets = list(string)<br>})</pre> | n/a | yes |
| vpc_endpoints | List of VPC endpoints to create | `list(string)` | See variables.tf | no |
| tags | Additional tags to apply to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| assets_bucket | The assets S3 bucket object containing id, arn and bucket name |
| state_bucket | The state backend S3 bucket object containing id, arn and bucket name |
| state_lock_table | The DynamoDB table used for state locking |
| security_group_id | ID of the pipeline security group |
| vpc_endpoints | Map of created VPC endpoints |

## Notes

- The assets bucket is created with a bucket policy that allows access from the provided IAM ARNs
- VPC endpoints are created for common AWS services needed by the pipeline
- All resources are tagged with the project name and any additional tags provided
- DynamoDB table uses on-demand capacity by default for cost optimization
- State locking is automatically handled by Terraform when using the DynamoDB table

<!-- BEGIN_TF_DOCS -->
{{ .Content }}
<!-- END_TF_DOCS -->