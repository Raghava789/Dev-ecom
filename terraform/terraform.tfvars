cluster_name    = "ecom-eks-cluster"
cluster_version = "1.31"

# vpc_cidr         = "10.0.0.0/16"
# public_subnets   = ["10.0.1.0/24", "10.0.2.0/24"]
# private_subnets  = ["10.0.3.0/24", "10.0.4.0/24"]
# azs              = ["us-east-1a", "us-east-1b"]

ec2_ssh_key_name = "ecom-key"

eks_node_group = {
  ecom-ng = {
    instance_type = ["t3.large"]
    capacity_type = "SPOT"
    scaling_config = {
      min_size     = 1
      max_size     = 3
      desired_size = 2
    }
  }
}

#jenkins_role_arn = "arn:aws:iam::123456789012:role/jenkins-eks-role"  # Update with your actual role ARN
