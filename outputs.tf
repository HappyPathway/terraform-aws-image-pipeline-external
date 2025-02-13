output "assets_bucket_arn" {
  description = "ARN of the assets S3 bucket"
  value       = var.enable_assets_bucket ? aws_s3_bucket.assets_bucket[0].arn : null
}

output "assets_bucket_name" {
  description = "Name of the assets S3 bucket"
  value       = var.enable_assets_bucket ? aws_s3_bucket.assets_bucket[0].id : null
}

output "pipeline_security_group_id" {
  description = "ID of the pipeline security group"
  value       = var.enable_security_groups ? aws_security_group.pipeline_security_group[0].id : null
}

output "state_bucket_arn" {
  description = "ARN of the Terraform state S3 bucket"
  value       = var.enable_state_backend ? aws_s3_bucket.state_bucket[0].arn : null
}

output "state_bucket_name" {
  description = "Name of the Terraform state S3 bucket"
  value       = var.enable_state_backend ? aws_s3_bucket.state_bucket[0].id : null
}

output "state_lock_table_name" {
  description = "Name of the DynamoDB state lock table"
  value       = var.enable_state_backend ? aws_dynamodb_table.terraform_state_lock[0].name : null
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

output "build_user_role_arn" {
  description = "The ARN of the build user IAM role"
  value       = var.enable_build_user ? aws_iam_role.build_user_role[0].arn : null
}

output "build_user_policy" {
  description = "The policy document for the build user"
  value       = var.enable_build_user ? aws_iam_role_policy.build_user_policy[0].policy : null
}

output "build_user_instance_profile" {
  description = "The instance profile for the build user"
  value       = var.enable_build_user ? aws_iam_instance_profile.build_user_instance_profile[0] : null
}