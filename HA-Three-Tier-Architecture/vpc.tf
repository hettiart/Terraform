# Create a VPC
resource "aws_vpc" "three-tier-vpc" {
  cidr_block = "10.0.0.0/16"
   tags = {
    Name = "Three-Tier-VPC"
  }
}