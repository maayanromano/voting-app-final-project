variable "name" {
  description = "Full service name"
  type        = string
}

variable "image" {
  description = "Container image URL including tag"
  type        = string
}

variable "cluster_id" {
  description = "ECS cluster ID"
  type        = string
}

variable "execution_role_arn" {
  description = "Task execution role ARN"
  type        = string
}

variable "subnet_ids" {
  description = "Public subnet IDs"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security group IDs for the tasks"
  type        = list(string)
}

variable "desired_count" {
  description = "Number of running tasks"
  type        = number
}

variable "environment" {
  description = "Container environment variables"
  type        = map(string)
  default     = {}
}

variable "secrets" {
  description = "Container secrets"
  type = list(object({
    name      = string
    valueFrom = string
  }))
  default = []
}

variable "container_port" {
  description = "Optional container port"
  type        = number
  default     = null
}

variable "target_group_arn" {
  description = "Optional load balancer target group ARN"
  type        = string
  default     = null
}
