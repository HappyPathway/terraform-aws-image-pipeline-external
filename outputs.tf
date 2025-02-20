output "assets_bucket_arn" {
  description = "ARN of the assets S3 bucket"
  value       = var.enable_assets_bucket ? aws_s3_bucket.assets_bucket[0].arn : null
}

output "assets_bucket_name" {
  description = "Name of the assets S3 bucket if enabled"
  value       = var.enable_assets_bucket ? aws_s3_bucket.assets_bucket[0].id : null
}

output "pipeline_security_group_id" {
  description = "ID of the pipeline security group, if enabled"
  value       = var.enable_security_groups && var.create_security_groups ? aws_security_group.pipeline[0].id : null
}

output "state_bucket_arn" {
  description = "ARN of the Terraform state S3 bucket"
  value       = var.enable_state_backend ? aws_s3_bucket.state_bucket[0].arn : null
}

output "state_bucket_name" {
  description = "Name of the state backend S3 bucket if enabled"
  value       = var.enable_state_backend ? aws_s3_bucket.state_bucket[0].id : null
}

output "state_lock_table_name" {
  description = "Name of the state lock DynamoDB table if enabled"
  value       = var.enable_state_backend ? aws_dynamodb_table.terraform_state_lock[0].id : null
}

output state {
  description = "State configuration"
  value       = {
    dynamodb_table = var.enable_state_backend ? aws_dynamodb_table.terraform_state_lock[0].name : null
    bucket         = var.enable_state_backend ? aws_s3_bucket.state_bucket[0].id : null
  }
}

output "vpc_endpoints" {
  description = "Map of created VPC endpoints"
  value       = var.enable_vpc_endpoints ? aws_vpc_endpoint.endpoints : null
}

output "vpc_config" {
  description = "VPC configuration including VPC ID, region, security groups, and subnets"
  value       = local.vpc_config
}

output "vpc_id" {
  description = "The ID of the VPC (created or looked up)"
  value       = local.vpc_id
}

output "security_group_ids" {
  description = "List of security group IDs (created or looked up)"
  value       = local.security_group_ids
}

output "subnet_ids" {
  description = "List of subnet IDs (created or looked up)"
  value       = local.subnet_ids
}

output "vpc_endpoint_ids" {
  description = "Map of VPC endpoint IDs (created or looked up)"
  value       = local.vpc_endpoint_ids
}

# output "build_user_arn" {
#   description = "ARN of the build user if enabled"
#   value       = var.enable_build_user ? aws_iam_user.build_user[0].arn : null
# }

# output "build_user_name" {
#   description = "Name of the build user if enabled"
#   value       = var.enable_build_user ? aws_iam_user.build_user[0].name : null
# }

# output build_user {
#   description = "Build user configuration"
#   value       = var.enable_build_user ? aws_iam_user.build_user[0] : null
# }

output security_group {
  description = "Pipeline security group"
  value       = var.enable_security_groups && var.create_security_groups ? aws_security_group.pipeline[0] : null
}