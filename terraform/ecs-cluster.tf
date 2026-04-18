resource "aws_ecs_cluster" "mycluster" {
  name = "my-cluster"

  tags = {
    Name = "My Cluster"
  }
}