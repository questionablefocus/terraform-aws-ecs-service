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

output "autoscaling_target_id" {
  description = "ID of the Application Auto Scaling target"
  value       = var.enable_autoscaling ? aws_appautoscaling_target.main[0].id : null
}

output "autoscaling_target_resource_id" {
  description = "Resource ID of the Application Auto Scaling target (for use in external scaling policies)"
  value       = var.enable_autoscaling ? aws_appautoscaling_target.main[0].resource_id : null
}

output "autoscaling_target_scalable_dimension" {
  description = "Scalable dimension of the Application Auto Scaling target (for use in external scaling policies)"
  value       = var.enable_autoscaling ? aws_appautoscaling_target.main[0].scalable_dimension : null
}

output "autoscaling_target_service_namespace" {
  description = "Service namespace of the Application Auto Scaling target (for use in external scaling policies)"
  value       = var.enable_autoscaling ? aws_appautoscaling_target.main[0].service_namespace : null
}

