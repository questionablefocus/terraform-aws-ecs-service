variable "name" {
  description = "Name of the ECS service"
  type        = string
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
    cpu       = optional(number, 0)
    memory    = optional(number, 0)
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
