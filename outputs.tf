output "service_id" {
  description = "ID of the ECS service"
  value       = aws_ecs_service.main.id
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.main.id
}

output "task_definition_arn" {
  description = "ARN of the task definition"
  value       = aws_ecs_task_definition.main.arn
}

output "efs_file_system_id" {
  description = "ID of the EFS file system"
  value       = var.efs_root_directory != null ? aws_efs_file_system.main[0].id : null
}

output "efs_file_system_arn" {
  description = "ARN of the EFS file system"
  value       = var.efs_root_directory != null ? aws_efs_file_system.main[0].arn : null
}

output "efs_access_point_id" {
  description = "ID of the EFS access point"
  value       = var.efs_root_directory != null ? aws_efs_access_point.main[0].id : null
}

output "efs_access_point_arn" {
  description = "ARN of the EFS access point"
  value       = var.efs_root_directory != null ? aws_efs_access_point.main[0].arn : null
}

output "efs_security_group_id" {
  description = "ID of the EFS security group"
  value       = var.efs_root_directory != null ? aws_security_group.efs[0].id : null
}

