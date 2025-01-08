# Create Database
resource "aws_db_instance" "db" {
  allocated_storage           = 10
#  storage_type                = "gp3"
  engine                      = "mysql"
  engine_version              = "8.0"
  instance_class              = "db.t3.micro"
  identifier                  = "db"
  username                    = "admin"
  password                    = "23vS5TdDW8*o"
  parameter_group_name        = "default.mysql8.0"
  db_subnet_group_name        = aws_db_subnet_group.db-subnet-group.name
  vpc_security_group_ids      = ["${aws_security_group.db-sg.id}"]
  multi_az                    = true
  skip_final_snapshot         = true
  publicly_accessible         = false

  lifecycle {
    prevent_destroy = false
    ignore_changes  = all
  }
}

# DB Subnet Group
resource "aws_db_subnet_group" "db-subnet-group" {
  name       = "db-subnet-group"
  subnet_ids = ["${aws_subnet.private-subnet-03.id}","${aws_subnet.private-subnet-04.id}"]
}

# Database tier Security group
resource "aws_security_group" "db-sg" {
  name        = "DB-SG"
  description = "allow traffic from app tier"
  vpc_id      = aws_vpc.three-tier-vpc.id

  ingress {
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    cidr_blocks      = ["10.0.0.32/28" , "10.0.0.48/28"]
    description      = "Access for the web ALB SG"
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.appserver-security-group.id]
    cidr_blocks     = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}