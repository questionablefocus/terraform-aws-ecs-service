resource "aws_cloudwatch_log_group" "main" {
  name              = "/ecs/${var.name}"
  retention_in_days = 30
}
