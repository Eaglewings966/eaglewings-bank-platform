output "repository_urls" {
  description = "ECR repository URLs"
  value = {
    for repo in aws_ecr_repository.main :
    repo.name => repo.repository_url
  }
}

output "registry_id" {
  description = "AWS account ID"
  value       = data.aws_caller_identity.current.account_id
}
