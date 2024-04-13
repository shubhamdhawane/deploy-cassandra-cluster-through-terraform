#vpc code

resource "aws_vpc" "skyage" {
  cidr_block = "172.16.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "skyage-vpc"
  }
}

resource "aws_subnet" "public_subnet1" {
  vpc_id                  = aws_vpc.skyage.id
  cidr_block              = "172.16.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "PublicSubnet1"
  }
}


resource "aws_subnet" "private_subnet1" {
  vpc_id                  = aws_vpc.skyage.id
  cidr_block              = "172.16.2.0/24"
  availability_zone       = "us-east-1a"

  tags = {
    Name = "PrivateSubnet1"
  }
}

resource "aws_subnet" "private_subnet2" {
  vpc_id                  = aws_vpc.skyage.id
  cidr_block              = "172.16.3.0/24"
  availability_zone       = "us-east-1b"

  tags = {
    Name = "PrivateSubnet2"
  }
}


# Internet Gateway
resource "aws_internet_gateway" "skyage_igw" {
  vpc_id = aws_vpc.skyage.id
  tags = {
    "Name" = "skyage-igw"
  }
}
# Create Elastic IP for NAT Gateway
resource "aws_eip" "nat_eip" {
  vpc = true
}

# Nat Gateway
resource "aws_nat_gateway" "skyage-nat-gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet1.id
  tags = {
    Name = "skyage-nat-gw"
  }
  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.skyage_igw]
}

######################################################
# public route table
# public subnets association into public route table
# Add Internet Gateway into public route table
######################################################
# public route table
resource "aws_route_table" "skyage-public-rt" {
  vpc_id = aws_vpc.skyage.id
  tags = {
    "Name" = "public-rt"
  }
}

# Associate both public subnets with public route table
resource "aws_route_table_association" "public_subnet_association-1" {
  route_table_id = aws_route_table.skyage-public-rt.id
  subnet_id      = aws_subnet.public_subnet1.id
}



# Add Internet Gateway into public route table
resource "aws_route" "skyage-route-igw" {
  route_table_id         = aws_route_table.skyage-public-rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.skyage_igw.id
}


######################################################
# private route table
# private subnets association into private route table
# Add Nat Gateway into private route table
######################################################
# private route table
resource "aws_route_table" "skyage-private-rt" {
  vpc_id = aws_vpc.skyage.id
  tags = {
    "Name" = "private-rt"
  }
}

# Associate both private subnets with private route table
resource "aws_route_table_association" "private_subnet_association-1" {   
  route_table_id = aws_route_table.skyage-private-rt.id
  subnet_id      = aws_subnet.private_subnet1.id
}



# Add Nat Gateway into private route table
resource "aws_route" "skyage-route-nat-gw" {
  route_table_id         = aws_route_table.skyage-private-rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.skyage-nat-gw.id
}
