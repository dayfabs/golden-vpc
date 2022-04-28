name = "vpc-use1-dev-ixbp"
enable_nat_gateway  = true

azs = ["us-east-1a", "us-east-1b", "us-east-1c"]

tags = {
    Terraform   = "true"
    Environment = "dev"
  }