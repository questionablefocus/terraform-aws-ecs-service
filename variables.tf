variable "name" {
  description = "Name of the ECS service"
  type        = string
}

variable "task_cpu" {
  description = "CPU units for the task (valid values: 256, 512, 1024, 2048, 4096)"
  type        = number

  validation {
    condition     = contains([256, 512, 1024, 2048, 4096], var.task_cpu)
    error_message = "Task CPU must be one of: 256, 512, 1024, 2048, 4096"
  }
}

variable "task_memory" {
  description = "Memory for the task in MiB"
  type        = number
}

variable "cluster_id" {
  description = "ID of the ECS cluster"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs to deploy the service into"
  type        = list(string)
}

variable "containers" {
  description = "List of container definitions"
  type = list(object({
    name      = string
    image     = string
    cpu       = optional(number)
    memory    = optional(number)
    essential = optional(bool, true)
    portMappings = optional(list(object({
      containerPort = number
      hostPort      = optional(number)
      protocol      = optional(string)
    })), [])
    environment = optional(list(object({
      name  = string
      value = string
    })), [])
    secrets = optional(list(object({
      name      = string
      valueFrom = string
    })), [])
    mountPoints = optional(list(object({
      sourceVolume  = string
      containerPath = string
      readOnly      = optional(bool, false)
    })), [])
  }))

  validation {
    condition = alltrue([
      for container in var.containers : !contains(keys(container), "logConfiguration")
    ])
    error_message = "logConfiguration should not be provided in container definitions. Logging is automatically configured to use the CloudWatch log group."
  }
}

variable "desired_count" {
  description = "Number of tasks to run"
  type        = number
  default     = 1

  validation {
    condition     = !var.enable_autoscaling || (var.desired_count >= var.min_capacity && var.desired_count <= var.max_capacity)
    error_message = "Desired count must be between min_capacity and max_capacity when autoscaling is enabled."
  }
}

variable "enable_autoscaling" {
  description = "Whether to enable autoscaling for the ECS service"
  type        = bool
  default     = false
}

variable "min_capacity" {
  description = "Minimum number of tasks for autoscaling"
  type        = number
  default     = 1

  validation {
    condition     = var.min_capacity >= 0
    error_message = "Min capacity must be 0 or greater."
  }
}

variable "max_capacity" {
  description = "Maximum number of tasks for autoscaling"
  type        = number
  default     = 10

  validation {
    condition     = var.max_capacity > 0
    error_message = "Max capacity must be greater than 0."
  }

  validation {
    condition     = var.max_capacity >= var.min_capacity
    error_message = "Max capacity must be greater than or equal to min capacity."
  }
}

variable "task_execution_role_arn" {
  description = "ARN of the task execution role"
  type        = string
}

variable "task_role_arn" {
  description = "ARN of the task role"
  type        = string
}

variable "ingress_rules" {
  description = "List of ingress rules for the security group"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = optional(string)
  }))
  default = []
}

variable "efs_root_directory" {
  description = "Root directory of the EFS file system"
  type        = string
  default     = null
}

variable "efs_volume_name" {
  description = "Name of the EFS volume"
  type        = string
  default     = null

  validation {
    condition     = (var.efs_volume_name == null && var.efs_root_directory == null) || (var.efs_volume_name != null && var.efs_root_directory != null)
    error_message = "efs_volume_name and efs_root_directory must be provided together or both must be null."
  }
}

variable "efs_provisioned_throughput" {
  description = "Provisioned throughput in Mibps for the EFS file system. Required when throughput_mode is 'provisioned'."
  type        = number
  default     = null
}

variable "efs_throughput_mode" {
  description = "Throughput mode for the EFS file system. Can be 'bursting', 'provisioned', or 'elastic'."
  type        = string
  default     = "bursting"

  validation {
    condition     = contains(["bursting", "provisioned", "elastic"], var.efs_throughput_mode)
    error_message = "Throughput mode must be one of: bursting, provisioned, or elastic."
  }

  validation {
    condition     = (var.efs_throughput_mode == "provisioned" && var.efs_provisioned_throughput != null) || var.efs_throughput_mode != "provisioned"
    error_message = "Provisioned throughput must be specified when throughput mode is 'provisioned'."
  }
}

variable "load_balancers" {
  description = "Load balancer configuration for the ECS service"
  type = list(object({
    target_group_arn = string
    container_name   = string
    container_port   = number
  }))
  default = []
}

variable "service_registries" {
  description = "Service discovery registries for the service"
  type = list(object({
    registry_arn   = string
    port           = optional(number)
    container_name = optional(string)
    container_port = optional(number)
  }))
  default = []
}
