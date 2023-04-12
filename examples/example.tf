module "ecs_testfargate" {
  source                = "github.com/silksh-terraform-modules/terraform-aws-ecs-fargate?ref=v0.0.1"
  
  aws_region            = "eu-north-1"
  vpc_id                = data.terraform_remote_state.infra.outputs.vpc_id
  service_name          = "testfargate"
  env_name              = "test"
  ecs_role_arn          = aws_iam_role.ecs_role.arn
  docker_image_tag      = "latest"
  ecr_repository_url    = data.terraform_remote_state.global.outputs.ecr_example
  environment_bucket_id = module.s3_bucket_example.s3_bucket_id
  deploy_max_percent    = 200
  deploy_min_percent    = 100
  
  launch_type = "FARGATE"


  task_variables = {
    "AWS_REGION" = "${var.aws_region}"
  }

  zone_id = data.aws_route53_zone.zone_example.zone_id

  ## handling requests coming directly from the loadbalancer
  service_dns_name = "test.example.com"

  ## handling requests flowing through the cloudfront distribution
  # other_service_dns_names = ["example.tgcfa.silksh.dev"]

  cluster_id                  = aws_ecs_cluster.main.id
  cluster_name                = aws_ecs_cluster.main.name
  lb_dns_name                 = aws_lb.external.dns_name
  lb_zone_id                  = aws_lb.external.zone_id
  lb_listener_arn             = aws_lb_listener.https_external.arn
  deployer_id                 = module.deployer_user.deployer_id
  deployer_secret             = module.deployer_user.deployer_secret
  gitlab_branch               = "test"
  # for correct values for cpu limit & memory limit see https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html
  cpu_limit                   = "256"
  memory_limit                = "512"
  # container & host port must be identical
  container_port              = "8888"
  host_port                   = "8888"
  target_group_health_matcher = "200"
  target_group_health_path    = "/"
  subnet_ids                  = data.terraform_remote_state.infra.outputs.subnet_a_id

  environment_files = [
    {
      value = "${module.s3_bucket_example.s3_bucket_arn}/.env",
      type  = "s3"
    }
  ]

}
