resource "aws_key_pair" "ssh_key" {
  count = var.create_ssh_key == true ? 1 : 0

  key_name   = var.ssh_key_name
  public_key = file(var.ssh_public_key)
}

# Allow inbound traffic to the EC2 instance on necessary ports
resource "aws_security_group_rule" "allow_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = var.ssh_ingress_allowed_cidr
  security_group_id = var.ark_security_group_id
}

resource "aws_instance" "ark_server" {
  ami                    = var.ami_id != null ? var.ami_id : data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.create_ssh_key == true ? aws_key_pair.ssh_key[0].key_name : var.existing_ssh_key_name
  subnet_id              = var.ark_subnet_id
  vpc_security_group_ids = [var.ark_security_group_id]

  user_data = data.template_file.user_data_template.rendered

  root_block_device {
    volume_size = var.ebs_volume_size
  }

  tags = {
    Name = var.ark_session_name
  }
}

resource "aws_eip" "ark_server_ip" {
  instance = aws_instance.ark_server.id
}
