resource "aws_ecs_service" "service" {
  name                               = "my-service"
  launch_type                        = "FARGATE"
  platform_version                   = "LATEST"
  cluster                            = aws_ecs_cluster.mycluster.id
  task_definition                    = aws_ecs_task_definition.TD.arn
  scheduling_strategy                = "REPLICA"
  desired_count                      = 2
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  depends_on                         = [aws_iam_role.ecs_execution_role, aws_iam_role_policy_attachment.ecs_execution_attach]

  load_balancer {
    target_group_arn = aws_lb_target_group.TG.arn
    container_name   = "nginx"
    container_port   = 80
  }

  network_configuration {
    assign_public_ip = true
    security_groups  = [aws_security_group.security_group.id]
    subnets          = [aws_subnet.public_subnet_az1.id, aws_subnet.public_subnet_az2.id]
  }
}