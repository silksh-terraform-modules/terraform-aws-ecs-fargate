output "app_fqdn" {
  value = aws_route53_record.this[*].fqdn
}

output "app_fqdn_secondary" {
  value = aws_route53_record.secondary[*].fqdn
}

output "app_service_name" {
  value = aws_ecs_service.this.name
}
