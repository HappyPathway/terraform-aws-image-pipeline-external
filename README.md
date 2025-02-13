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
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.20.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.86.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_dynamodb_table.terraform_state_lock](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table) | resource |
| [aws_s3_bucket.assets_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.state_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_policy.assets_bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.assets_bucket_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_public_access_block.state_bucket_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.assets_bucket_encryption](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.state_bucket_encryption](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.assets_bucket_versioning](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_s3_bucket_versioning.state_bucket_versioning](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_security_group.pipeline_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpc_endpoint.endpoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_security_group_egress_rule.allow_all_traffic_ipv4](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.allow_self_traffic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_iam_policy_document.assets_bucket_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_security_group.it_linux_base](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/security_group) | data source |
| [aws_subnet.selected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_vpc.selected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_security_group_ids"></a> [additional\_security\_group\_ids](#input\_additional\_security\_group\_ids) | Additional security group IDs to be added to the VPC configuration | `list(string)` | `[]` | no |
| <a name="input_assets_bucket_name"></a> [assets\_bucket\_name](#input\_assets\_bucket\_name) | Name of the S3 bucket for storing pipeline artifacts | `string` | `"image-pipeline-assets"` | no |
| <a name="input_enable_assets_bucket"></a> [enable\_assets\_bucket](#input\_enable\_assets\_bucket) | Flag to enable/disable the assets S3 bucket and related resources | `bool` | `true` | no |
| <a name="input_enable_security_groups"></a> [enable\_security\_groups](#input\_enable\_security\_groups) | Flag to enable/disable security group resources | `bool` | `true` | no |
| <a name="input_enable_state_backend"></a> [enable\_state\_backend](#input\_enable\_state\_backend) | Flag to enable/disable state backend resources (S3 bucket and DynamoDB) | `bool` | `true` | no |
| <a name="input_enable_vpc_endpoints"></a> [enable\_vpc\_endpoints](#input\_enable\_vpc\_endpoints) | Flag to enable/disable VPC endpoint resources | `bool` | `true` | no |
| <a name="input_pipeline_iam_arns"></a> [pipeline\_iam\_arns](#input\_pipeline\_iam\_arns) | List of IAM ARNs that need access to the assets bucket | `list(string)` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Name of the project to be used as prefix for resources | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The AWS region where resources will be created | `string` | n/a | yes |
| <a name="input_state_bucket_name"></a> [state\_bucket\_name](#input\_state\_bucket\_name) | Name of the S3 bucket for storing terraform state | `string` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of subnet IDs where resources will be created | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags to apply to resources | `map(string)` | `{}` | no |
| <a name="input_vpc_config"></a> [vpc\_config](#input\_vpc\_config) | VPC configuration for the pipeline resources | <pre>object({<br>    vpc_id            = string<br>    region            = string<br>    security_group_ids = list(string)<br>    subnets           = list(string)<br>  })</pre> | n/a | yes |
| <a name="input_vpc_endpoints"></a> [vpc\_endpoints](#input\_vpc\_endpoints) | List of VPC endpoints to create | `list(string)` | <pre>[<br>  "codecommit",<br>  "ecr.api",<br>  "ecr.dkr",<br>  "git-codecommit",<br>  "s3"<br>]</pre> | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC where resources will be created | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_assets_bucket_arn"></a> [assets\_bucket\_arn](#output\_assets\_bucket\_arn) | ARN of the assets S3 bucket |
| <a name="output_assets_bucket_name"></a> [assets\_bucket\_name](#output\_assets\_bucket\_name) | Name of the assets S3 bucket |
| <a name="output_pipeline_security_group_id"></a> [pipeline\_security\_group\_id](#output\_pipeline\_security\_group\_id) | ID of the pipeline security group |
| <a name="output_state"></a> [state](#output\_state) | State configuration |
| <a name="output_state_bucket_arn"></a> [state\_bucket\_arn](#output\_state\_bucket\_arn) | ARN of the Terraform state S3 bucket |
| <a name="output_state_bucket_name"></a> [state\_bucket\_name](#output\_state\_bucket\_name) | Name of the Terraform state S3 bucket |
| <a name="output_state_lock_table_name"></a> [state\_lock\_table\_name](#output\_state\_lock\_table\_name) | Name of the DynamoDB state lock table |
| <a name="output_vpc_config"></a> [vpc\_config](#output\_vpc\_config) | VPC configuration including VPC ID, region, security groups, and subnets |
| <a name="output_vpc_endpoints"></a> [vpc\_endpoints](#output\_vpc\_endpoints) | Map of created VPC endpoints |
<!-- END_TF_DOCS -->