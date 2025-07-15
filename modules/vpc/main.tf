resource "aws_vpc" "vpc_main" {
  cidr_block       = var.vpc_cidr
  enable_dns_support   = true     # Enables DNS resolution
  enable_dns_hostnames = true     # Assigns DNS names

  tags = {
    Name = "${var.cluster_name}-vpc"
  }
}

resource "aws_subnet" "public_sub" {
  count      = length(var.public_sub_cidr)
  vpc_id     = aws_vpc.vpc_main.id
  cidr_block = var.public_sub_cidr[count.index]
  availability_zone = var.availability_zone[count.index]

  map_public_ip_on_launch = true

  tags = {
    Name = "${var.cluster_name}-public-${count.index + 1}"
    "kubernetes.io/cluster/${var.cluster_name}"    = "shared"
    "kubernetes.io/role/elb"                       = "1"
  }
}

resource "aws_subnet" "private_sub" {
  count = length(var.private_sub_cidr)
  vpc_id     = aws_vpc.vpc_main.id
  cidr_block = var.private_sub_cidr[count.index]
  availability_zone = var.availability_zone[count.index]

  tags = {
    Name = "${var.cluster_name}-private-${count.index + 1}"
    "kubernetes.io/cluster/${var.cluster_name}"    = "shared"
    "kubernetes.io/role/internal-elb"              = "1"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc_main.id

  tags = {
    Name = "${var.cluster_name}-igw"
  }
}

resource "aws_route_table" "pub_rt" {
  vpc_id = aws_vpc.vpc_main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "${var.cluster_name}-public-rt"
  }
}

resource "aws_route_table_association" "igw_pub_asso" {
  count = length(var.public_sub_cidr)
  subnet_id      = aws_subnet.public_sub[count.index].id
  route_table_id = aws_route_table.pub_rt.id
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_sub[0].id

  tags = {
    Name = "${var.cluster_name}-nat"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.gw]
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.vpc_main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }
}

resource "aws_route_table_association" "nat_pvt_asso" {
  count = length(var.private_sub_cidr)
  subnet_id      = aws_subnet.private_sub[count.index].id
  route_table_id = aws_route_table.private_rt.id
}





