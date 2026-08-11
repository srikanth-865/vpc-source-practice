resource "aws_vpc" "main" {
  cidr_block       =  var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_hostnames = true

  tags = merge (
    local.common_tags,
    var.vpc_tags
  )
    
  }

  resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags =  merge (
    local.common_tags,
    var.gw_tags
  )
    
  }

  resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidr)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidr[count.index]
  availability_zone   = slice(data.aws_availability_zones.available.names, 0, 2)[count.index]
  map_public_ip_on_launch = true

  tags = merge (
    local.common_tags,
    var.public_subnet_tags,
    {
      Name = "${local.common_name}-public- ${split("-",local.az_names[count.index])[2]}" # for split function we get specific "1a" so output is roboshop-dev-public-1a
    }
  )
    
}

resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidr)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidr[count.index]
  availability_zone   = slice(data.aws_availability_zones.available.names, 0, 2)[count.index]
 map_public_ip_on_launch = false
  tags = merge (
    local.common_tags,
    var.private_subnet_tags,
    {
      Name = "${local.common_name}-private- ${split("-",local.az_names[count.index])[2]}"
    }
  )
    
}

resource "aws_subnet" "database" {
  count = length(var.database_subnet_cidr)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.database_subnet_cidr[count.index]
  availability_zone   = slice(data.aws_availability_zones.available.names, 0, 2)[count.index]
  map_public_ip_on_launch = false
  tags = merge (
    local.common_tags,
    var.database_subnet_tags,
    {
      Name = "${local.common_name}-database- ${split("-",local.az_names[count.index])[2]}"
    }
  )
    
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    {

    Name = "${local.common_name}-Public"
    }
  )
  }

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
  {
  Name = "${local.common_name}-Private"
  }
  )
  }

  resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
  {
  Name = "${local.common_name}-database"
  }
  )
  }

  resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidr)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

 resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidr)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

 resource "aws_route_table_association" "database" {
  count = length(var.database_subnet_cidr)
  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database.id
}

resource "aws_eip" "nat" {
  domain   = "vpc"
  tags = merge (
    local.common_tags,
    {
      Name = "${local.common_name}-NAT"
    }
  )

  }

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name =  "${local.common_name}-NATgateway"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.main]
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"                # The destination network path
  gateway_id             = aws_internet_gateway.main.id   # The target gateway (or nat_gateway_id, transit_gateway_id, etc.)
}

resource "aws_route" "private" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"                # The destination network path ,.
  nat_gateway_id         = aws_nat_gateway.main.id   # The target gateway (or nat_gateway_id, transit_gateway_id, etc.)
}
resource "aws_route" "database" {
  route_table_id         = aws_route_table.database.id
  destination_cidr_block = "0.0.0.0/0"               
  nat_gateway_id            = aws_nat_gateway.main.id   
}


