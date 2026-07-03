// name, cidr_block, azs, private_subnets, public_subnets, enable_nat_gateway, single_nat_gateway, enable_vpn_gateway, tags

variable "name" {
  description = "The name of the VPC"
  type        = string
}

variable "cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "A list of availability zones in the region (min 2 for high availability)"
  type        = list(string)
}

variable "private_subnets" {
  description = "A list of private subnet CIDR blocks (must be the same length as azs)"
  type        = list(string)

}

variable "public_subnets" {
  description = "A list of public subnet CIDR blocks (must be the same length as azs)"
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "Whether to enable a NAT gateway for private subnets"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Whether to use a single NAT gateway for all private subnets (if true, only the first public subnet will be used for the NAT gateway) reduces cost but also reduces availability"
  type        = bool
  default     = false
}

variable "enable_vpn_gateway" {
  description = "Enable VPN gateway"
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to assign to the VPC and its resources"
  type        = map(string)
  default     = {}
}