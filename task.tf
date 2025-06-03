data "aws_region" "current" {}

locals {
  # Compute total CPU and memory from all containers
  total_cpu = sum([
    for container in var.containers : lookup(container, "cpu", 0)
  ])

  total_memory = sum([
    for container in var.containers : lookup(container, "memory", 0)
  ])

  containers_with_logging = [
    for container in var.containers : merge(container, {
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.main.name
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = container.name
        }
      }
    })
  ]
}

resource "aws_ecs_task_definition" "main" {
  family                   = var.name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = local.total_cpu
  memory                   = local.total_memory
  execution_role_arn       = var.task_execution_role_arn
  task_role_arn            = var.task_role_arn

  dynamic "volume" {
    for_each = var.efs_root_directory != null ? { efs_volume = true } : {}

    content {
      name = var.efs_volume_name

      efs_volume_configuration {
        file_system_id     = aws_efs_file_system.main[0].id
        transit_encryption = "ENABLED"

        authorization_config {
          access_point_id = aws_efs_access_point.main[0].id
          iam             = "ENABLED"
        }
      }
    }
  }

  container_definitions = jsonencode(local.containers_with_logging)
}
