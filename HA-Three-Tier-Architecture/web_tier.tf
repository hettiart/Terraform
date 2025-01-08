/*
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
*/

# Create a launch configuration for the EC2 instances
resource "aws_launch_configuration" "web-launch-configuration" {
  name_prefix       = "Web-Launch-Configuration"
  image_id          = data.aws_ami.amazon_linux_2.id
  instance_type     = "t2.micro"
  security_groups   = [aws_security_group.webserver-security-group.id]
  key_name          = "web-key"
  user_data         = file("install-apache.sh")
  associate_public_ip_address = true

  lifecycle {
    create_before_destroy = true
  }  
}

# web tier auto scalling group - Security Group
resource "aws_security_group" "webserver-security-group" {
  name        = "webserver-security-group"
  description = "Allow traffic from VPC"
  vpc_id      = aws_vpc.three-tier-vpc.id
  depends_on = [
    aws_vpc.three-tier-vpc
  ]

  ingress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
  }
  ingress {
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "webserver-security-group"
  }
}

# Create an EC2 Auto Scaling Group - web 
resource "aws_autoscaling_group" "web-autoscaling-group" {
  name                 = "Web-Autoscaling-Group"
  launch_configuration = aws_launch_configuration.web-launch-configuration.name
  vpc_zone_identifier  = [aws_subnet.public-subnet-01.id, aws_subnet.public-subnet-02.id]
  min_size             = 1
  max_size             = 2
  desired_capacity     = 1
}

# Create a Load Balancer - web
resource "aws_lb" "web-lb" {
  name               = "Web-LB"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web-alb-sg.id]
  subnets            = [aws_subnet.public-subnet-01.id, aws_subnet.public-subnet-02.id]

  tags = {
    Environment = "Web-LB"
  }
}

# Create LB target group
resource "aws_lb_target_group" "web-alb-target-group" {
  name        = "Web-ALB-target-group"
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
resource "aws_lb_listener" "web-lb-listener" {
  load_balancer_arn = aws_lb.web-lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web-alb-target-group.arn
  }
}

# Create a new ALB Target Group attachment
resource "aws_autoscaling_attachment" "web-autoscaling-attachment" {
  autoscaling_group_name = aws_autoscaling_group.web-autoscaling-group.id
  lb_target_group_arn    = aws_lb_target_group.web-alb-target-group.arn
}

# Load balancer security group - web
resource "aws_security_group" "web-alb-sg" {
  name        = "Web-ALB-SG"
  description = "load balancer security group for web tier"
  vpc_id      = aws_vpc.three-tier-vpc.id
  depends_on = [
    aws_vpc.three-tier-vpc
  ]

  ingress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-alb-sg"
  }
}