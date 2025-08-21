variable "vpc_name" {
  default = "tws-vpc"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "azs" {
  default = ["ap-south-1a", "ap-south-1b"]
}

variable "public_subnets" {
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  default = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "cluster_name" {
  default = "ECOM-clus"
}

variable "cluster_version" {
  description = "cluster version"
  default     = "1.30"
}

variable "eks_node_group" {
  description = "eks node group"

  type = map(object({
    instance_type = list(string)
    capacity_type = string
    scaling_config = object({
      min_size     = number
      max_size     = number
      desired_size = number
    })
  }))
}

variable "instance_type" {
  description = "Instance type for the EC2 instance"
  default     = "t3.medium"
}

variable "bastion_sg" {
  description = "bastion-host-sg"
  type = list(object({
    description = string
    from        = number
    to          = number
    protocol    = string
    cidr        = list(string)
  }))

  default = [
    { description = "port 22", from = 22, to = 22, protocol = "tcp", cidr = ["0.0.0.0/0"] },
    { description = "port 80", from = 80, to = 80, protocol = "tcp", cidr = ["0.0.0.0/0"] },
    { description = "port 443", from = 443, to = 443, protocol = "tcp", cidr = ["0.0.0.0/0"] },
    { description = "port 443", from = 8080, to = 8080, protocol = "tcp", cidr = ["0.0.0.0/0"] }
  ]
}

variable "ec2_ssh_key_name" {
  description = "ssh key name"
}

variable "cluster_addons" {
  description = "Map of EKS addons to enable"
  type = map(object({
    addon_version                = optional(string)
    resolve_conflicts_on_create = optional(string, "OVERWRITE")
    resolve_conflicts_on_update = optional(string, "OVERWRITE")
    service_account_role_arn    = optional(string)
  }))
}

