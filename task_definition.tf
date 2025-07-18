locals {
  port_mappings = length(var.container_port_secondary) > 0 ? [
    {
      containerPort = var.container_port
      hostPort      = var.container_port
      protocol      = var.service_protocol
    },
    {
      containerPort = var.container_port_secondary
      hostPort      = var.container_port_secondary
      protocol      = var.service_protocol
    }
    ] : [
    {
      containerPort = var.container_port
      hostPort      = var.container_port
      protocol      = var.service_protocol
    }
  ]

}

module "container" {
  source  = "cloudposse/ecs-container-definition/aws"
  version = "0.61.2"

  container_name   = var.service_name
  container_image  = "${var.ecr_repository_url}:${var.docker_image_tag}"
  container_cpu    = var.cpu_limit
  container_memory = var.memory_limit
  command          = try(var.command, null)
  essential        = true

  log_configuration = {
    logDriver = "awslogs",
    options = merge(
      {
        awslogs-region        = var.aws_region,
        awslogs-group         = var.cloudwatch_log_group,
        awslogs-stream-prefix = var.env_name
      },
      var.cloudwatch_multiline_pattern != null ? { awslogs-multiline-pattern = var.cloudwatch_multiline_pattern } : {}
    )
  }

  port_mappings     = local.port_mappings
  map_secrets       = var.ssm_variables
  map_environment   = var.task_variables
  mount_points      = var.mount_points
  environment_files = var.environment_files
  healthcheck       = var.healthcheck
  restart_policy    = var.restart_policy
}

resource "aws_ecs_task_definition" "this" {
  family                   = "${var.service_name}-${var.env_name}"
  cpu                      = var.cpu_limit
  execution_role_arn       = var.ecs_role_arn
  memory                   = var.memory_limit
  network_mode             = "awsvpc"
  task_role_arn            = var.ecs_role_arn
  requires_compatibilities = ["FARGATE"]

  container_definitions = module.container.json_map_encoded_list

  lifecycle {
    create_before_destroy = true
  }

  dynamic "volume" {
    for_each = length(var.volume_name) > 0 ? [1] : []
    content {
      name      = var.volume_name
      host_path = var.host_path

    }
  }

  dynamic "volume" {
    for_each = length(var.efs_volume_name) > 0 ? [1] : []
    content {
      name = var.efs_volume_name

      dynamic "efs_volume_configuration" {
        for_each = length(var.efs_file_system_id) > 0 ? [1] : []

        content {
          file_system_id     = var.efs_file_system_id
          transit_encryption = "ENABLED"

          dynamic "authorization_config" {
            for_each = length(var.efs_access_point_id) > 0 ? [1] : []

            content {
              access_point_id = var.efs_access_point_id
            }
          }
        }
      }
    }
  }
}
