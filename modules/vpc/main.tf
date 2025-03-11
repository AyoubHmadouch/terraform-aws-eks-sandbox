# modules/vpc/main.tf
data "aws_availability_zones" "available" {}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, var.az_num)
  public_subnets = [for i in range(var.az_num) : {
    cidr_block = cidrsubnet(var.cidr_block, 8, i)
    az         = local.azs[i]
  }]
  private_subnets = [for i in range(var.az_num) : {
    cidr_block = cidrsubnet(var.cidr_block, 8, i + var.az_num)
    az         = local.azs[i]
  }]
}

resource "aws_vpc" "self" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = join("-", compact([var.vpc_prefix, "vpc"]))
  }
}

resource "aws_internet_gateway" "self" {
  vpc_id = aws_vpc.self.id
  tags = {
    Name = join("-", compact([var.vpc_prefix, "igw"]))
  }
}

resource "aws_subnet" "public" {
  for_each                = { for subnet in local.public_subnets : subnet.az => subnet }
  vpc_id                  = aws_vpc.self.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.az
  map_public_ip_on_launch = true
  tags = {
    Name                     = join("-", compact([var.vpc_prefix, "public-subnet", each.value.az]))
    "kubernetes.io/role/elb" = 1
  }
}

resource "aws_subnet" "private" {
  for_each                = { for subnet in local.private_subnets : subnet.az => subnet }
  vpc_id                  = aws_vpc.self.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.az
  map_public_ip_on_launch = false
  tags = {
    Name                              = join("-", compact([var.vpc_prefix, "private-subnet", each.value.az]))
    "kubernetes.io/role/internal-elb" = 1
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.self.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.self.id
  }

  tags = {
    Name = join("-", compact([var.vpc_prefix, "public-rtb"]))
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.self.id

  dynamic "route" {
    for_each = var.nat_enabled ? [aws_nat_gateway.self[0]] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = route.value.id
    }
  }

  tags = {
    Name = join("-", compact([var.vpc_prefix, "private-rtb"]))
  }
}

resource "aws_route_table_association" "private" {
  for_each       = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}

resource "aws_eip" "public_nat" {
  count = var.nat_enabled ? 1 : 0

  tags = {
    Name = join("-", compact([var.vpc_prefix, "nat-eip"]))
  }
}

resource "aws_nat_gateway" "self" {
  count         = var.nat_enabled ? 1 : 0
  allocation_id = aws_eip.public_nat[0].id
  subnet_id     = aws_subnet.public[local.azs[0]].id
  depends_on    = [aws_internet_gateway.self]

  tags = {
    Name = join("-", compact([var.vpc_prefix, "nat"]))
  }
}
