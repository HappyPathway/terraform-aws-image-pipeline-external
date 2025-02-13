output "assets_bucket" {
  description = "The assets S3 bucket object"
  value = {
    id     = aws_s3_bucket.assets_bucket.id
    arn    = aws_s3_bucket.assets_bucket.arn
    bucket = aws_s3_bucket.assets_bucket.bucket
  }
}

output "state_bucket" {
  description = "The state backend S3 bucket object"
  value = {
    id     = aws_s3_bucket.state_bucket.id
    arn    = aws_s3_bucket.state_bucket.arn
    bucket = aws_s3_bucket.state_bucket.bucket
  }
}

output "state_lock_table" {
  description = "The DynamoDB table used for state locking"
  value = {
    id    = aws_dynamodb_table.terraform_state_lock.id
    arn   = aws_dynamodb_table.terraform_state_lock.arn
    name  = aws_dynamodb_table.terraform_state_lock.name
  }
}

output "security_group_id" {
  description = "ID of the pipeline security group"
  value       = aws_security_group.pipeline_security_group.id
}

output "vpc_endpoints" {
  description = "Map of created VPC endpoints"
  value       = { for k, v in aws_vpc_endpoint.endpoints : k => v.id }
}