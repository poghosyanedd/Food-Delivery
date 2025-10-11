output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.app_server.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_eip.app_eip.public_ip
}

output "instance_public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = aws_instance.app_server.public_dns
}

output "instance_private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = aws_instance.app_server.private_ip
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.app_sg.id
}

output "iam_role_arn" {
  description = "ARN of the IAM role attached to EC2"
  value       = aws_iam_role.ec2_ecr_role.arn
}

output "iam_instance_profile_arn" {
  description = "ARN of the IAM instance profile"
  value       = aws_iam_instance_profile.ec2_profile.arn
}

output "ssh_connection_string" {
  description = "SSH connection string"
  value       = "ssh -i ~/.ssh/id_rsa ubuntu@${aws_eip.app_eip.public_ip}"
}

output "application_urls" {
  description = "Application URLs"
  value = {
    frontend = "http://${aws_eip.app_eip.public_ip}"
    backend  = "http://${aws_eip.app_eip.public_ip}/api"
    admin    = "http://${aws_eip.app_eip.public_ip}/admin"
  }
}

output "ecr_login_command" {
  description = "Command to login to ECR"
  value       = "aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com"
}