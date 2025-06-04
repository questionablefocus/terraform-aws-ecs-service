data "aws_region" "current" {}

locals {
  # Valid Fargate CPU and memory combinations
  valid_fargate_configs = {
    "256"  = [512, 1024, 2048]
    "512"  = [1024, 2048, 3072, 4096]
    "1024" = [2048, 3072, 4096, 5120, 6144, 7168, 8192]
    "2048" = [4096, 5120, 6144, 7168, 8192, 9216, 10240, 11264, 12288, 13312, 14336, 15360, 16384]
    "4096" = [8192, 9216, 10240, 11264, 12288, 13312, 14336, 15360, 16384, 17408, 18432, 19456, 20480, 21504, 22528, 23552, 24576, 25600, 26624, 27648, 28672, 29696, 30720]
  }

  # Calculate total container resources
  total_container_cpu = sum([
    for container in var.containers : container.cpu
  ])

  total_container_memory = sum([
    for container in var.containers : container.memory
  ])

  # Find the smallest valid CPU that can accommodate the containers
  task_cpu = min([
    for cpu, memories in local.valid_fargate_configs : tonumber(cpu)
    if tonumber(cpu) >= local.total_container_cpu
  ]...)

  # Find the smallest valid memory for the selected CPU that can accommodate the containers
  task_memory = min([
    for memory in local.valid_fargate_configs[tostring(local.task_cpu)] : memory
    if memory >= local.total_container_memory
  ]...)

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
  cpu                      = local.task_cpu
  memory                   = local.task_memory
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
