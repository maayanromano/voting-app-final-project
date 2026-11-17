resource "aws_ecs_cluster" "this" {
  name = "${local.name}-cluster"
}

locals {
  service_subnet_ids = [
    for subnet in aws_subnet.public : subnet.id
  ]

  db_environment = {
    DB_HOST = aws_db_instance.this.address
    DB_PORT = tostring(aws_db_instance.this.port)
    DB_USER = aws_db_instance.this.username
    DB_NAME = aws_db_instance.this.db_name
    DB_SSL  = "true"
  }

  db_secrets = [
    {
      name      = "DB_PASSWORD"
      valueFrom = aws_secretsmanager_secret.db_password.arn
    }
  ]
}

module "vote" {
  source = "./modules/service"

  name               = "${local.name}-vote"
  image              = "${data.aws_ecr_repository.vote.repository_url}:${var.image_tag}"
  cluster_id         = aws_ecs_cluster.this.id
  execution_role_arn = aws_iam_role.execution.arn
  subnet_ids         = local.service_subnet_ids
  security_group_ids = [aws_security_group.ecs.id]
  desired_count      = var.desired_count

  container_port   = 80
  target_group_arn = aws_lb_target_group.vote.arn

  environment = {
    REDIS_HOST = aws_elasticache_cluster.redis.cache_nodes[0].address
    OPTION_A   = var.option_a
    OPTION_B   = var.option_b
  }

  depends_on = [
    aws_lb_listener.vote,
    aws_iam_role_policy_attachment.execution,
    aws_iam_role_policy.db_secret
  ]
}

module "result" {
  source = "./modules/service"

  name               = "${local.name}-result"
  image              = "${data.aws_ecr_repository.result.repository_url}:${var.image_tag}"
  cluster_id         = aws_ecs_cluster.this.id
  execution_role_arn = aws_iam_role.execution.arn
  subnet_ids         = local.service_subnet_ids
  security_group_ids = [aws_security_group.ecs.id]
  desired_count      = var.desired_count

  container_port   = 80
  target_group_arn = aws_lb_target_group.result.arn

  environment = local.db_environment
  secrets     = local.db_secrets

  depends_on = [
    aws_lb_listener.result,
    aws_iam_role_policy_attachment.execution,
    aws_iam_role_policy.db_secret,
    aws_secretsmanager_secret_version.db_password
  ]
}

module "worker" {
  source = "./modules/service"

  name               = "${local.name}-worker"
  image              = "${data.aws_ecr_repository.worker.repository_url}:${var.image_tag}"
  cluster_id         = aws_ecs_cluster.this.id
  execution_role_arn = aws_iam_role.execution.arn
  subnet_ids         = local.service_subnet_ids
  security_group_ids = [aws_security_group.ecs.id]
  desired_count      = var.desired_count

  environment = merge(local.db_environment, {
    REDIS_HOST = aws_elasticache_cluster.redis.cache_nodes[0].address
  })

  secrets = local.db_secrets

  depends_on = [
    aws_iam_role_policy_attachment.execution,
    aws_iam_role_policy.db_secret,
    aws_secretsmanager_secret_version.db_password
  ]
}
