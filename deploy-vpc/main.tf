module "vpc" {
  source = "../module/module_vpc"

  name = "vpc-use1-dev-ixbp"
  cidr = "10.209.64.0/23"

  azs                 = ["us-east-1a", "us-east-1b", "us-east-1c"]
  tgwsubnet_subnets   = ["10.209.65.192/28", "10.209.65.208/28", "10.209.65.224/28"]
  private_subnets     = ["10.209.64.192/26", "10.209.65.0/26", "10.209.65.64/26"]
  public_subnets      = ["10.209.64.0/26", "10.209.64.64/26", "10.209.64.128/26"]

  enable_nat_gateway  = true
  enable_vpn_gateway  = true
  reuse_nat_ips       = true                   # <= Skip creation of EIPs for the NAT Gateways
 // external_nat_ips    = ["3.213.215.153", "18.210.140.65", "52.4.16.101"]   # Enter in pre-assigned EIPS here(Allows the reuse of same IP for whitelisting purposes)
 // external_nat_ip_ids = ["eipalloc-08e18b9e5cb11e437", "eipalloc-028aaed034d5fd425","eipalloc-052544099b2944cd6"]     # Enter in pre-assigned EIP ids here(Allows the reuse of same IP for whitelisting purposes)
  external_nat_ip_ids = "${aws_eip.nat.*.id}"   # <= IPs specified here as input to the module (Use this when you need to deploy EIP for the first time
  

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "aws_eip" "nat" {
count = 3

vpc = true
}
