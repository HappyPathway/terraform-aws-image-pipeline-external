variable "project_name" {
  type        = string
  description = "Name of the project to be used as prefix for resources"
}

variable "region" {
  type        = string
  description = "The AWS region where resources will be created"
}

# S3 bucket configurations
variable "assets_bucket_name" {
  type        = string
  description = "Name of the S3 bucket for storing pipeline artifacts"
  default     = "image-pipeline-assets"
}

variable "state_bucket_name" {
  type        = string
  description = "Name of the S3 bucket for storing terraform state"
}

# Network configurations
variable "vpc_cidr" {
  type        = string
  description = "CIDR block for VPC when creating a new VPC"
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones for subnet creation"
  default     = []
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

# Feature flags
variable "enable_assets_bucket" {
  type        = bool
  description = "Flag to enable/disable the assets S3 bucket and related resources"
  default     = true
}

variable "enable_vpc_endpoints" {
  type        = bool
  description = "Flag to enable/disable VPC endpoint resources"
  default     = true
}

variable "enable_security_groups" {
  type        = bool
  description = "Flag to enable/disable security group resources"
  default     = true
}

variable "enable_state_backend" {
  type        = bool
  description = "Flag to enable/disable state backend resources (S3 bucket and DynamoDB)"
  default     = true
}

# Resource creation flags
variable "create_vpc" {
  type        = bool
  description = "Whether to create VPC resources or look them up"
  default     = false
}

variable "create_security_groups" {
  type        = bool
  description = "Whether to create security groups or look them up"
  default     = false
}

variable "create_subnets" {
  type        = bool
  description = "Whether to create subnets or look them up"
  default     = false
}

variable "create_vpc_endpoints" {
  type        = bool
  description = "Whether to create VPC endpoints or use existing ones"
  default     = false
}

# Existing resource references
variable "existing_vpc_id" {
  type        = string
  description = "Existing VPC ID to use when not creating VPC"
  default     = ""
}

variable "existing_security_group_ids" {
  type        = list(string)
  description = "Existing security group IDs to use when not creating security groups"
  default     = []
}

variable "existing_subnet_ids" {
  type        = list(string)
  description = "Existing subnet IDs to use when not creating subnets"
  default     = []
}

variable "existing_vpc_endpoint_ids" {
  type        = map(string)
  description = "Map of existing VPC endpoint IDs to use when not creating them"
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "Additional tags to apply to resources"
  default     = {}
}

variable "pipeline_iam_arns" {
  type        = list(string)
  description = "List of IAM ARNs that need access to the assets bucket"
  default     = []
}
