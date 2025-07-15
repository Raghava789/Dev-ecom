data "aws_ami" "os_image" {
  owners      = ["099720109477"]
  most_recent = true
  filter {
    name   = "state"
    values = ["available"]
  }
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/*24.04-amd64*"]
  }
}

# resource "aws_key_pair" "deployer" {
#   key_name   = "terra-automate-key"
#   public_key = file("terra-key.pub")
# }

resource "aws_security_group" "allow_user_to_connect" {
  name        = "allow TLS"
  description = "Allow user to connect"
  vpc_id      = module.vpc.vpc_id
  dynamic "ingress" {
    for_each = var.bastion_sg
    content {
      description = ingress.value.description
      from_port   = ingress.value.from
      to_port     = ingress.value.to
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr
    }
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = {
    Name = "mysecurity"
  }
}

resource "aws_instance" "testinstance" {
  ami                    = data.aws_ami.os_image.id
  instance_type          = var.instance_type
  key_name               = var.ec2_ssh_key_name
  vpc_security_group_ids = [aws_security_group.allow_user_to_connect.id]
  subnet_id = module.vpc.public_subnet_ids[0]
  iam_instance_profile   = aws_iam_instance_profile.jenkins_profile.name
  user_data              = file("${path.module}/install_tools.sh")
  tags = {
    Name = "Jenkins-Automate"
  }
  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

}

resource "aws_iam_instance_profile" "jenkins_profile" {
  name = "jenkins-instance-profile"
  role = aws_iam_role.jenkins_eks_role.name
}


resource "aws_eip" "jenkins_server_ip" {
  instance = aws_instance.testinstance.id
  domain   = "vpc"
}
