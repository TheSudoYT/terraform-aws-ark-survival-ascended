data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "template_file" "user_data_template" {
  template = file("${path.module}/templates/user_data_script.sh.tpl")
  vars = {
    max_players           = "${var.max_players}"
    steam_query_port      = "${var.steam_query_port}"
    game_client_port      = "${var.game_client_port}"
    server_admin_password = "${var.server_admin_password}"
    ark_session_name      = "${var.ark_session_name}"
  }
}