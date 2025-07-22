variable "cluster_name" {
  description = "eks cluster name"
}

variable "cluster_version" {
  description = "eks cluster version"
}

variable "vpc_id" {
  description = "vpc ID"
}

variable "subnet_id"{
  description = "subnet ID"
  type = list(string)
}

variable "eks_node_group" {
  description = "eks node group"
  type = map(object({
    instance_type = list(string)
    capacity_type = string
    scaling_config = object({
      min_size = number
      max_size = number
      desired_size = number  
    })
  }))
}

variable "remote_access_config" {
  description = "Remote access SSH configuration"
  type = object({
    ec2_ssh_key               = string
    source_security_group_ids = list(string)
  })
  default = null
}

variable "cluster_addons" {
  description = "EKS addons to deploy"
  type        = map(any)
  default     = {}
}

variable "jenkins_role_arn" {
  description = "IAM role ARN for Jenkins"
  type        = string
}

variable "bastion_role_arn" {
  description = "IAM role ARN for Bastion host to access EKS"
  type        = string
}

