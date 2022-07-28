# VPC
resource "aws_vpc" "homework1_vpc" {
  cidr_block       = var.vpc_cidr
  tags = {
    Name = "Homework1_VPC"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "homework1_igw" {
  vpc_id = aws_vpc.homework1_vpc.id
  tags = {
    Name = "main"
  }
}

# Subnets : public
resource "aws_subnet" "public" {
  count = length(var.subnets_cidr)
  vpc_id = aws_vpc.homework1_vpc.id
  cidr_block = element(var.subnets_cidr,count.index)
  availability_zone = element(var.azs,count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "Subnet-${count.index+1}"
  }
}

# Route table: attach Internet Gateway 
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.homework1_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.homework1_igw.id
  }
  tags = {
    Name = "publicRouteTable"
  }
}

# Route table association with public subnets
resource "aws_route_table_association" "a" {
  count = length(var.subnets_cidr)
  subnet_id      = element(aws_subnet.public.*.id,count.index)
  route_table_id = aws_route_table.public_rt.id
}



resource "aws_security_group" "dokuwiki-sg" {
  vpc_id = aws_vpc.homework1_vpc.id
  name = "dokuwiki-sg"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
