
The  golden VPC Module is a deployment template for VPCs within TCH's cloud enviroment. Below is the example of the contents that go into the main.tf file
in other to create the VPC. The module is designed for repeateable deployment in any of either dev, test or prod enviroment.

NOTE:
As shown below, this terraform template will create new EIPs and destroy them when the "terraform destroy" command is used. In other to persit EIPs in
cases where the Ip addresses need to be whitelisted
1. Simply pre-assign the ip addresses in the AWS account
2. Assign the ip and the allocation ID as shown in lines 27 and line 28 and uncomment them
3. Comment out line 29 and line 38-42

==========================================================================================================================================================
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
 // external_nat_ips    = ["1.2.3.4", "5.6.7.8", "9.10.11.12"]   # Enter in pre-assigned EIPS here(Allows the reuse of same IP for whitelisting purposes)
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


==========================================================================================================================================================
