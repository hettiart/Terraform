# Public Subnets
resource "aws_subnet" "public-subnet-01" {
  vpc_id     = aws_vpc.three-tier-vpc.id
  cidr_block = "10.0.0.0/28"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "Public-Subnet-01"
  }
}

resource "aws_subnet" "public-subnet-02" {
  vpc_id     = aws_vpc.three-tier-vpc.id
  cidr_block = "10.0.0.16/28"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "Public-Subnet-02"
  }
}

# Private Subnets
resource "aws_subnet" "private-subnet-01" {
  vpc_id     = aws_vpc.three-tier-vpc.id
  cidr_block = "10.0.0.32/28"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "Private-Subnet-01"
  }
}

resource "aws_subnet" "private-subnet-02" {
  vpc_id     = aws_vpc.three-tier-vpc.id
  cidr_block = "10.0.0.48/28"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "Private-Subnet-02"
  }
}

resource "aws_subnet" "private-subnet-03" {
  vpc_id     = aws_vpc.three-tier-vpc.id
  cidr_block = "10.0.0.64/28"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "Private-Subnet-03"
  }
}

resource "aws_subnet" "private-subnet-04" {
  vpc_id     = aws_vpc.three-tier-vpc.id
  cidr_block = "10.0.0.80/28"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "Private-Subnet-04"
  }
}