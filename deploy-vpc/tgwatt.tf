data "aws_ec2_transit_gateway" "netsrvc-tgw" {
  id = "tgw-0cee261f107a0c8d6"  
}

resource "aws_ec2_transit_gateway_vpc_attachment" "tgwatt" {
  //subnet_ids         = [aws_subnet.private_subnets.id]
  subnet_ids         = module.vpc.private_subnets
  transit_gateway_id = data.aws_ec2_transit_gateway.netsrvc-tgw.id
  vpc_id             = module.vpc.vpc_id
}