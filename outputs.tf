output "service_id" {
  description = "ID of the ECS service"
  value       = aws_ecs_service.service.id
}

output "task_definition_arn" {
  description = "ARN of the task definition"
  value       = aws_ecs_task_definition.task.arn
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.ecs_service.id
}
