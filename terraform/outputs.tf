# -----------------------------
# Output Values
# -----------------------------

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.app_alb.dns_name
}

output "alb_url" {
  description = "Application URL through the ALB"
  value       = "http://${aws_lb.app_alb.dns_name}"
}

output "target_group_name" {
  description = "Name of the ALB target group"
  value       = aws_lb_target_group.app_tg.name
}

output "target_group_arn" {
  description = "ARN of the ALB target group"
  value       = aws_lb_target_group.app_tg.arn
}

output "auto_scaling_group_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.app_asg.name
}

output "launch_template_id" {
  description = "ID of the EC2 Launch Template"
  value       = aws_launch_template.app_lt.id
}

output "vpc_id" {
  description = "ID of the VPC created for this project"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs used by ALB and ASG"
  value = [
    aws_subnet.public_1.id,
    aws_subnet.public_2.id
  ]
}

output "alb_security_group_id" {
  description = "Security group ID attached to the ALB"
  value       = aws_security_group.alb_sg.id
}

output "ec2_security_group_id" {
  description = "Security group ID attached to ASG EC2 instances"
  value       = aws_security_group.ec2_sg.id
}