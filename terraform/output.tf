output "load_balancer_ip" {
  value = aws_lb.LB.dns_name
}