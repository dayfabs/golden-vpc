
The  golden VPC Module is a deployment template for VPCs within TCH's cloud enviroment. Below is the example of the contents that go into the main.tf file
in other to create the VPC. The module is designed for repeateable deployment in any of either dev, test or prod enviroment.

NOTE:
As shown below, this terraform template will create new EIPs and destroy them when the "terraform destroy" command is used. In other to persit EIPs in
cases where the Ip addresses need to be whitelisted
1. Simply pre-assign the ip addresses in the AWS account
2. Assign the ip and the allocation ID as shown in lines 27 and line 28 and uncomment them
3. Comment out line 29 and line 38-42

# AWS VPC Terraform module

Terraform module which creates VPC resources on AWS.

## Usage

```hcl
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "vpc-use1-dev-ixbp"
  cidr = "10.209.64.0/23"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  tgwsubnet_subnets = ["10.209.65.192/26", "10.209.65.208/26", "10.209.65.224/26"]
  private_subnets = ["10.209.64.192/26", "10.209.65.0/26", "10.209.65.64/26"]
  public_subnets  = ["10.209.64.0/26", "10.209.64.64/26", "10.209.64.128/26"]

  enable_nat_gateway = true
  enable_vpn_gateway = true
  reuse_nat_ips      = true 
  
 // external_nat_ips    = ["1.2.3.4", "5.6.7.8", "9.10.11.12"]   # Enter in pre-assigned EIPS here and allocation ID below to persist IPs
 // external_nat_ip_ids = ["eipalloc-08e18b9e5cb11e437", "eipalloc-028aaed034d5fd425","eipalloc-052544099b2944cd6"]  
  external_nat_ip_ids = "${aws_eip.nat.*.id}"   # <= IPs specified here as input to the module (Use this when you need to deploy EIP for the first time)

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}
```
## External NAT Gateway IPs

By default this module will provision new Elastic IPs for the VPC's NAT Gateways.
This means that when creating a new VPC, new IPs are allocated, and when that VPC is destroyed those IPs are released.
Sometimes it is handy to keep the same IPs even after the VPC is destroyed and re-created.
To that end, it is possible to assign existing IPs to the NAT Gateways.
This prevents the destruction of the VPC from releasing those IPs, while making it possible that a re-created VPC uses the same IPs.

To achieve this, allocate the IPs outside the VPC module declaration.

```hcl
resource "aws_eip" "nat" {
  count = 3

  vpc = true
}
```

Then, pass the allocated IPs as a parameter to this module.

```hcl
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  # The rest of arguments are omitted for brevity

  enable_nat_gateway  = true
  single_nat_gateway  = false
  reuse_nat_ips       = true                    # <= Skip creation of EIPs for the NAT Gateways
  external_nat_ip_ids = "${aws_eip.nat.*.id}"   # <= IPs specified here as input to the module
}
```

Note that in the example we allocate 3 IPs because we will be provisioning 3 NAT Gateways (due to `single_nat_gateway = false` and having 3 subnets).
If, on the other hand, `single_nat_gateway = true`, then `aws_eip.nat` would only need to allocate 1 IP.
Passing the IPs into the module is done by setting two variables `reuse_nat_ips = true` and `external_nat_ip_ids = "${aws_eip.nat.*.id}"`.

## NAT Gateway Scenarios

This module supports three scenarios for creating NAT gateways. Each will be explained in further detail in the corresponding sections.

- One NAT Gateway per subnet (default behavior)
  - `enable_nat_gateway = true`
  - `single_nat_gateway = false`
  - `one_nat_gateway_per_az = false`
  - 
- Single NAT Gateway
  - `enable_nat_gateway = true`
  - `single_nat_gateway = true`
  - `one_nat_gateway_per_az = false`
  - 
- One NAT Gateway per availability zone
  - `enable_nat_gateway = true`
  - `single_nat_gateway = false`
  - `one_nat_gateway_per_az = true`

If both `single_nat_gateway` and `one_nat_gateway_per_az` are set to `true`, then `single_nat_gateway` takes precedence.

### One NAT Gateway per subnet (default)

By default, the module will determine the number of NAT Gateways to create based on the the `max()` of the private subnet lists (`database_subnets`, `elasticache_subnets`, `private_subnets`, and `redshift_subnets`). The module **does not** take into account the number of `intra_subnets`, since the latter are designed to have no Internet access via NAT Gateway. For example, if your configuration looks like the following:


## VPC Flow Log

VPC Flow Log allows to capture IP traffic for a specific network interface (ENI), subnet, or entire VPC. This module supports enabling or disabling VPC Flow Logs for entire VPC. If you need to have VPC Flow Logs for subnet or ENI, you have to manage it outside of this module with [aws_flow_log resource](https://www.terraform.io/docs/providers/aws/r/flow_log.html).

### VPC Flow Log Examples

By default `file_format` is `plain-text`. You can also specify `parquet` to have logs written in Apache Parquet format.

```
flow_log_file_format = "parquet"
```


## Network Access Control Lists (ACL or NACL)

This module can manage network ACL and rules. Once VPC is created, AWS creates the default network ACL, which can be controlled using this module (`manage_default_network_acl = true`).

Also, each type of subnet may have its own network ACL with custom rules per subnet. Eg, set `public_dedicated_network_acl = true` to use dedicated network ACL for the public subnets; set values of `public_inbound_acl_rules` and `public_outbound_acl_rules` to specify all the NACL rules you need to have on public subnets (see `variables.tf` for default values and structures).

By default, all subnets are associated with the default network ACL.


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.63 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.63 |

