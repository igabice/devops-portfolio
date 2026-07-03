module "my_vpc" {
  source = "./.."

  name               = "my-vpc"
  cidr_block         = "10.0.0.0/16"
  azs                = ["us-east-1a", "us-east-1b"]
  private_subnets    = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets     = ["10.0.101.0/24", "10.0.102.0/24"]
  enable_nat_gateway = true
  single_nat_gateway = true # save cost in development environment, but not recommended for production

  tags = {
    Environment = "dev"
    Project     = "my-project"
    ManagedBy   = "terraform"
  }

}