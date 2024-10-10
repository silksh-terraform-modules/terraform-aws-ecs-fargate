output "app_fqdn" {
  value = aws_route53_record.this[*].fqdn
}

output "app_fqdn_secondary" {
  value = aws_route53_record.secondary[*].fqdn
}

output "app_service_name" {
  value = aws_ecs_service.this.name
}

output "app_repository_url" {
  value = var.ecr_repository_url
}

output "app_env_bucket_id" {
  value = var.environment_bucket_id
}
