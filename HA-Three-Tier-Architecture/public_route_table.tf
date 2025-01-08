# Route Tables
resource "aws_route_table" "public-subnet-web-rt" {
  vpc_id = aws_vpc.three-tier-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet-gateway.id
  }

  tags = {
    Name = "Public-Subnet-Web-RT"
  }
}

# Public route table association
resource "aws_route_table_association" "rt-association-pub-sub-01" {
  subnet_id      = aws_subnet.public-subnet-01.id
  route_table_id = aws_route_table.public-subnet-web-rt.id
}

resource "aws_route_table_association" "rt-association-pub-sub-02" {
  subnet_id      = aws_subnet.public-subnet-02.id
  route_table_id = aws_route_table.public-subnet-web-rt.id
}