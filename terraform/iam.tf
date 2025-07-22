resource "aws_iam_role" "jenkins_eks_role" {
  name = "jenkins-eks-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "jenkins_eks_policy_attach" {
  role       = aws_iam_role.jenkins_eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

output "jenkins_role_arn" {
  description = "IAM role ARN to be used by Jenkins to access EKS"
  value       = aws_iam_role.jenkins_eks_role.arn
}

resource "aws_iam_role" "bastion_role" {
  name = "bastion-eks-access-role"

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

# resource "aws_iam_role_policy_attachment" "bastion_access" {
#   policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAccessPolicy"
#   role       = aws_iam_role.bastion_role.name
# }

resource "aws_iam_instance_profile" "bastion_profile" {
  name = "bastion-profile"
  role = aws_iam_role.bastion_role.name
}

resource "aws_iam_role_policy_attachment" "bastion_access" {
  role       = aws_iam_role.bastion_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

