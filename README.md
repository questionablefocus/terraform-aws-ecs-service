# terraform-aws-ecs-service

A Terraform module for creating AWS ECS services with support for autoscaling, EFS integration, and load balancer configuration.

## Features

- ECS Fargate service deployment
- Application Auto Scaling target configuration
- EFS file system integration
- Load balancer integration
- Service discovery integration
- Configurable security groups
- CloudWatch logging

## Usage

````hcl
module "ecs_service" {
  source = "./terraform-aws-ecs-service"

  name                    = "my-app"
  cluster_id              = "arn:aws:ecs:us-west-2:123456789012:cluster/my-cluster"
  vpc_id                  = "vpc-12345678"
  subnet_ids              = ["subnet-12345678", "subnet-87654321"]
  task_cpu                = 256
  task_memory             = 512
  task_execution_role_arn = "arn:aws:iam::123456789012:role/ecsTaskExecutionRole"
  task_role_arn           = "arn:aws:iam::123456789012:role/ecsTaskRole"
  desired_count           = 2

  containers = [
    {
      name  = "app"
      image = "nginx:latest"
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]
    }
  ]

  # Autoscaling configuration
  enable_autoscaling = true
  min_capacity       = 1
  max_capacity       = 10

  # Load balancer configuration
  load_balancers = [
    {
      target_group_arn = "arn:aws:elasticloadbalancing:us-west-2:123456789012:targetgroup/my-tg/1234567890123456"
      container_name   = "app"
      container_port   = 80
    }
  ]

  # Security group rules
  ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/16"]
    }
  ]
}

# Autoscaling policies configured externally
resource "aws_appautoscaling_policy" "cpu_scaling" {
  name               = "cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = module.ecs_service.autoscaling_target_resource_id
  scalable_dimension = module.ecs_service.autoscaling_target_scalable_dimension
  service_namespace  = module.ecs_service.autoscaling_target_service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = 70.0
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}

resource "aws_appautoscaling_policy" "memory_scaling" {
  name               = "memory-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = module.ecs_service.autoscaling_target_resource_id
  scalable_dimension = module.ecs_service.autoscaling_target_scalable_dimension
  service_namespace  = module.ecs_service.autoscaling_target_service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    target_value = 80.0
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}

## Autoscaling Configuration

The module creates an Application Auto Scaling target for the ECS service. Scaling policies should be configured externally using the module outputs. This approach provides better flexibility and allows for more complex scaling scenarios.

### Target Tracking Scaling

Scales based on a target value for a specified metric. Supports both predefined ECS metrics and custom CloudWatch metrics.

```hcl
resource "aws_appautoscaling_policy" "cpu_scaling" {
  name               = "cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = module.ecs_service.autoscaling_target_resource_id
  scalable_dimension = module.ecs_service.autoscaling_target_scalable_dimension
  service_namespace  = module.ecs_service.autoscaling_target_service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = 70.0
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}
````

### Step Scaling

Scales based on step adjustments for metric values.

```hcl
resource "aws_appautoscaling_policy" "custom_metric_scaling" {
  name               = "custom-metric-scaling"
  policy_type        = "StepScaling"
  resource_id        = module.ecs_service.autoscaling_target_resource_id
  scalable_dimension = module.ecs_service.autoscaling_target_scalable_dimension
  service_namespace  = module.ecs_service.autoscaling_target_service_namespace

  step_scaling_policy_configuration {
    adjustment_type = "ChangeInCapacity"
    cooldown       = 300
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      metric_interval_upper_bound = 10
      scaling_adjustment          = 1
    }

    step_adjustment {
      metric_interval_lower_bound = 10
      scaling_adjustment          = 2
    }
  }
}
```

### Custom CloudWatch Metrics

You can scale based on custom CloudWatch metrics:

```hcl
resource "aws_appautoscaling_policy" "custom_metric_scaling" {
  name               = "custom-metric-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = module.ecs_service.autoscaling_target_resource_id
  scalable_dimension = module.ecs_service.autoscaling_target_scalable_dimension
  service_namespace  = module.ecs_service.autoscaling_target_service_namespace

  target_tracking_scaling_policy_configuration {
    customized_metric_specification {
      metric_name = "RequestCount"
      namespace   = "MyApp"
      statistic   = "Average"
      unit        = "Count"
      dimensions {
        name  = "ServiceName"
        value = "my-app"
      }
    }
    target_value = 100.0
  }
}
```
