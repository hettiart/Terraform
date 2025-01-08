# Internet Gateway
resource "aws_internet_gateway" "internet-gateway" {
  vpc_id =  aws_vpc.three-tier-vpc.id

  tags = {
    Name = "Internet-Gateway"
  }
}