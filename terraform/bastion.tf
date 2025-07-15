resource "aws_instance" "bastion_host" {
  ami                    = data.aws_ami.os_image.id
  instance_type          = var.instance_type
  key_name               = var.ec2_ssh_key_name
  vpc_security_group_ids = [aws_security_group.allow_user_bastion.id]
  subnet_id = module.vpc.public_subnet_ids[0]
  user_data              = file("${path.module}/bastion_user_data.sh")
  tags = {
    Name = "Bastion-Host"
  }
  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

}

resource "aws_security_group" "allow_user_bastion" {
  name        = "bastion-host-sg"
  description = "Allow SSH from trusted IP"
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
    Name = "bastion-sg"
  }
}