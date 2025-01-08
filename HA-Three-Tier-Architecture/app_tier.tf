# Data source for image id
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

# Create a launch configuration for the EC2 instances
resource "aws_launch_configuration" "app-launch-configuration" {
  name_prefix       = "App-Launch-Configuration"
  image_id          = data.aws_ami.amazon_linux_2.id
  instance_type     = "t2.micro"
  security_groups   = [aws_security_group.appserver-security-group.id]
  key_name          = "app-key"
  user_data                   = <<-EOF
                                #!/bin/bash

                                sudo yum install mysql -y

                                EOF

  associate_public_ip_address = false

  lifecycle {
    create_before_destroy = true
  }  
}

# App tier auto scalling group - Security Group
resource "aws_security_group" "appserver-security-group" {
  name        = "appserver-security-group"
  description = "Allow traffic from web tier"
  vpc_id      = aws_vpc.three-tier-vpc.id
  depends_on = [
    aws_vpc.three-tier-vpc
  ]

  ingress {
    from_port = "-1"
    to_port   = "-1"
    protocol  = "icmp"
    security_groups  = [aws_security_group.webserver-security-group.id]
  }
  ingress {
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    security_groups  = [aws_security_group.webserver-security-group.id]
  }
  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    security_groups  = [aws_security_group.webserver-security-group.id]
  }
  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "appserver-security-group"
  }
}

# Create an EC2 Auto Scaling Group - app 
resource "aws_autoscaling_group" "app-autoscaling-group" {
  name                 = "App-Autoscaling-Group"
  launch_configuration = aws_launch_configuration.app-launch-configuration.name
  vpc_zone_identifier  = [aws_subnet.private-subnet-01.id, aws_subnet.private-subnet-02.id]
  min_size             = 1
  max_size             = 2
  desired_capacity     = 1
}

# Create a Load Balancer - app
resource "aws_lb" "app-lb" {
  name               = "App-LB"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.app-alb-sg.id]
  subnets            = [aws_subnet.private-subnet-01.id, aws_subnet.private-subnet-02.id]

  tags = {
    Environment = "App-LB"
  }
}

# Create LB target group
resource "aws_lb_target_group" "app-alb-target-group" {
  name        = "App-ALB-target-group"
#  target_type = "alb"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.three-tier-vpc.id

  health_check {
    interval            = 30
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 10
    healthy_threshold   = 3
    unhealthy_threshold = 3
  } 
}

# Create LB listner creation
resource "aws_lb_listener" "app-lb-listener" {
  load_balancer_arn = aws_lb.app-lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app-alb-target-group.arn
  }
}

# Create a new ALB Target Group attachment
resource "aws_autoscaling_attachment" "app-autoscaling-attachment" {
  autoscaling_group_name = aws_autoscaling_group.app-autoscaling-group.id
  lb_target_group_arn    = aws_lb_target_group.app-alb-target-group.arn
}

# Load balancer security group - app
resource "aws_security_group" "app-alb-sg" {
  name        = "App-ALB-SG"
  description = "load balancer security group for app tier"
  vpc_id      = aws_vpc.three-tier-vpc.id
  depends_on = [
    aws_vpc.three-tier-vpc
  ]

  ingress {
    from_port          = "80"
    to_port            = "80"
    protocol           = "tcp"
    security_groups    = [aws_security_group.web-alb-sg.id]
  }

  tags = {
    Name = "app-alb-sg"
  }
}