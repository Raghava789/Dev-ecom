module "vpc" {
  source            = "../modules/vpc"
  vpc_cidr          = var.vpc_cidr
  availability_zone = var.azs
  public_sub_cidr   = var.public_subnets
  private_sub_cidr  = var.private_subnets
  cluster_name      = var.cluster_name
}


# module "eks" {
#   source = "./modules/eks"
#   vpc_id = module.vpc.vpc_id
#   subnet_id = module.vpc.private_subnet_ids
#   cluster_name = var.cluster_name
#   cluster_version = var.cluster_version
#   eks_node_group = var.eks_node_group
# }

module "eks" {
  source = "../modules/eks"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  vpc_id          = module.vpc.vpc_id
  subnet_id       = module.vpc.private_subnet_ids

  eks_node_group = var.eks_node_group
  bastion_role_arn = aws_iam_role.bastion_role.arn

  # Optional: remote access
  remote_access_config = {
    ec2_ssh_key               = var.ec2_ssh_key_name
    source_security_group_ids = [aws_security_group.node_group_remote_access.id]
  }

  cluster_addons = var.cluster_addons

  jenkins_role_arn = aws_iam_role.jenkins_eks_role.arn
}

resource "aws_security_group" "node_group_remote_access" {
  name   = "eks-node-group-ssh-access"
  vpc_id = module.vpc.vpc_id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Ideally, replace with your trusted IP
  }

  egress {
    description = "Allow all egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

