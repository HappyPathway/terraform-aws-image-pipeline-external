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
