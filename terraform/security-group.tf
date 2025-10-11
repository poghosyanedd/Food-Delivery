resource "aws_security_group" "app_sg" {
  name        = "${var.project_name}-sg"
  description = "Security group for Food Delivery application"

  tags = {
    Name        = "${var.project_name}-sg"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# SSH access
resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.app_sg.id
  description       = "SSH access"
  
  cidr_ipv4   = var.allowed_ssh_cidrs[0]
  from_port   = 22
  to_port     = 22
  ip_protocol = "tcp"

  tags = {
    Name = "SSH"
  }
}

# HTTP access
resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.app_sg.id
  description       = "HTTP access"
  
  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"

  tags = {
    Name = "HTTP"
  }
}

# HTTPS access
resource "aws_vpc_security_group_ingress_rule" "https" {
  security_group_id = aws_security_group.app_sg.id
  description       = "HTTPS access"
  
  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"

  tags = {
    Name = "HTTPS"
  }
}

# Backend API (optional - for development/testing)
resource "aws_vpc_security_group_ingress_rule" "backend" {
  security_group_id = aws_security_group.app_sg.id
  description       = "Backend API"
  
  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 4000
  to_port     = 4000
  ip_protocol = "tcp"

  tags = {
    Name = "Backend"
  }
}

# Frontend (optional - for development/testing)
resource "aws_vpc_security_group_ingress_rule" "frontend" {
  security_group_id = aws_security_group.app_sg.id
  description       = "Frontend"
  
  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 5173
  to_port     = 5173
  ip_protocol = "tcp"

  tags = {
    Name = "Frontend"
  }
}

# Admin panel (optional - for development/testing)
resource "aws_vpc_security_group_ingress_rule" "admin" {
  security_group_id = aws_security_group.app_sg.id
  description       = "Admin Panel"
  
  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 5174
  to_port     = 5174
  ip_protocol = "tcp"

  tags = {
    Name = "Admin"
  }
}

# Allow all outbound traffic
resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.app_sg.id
  description       = "Allow all outbound traffic"
  
  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"

  tags = {
    Name = "All outbound"
  }
}