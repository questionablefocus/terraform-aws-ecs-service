data "aws_region" "current" {}

resource "aws_ecs_task_definition" "main" {
  family                   = var.name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = var.task_execution_role_arn
  task_role_arn            = var.task_role_arn

  dynamic "volume" {
    for_each = var.efs_root_directory != null ? { efs_volume = true } : {}

    content {
      name = "efs-volume"

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

  container_definitions = jsonencode(var.containers)
}
