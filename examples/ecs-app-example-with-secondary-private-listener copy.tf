module "ecs-app-example" {
  source = "github.com/silksh-terraform-modules/terraform-aws-ecs-app?ref=v0.0.1"
  aws_region = var.aws_region
  vpc_id = var.vpc_id
  service_name = "example-app"
  env_name = var.env_name
  ecs_role_arn = aws_iam_role.ecs_role.arn
  docker_image_tag = "latest"
  ecr_repository_url =  var.ecr_repository_url
  
  task_variables = {
    "VARIABLE" = "value"
    "ANOTHER_VARIABLE" = var.another_variable
  }

  ssm_variables = {
    "FIRST_VARIABLE" = "${local.ssm_parameter_prefix}/example-app/FIRST_VARIABLE",
    "SECOND_VARIABLE" = "${local.ssm_parameter_prefix}/example-app/SECOND_VARIABLE",
    "DATASOURCE_URL" = "${local.ssm_parameter_prefix}/example-app/DATASOURCE_URL",
    
  }

  cluster_id = aws_ecs_cluster.main.id
  cluster_name = aws_ecs_cluster.main.name

  zone_id = data.aws_route53_zone.zone.zone_id
  # remember to attach the correct certificate to https_external (if you generated a certificate other than the main one)
  service_dns_name = "example.${var.tld}"

  lb_dns_name = aws_lb.external.dns_name
  lb_zone_id = aws_lb.external.zone_id
  lb_listener_arn = aws_lb_listener.https_external.arn
  container_port = "8080"

  zone_id_secondary = data.aws_route53_zone.zone_private.zone_id
  service_dns_name_secondary = "example.${var.tld}"

  lb_dns_name_secondary = aws_lb.internal.dns_name
  lb_zone_id_secondary = aws_lb.internal.zone_id
  lb_listener_arn_secondary = aws_lb_listener.http_internal.arn
  ## define secondary port only if there is a secondary application on another port in the container
  ## if you want to expose the same application on another loadbalancer (for ex. internal)
  ## do not define that variable
  # container_port_secondary = "8090"

  # data for creating gitlab variables json for deployment, 
  # have to be created first
  deployer_id      = module.deployer_user.deployer_id
  deployer_secret  = module.deployer_user.deployer_secret

  gitlab_branch = "main"

  cpu_limit = "1024"
  memory_limit = "1024"

  target_group_health_matcher = "200"
  target_group_health_path = "/"

}
