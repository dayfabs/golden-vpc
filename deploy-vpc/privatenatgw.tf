 //azs                 = ["us-east-1a", "us-east-1b", "us-east-1c"]
locals {
  max_subnet_length = max(
    //length(var.private_subnets),
      length(module.vpc.private_subnets),
  )
  nat_gateway_count = var.single_nat_gateway ? 1 : var.one_nat_gateway_per_az ? length(var.azs) : local.max_subnet_length
}
//resource "aws_eip" "nat" {
  //count = var.create_vpc && var.enable_nat_gateway && false == var.reuse_nat_ips ? local.nat_gateway_count : 0

  //vpc = true

  //tags = merge(
    //{
      //"Name" = format(
        //"${var.name}-%s",
        //element(var.azs, var.single_nat_gateway ? 0 : count.index),
      //)
    //},
    //var.tags,
    //var.nat_eip_tags,
  //)
//}

resource "aws_nat_gateway" "this" {
  connectivity_type = "private"
  count = 3

  //allocation_id = element(
    //local.nat_gateway_ips,
    //var.single_nat_gateway ? 0 : count.index,
  //)


  subnet_id = element(
    //module.vpc.private_subnets[*].id,
    module.vpc.private_subnets[*],
    var.single_nat_gateway ? 0 : count.index,
  )
  //subnet_id = element(
    //aws_subnet.private[*].id,
    //var.single_nat_gateway ? 0 : count.index,
  //)

  tags = merge(
    {
      "Name" = format(
        "${var.name}-%s",
        element(var.azs, var.single_nat_gateway ? 0 : count.index),
      )
    },
    var.tags,
    //var.nat_gateway_tags,
  )

  //depends_on = [aws_internet_gateway.this]
}

resource "aws_route" "private_nat_gateway" {
  count = var.create_vpc && var.enable_nat_gateway ? local.nat_gateway_count : 0

  //route_table_id         = element(aws_route_table.private[*].id, count.index)
  route_table_id         = element(module.vpc.private_route_table_ids[*], count.index)
  destination_cidr_block = var.nat_gateway_destination_cidr_block
  nat_gateway_id         = element(aws_nat_gateway.this[*].id, count.index)

  timeouts {
    create = "5m"
  }
}

resource "aws_route" "default_tgw" {
  count = var.create_vpc && var.enable_nat_gateway ? local.nat_gateway_count : 0

  //route_table_id         = element(aws_route_table.private[*].id, count.index)
  route_table_id         = element(module.vpc.private_route_table_ids[*], count.index)
  destination_cidr_block = var.default_gateway_destination_cidr_block
  transit_gateway_id     = data.aws_ec2_transit_gateway.netsrvc-tgw.id

  timeouts {
    create = "5m"
  }
}