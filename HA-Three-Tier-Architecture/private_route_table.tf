# Route Tables
resource "aws_route_table" "private-subnet-app-rt" {
  vpc_id = aws_vpc.three-tier-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gateway.id
  }

  tags = {
    Name = "Private-Subnet-App-RT"
  }
}

# Private route table association
resource "aws_route_table_association" "rt-association-pri-sub-01" {
  subnet_id      = aws_subnet.private-subnet-01.id
  route_table_id = aws_route_table.private-subnet-app-rt.id
}

resource "aws_route_table_association" "rt-association-pri-sub-02" {
  subnet_id      = aws_subnet.private-subnet-02.id
  route_table_id = aws_route_table.private-subnet-app-rt.id
}

resource "aws_route_table_association" "rt-association-pri-sub-03" {
  subnet_id      = aws_subnet.private-subnet-03.id
  route_table_id = aws_route_table.private-subnet-app-rt.id
}

resource "aws_route_table_association" "rt-association-pri-sub-04" {
  subnet_id      = aws_subnet.private-subnet-04.id
  route_table_id = aws_route_table.private-subnet-app-rt.id
}