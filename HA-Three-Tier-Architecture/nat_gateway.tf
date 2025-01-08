# NAT Gateway
resource "aws_nat_gateway" "nat-gateway" {
  allocation_id = aws_eip.nat-gateway-eip.id
  subnet_id     = aws_subnet.public-subnet-01.id

  tags = {
    Name = "NAT-Gateway"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.internet-gateway]
}

resource "aws_eip" "nat-gateway-eip" {
  domain = "vpc"

  tags = {
    Name = "Nat-Gateway-Eip"
  }
}
