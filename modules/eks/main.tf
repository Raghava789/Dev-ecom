resource "aws_eks_cluster" "eks_main_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.cluster_role.arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids = var.subnet_id
  }

  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_Policy
  ]
}

resource "aws_iam_role" "cluster_role" {
  name = "${var.cluster_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = ["sts:AssumeRole", "sts:TagSession"],
      Effect = "Allow",
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster_role.name
}

resource "aws_eks_node_group" "eks_node_group" {
  for_each = var.eks_node_group

  cluster_name    = aws_eks_cluster.eks_main_cluster.name
  node_group_name = "${var.cluster_name}-node-group"
  node_role_arn   = aws_iam_role.node_role.arn
  subnet_ids      = var.subnet_id

  instance_types = each.value.instance_type
  capacity_type  = each.value.capacity_type

  scaling_config {
    desired_size = each.value.scaling_config.desired_size
    max_size     = each.value.scaling_config.max_size
    min_size     = each.value.scaling_config.min_size
  }

  dynamic "remote_access" {
    for_each = var.remote_access_config != null ? [1] : []
    content {
      ec2_ssh_key               = var.remote_access_config.ec2_ssh_key
      source_security_group_ids = var.remote_access_config.source_security_group_ids
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.example-NodePolicy
  ]
}

resource "aws_iam_role" "node_role" {
  name = "eks-node-group-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "example-NodePolicy" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  ])

  policy_arn = each.value
  role       = aws_iam_role.node_role.name
}

resource "aws_eks_addon" "this" {
  for_each = var.cluster_addons

  cluster_name = aws_eks_cluster.eks_main_cluster.name
  addon_name   = each.key

  addon_version                  = try(each.value.addon_version, null)
  resolve_conflicts_on_create   = try(each.value.resolve_conflicts_on_create, "OVERWRITE")
  resolve_conflicts_on_update   = try(each.value.resolve_conflicts_on_update, "OVERWRITE")
  service_account_role_arn      = try(each.value.service_account_role_arn, null)

  depends_on = [aws_eks_cluster.eks_main_cluster]
}

resource "aws_eks_access_entry" "jenkins" {
  cluster_name  = aws_eks_cluster.eks_main_cluster.name
  principal_arn = var.jenkins_role_arn
}

resource "aws_eks_access_policy_association" "jenkins_admin" {
  cluster_name  = aws_eks_cluster.eks_main_cluster.name
  principal_arn = var.jenkins_role_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.jenkins]
}

# resource "aws_eks_access_entry" "bastion" {
#   cluster_name  = aws_eks_cluster.eks_main_cluster.name
#   principal_arn = aws_iam_role.bastion_role.arn
# }

resource "aws_eks_access_entry" "bastion" {
  cluster_name  = aws_eks_cluster.eks_main_cluster.name
  principal_arn = var.bastion_role_arn  
}

resource "aws_eks_access_policy_association" "bastion_admin" {
  cluster_name  = aws_eks_cluster.eks_main_cluster.name
  principal_arn = var.bastion_role_arn 
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.bastion]
}



data "aws_eks_cluster" "this" {
  name = aws_eks_cluster.eks_main_cluster.name
}

data "tls_certificate" "oidc_thumbprint" {
  url = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks_oidc" {
  url             = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.oidc_thumbprint.certificates[0].sha1_fingerprint]

  depends_on = [aws_eks_cluster.eks_main_cluster]
}

