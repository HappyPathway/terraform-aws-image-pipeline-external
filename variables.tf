variable "project_name" {
  type        = string
  description = "Name of the project to be used as prefix for resources"
}

variable "assets_bucket_name" {
  type        = string
  description = "Name of the S3 bucket for storing pipeline artifacts"
  default     = "image-pipeline-assets"
}

variable "state_bucket_name" {
  type        = string
  description = "Name of the S3 bucket for storing terraform state"
}

variable "pipeline_iam_arns" {
  type        = list(string)
  description = "List of IAM ARNs that need access to the assets bucket"
}

variable "vpc_config" {
  type = object({
    vpc_id            = string
    region            = string
    security_group_ids = list(string)
    subnets           = list(string)
  })
  description = "VPC configuration for the pipeline resources"
}

variable "vpc_endpoints" {
  type        = list(string)
  description = "List of VPC endpoints to create"
  default = [
    "codecommit",
    "ecr.api",
    "ecr.dkr",
    "git-codecommit",
    "s3"
  ]
}

variable "tags" {
  type        = map(string)
  description = "Additional tags to apply to resources"
  default     = {}
}

# Feature flags for resource groups
variable "enable_assets_bucket" {
  description = "Flag to enable/disable the assets S3 bucket and related resources"
  type        = bool
  default     = true
}

variable "enable_vpc_endpoints" {
  description = "Flag to enable/disable VPC endpoint resources"
  type        = bool
  default     = true
}

variable "enable_security_groups" {
  description = "Flag to enable/disable security group resources"
  type        = bool
  default     = true
}

variable "enable_state_backend" {
  description = "Flag to enable/disable state backend resources (S3 bucket and DynamoDB)"
  type        = bool
  default     = true
}

variable "enable_build_user" {
  description = "Flag to enable/disable the build user resources"
  type        = bool
  default     = true
}

variable "region" {
  type        = string
  description = "The AWS region where resources will be created"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs where resources will be created"
}

variable "additional_security_group_ids" {
  type        = list(string)
  description = "Additional security group IDs to be added to the VPC configuration"
  default     = []
}

variable "route_table_ids" {
  description = "List of route table IDs for VPC endpoint association"
  type        = list(string)
  default     = []
}
