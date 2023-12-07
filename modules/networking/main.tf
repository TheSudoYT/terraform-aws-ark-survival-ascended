locals {
  // raw UDP port is always 1 above the game client port
  computed_raw_udp_port = var.game_client_port + 1
}

resource "aws_vpc" "ark_vpc" {
  cidr_block = var.vpc_cidr_block
}

resource "aws_subnet" "ark_subnet" {
  vpc_id            = aws_vpc.ark_vpc.id
  cidr_block        = var.subnet_cidr_block
  availability_zone = var.subnet_availability_zone
}

resource "aws_security_group" "ark_security_group" {
  vpc_id = aws_vpc.ark_vpc.id

  // Game client port
  ingress {
    from_port   = var.game_client_port
    to_port     = var.game_client_port
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // Raw UDP Socket port. Always game client port +1
  ingress {
    from_port   = local.computed_raw_udp_port
    to_port     = local.computed_raw_udp_port
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // Query port for steam's server browser
  // Query Port cannot be between 27020 and 27050 due to Steam using those ports
  ingress {
    from_port   = var.steam_query_port
    to_port     = var.steam_query_port
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // RCON port if enabled
  dynamic "ingress" {
    for_each = var.enable_rcon ? [1] : []
    content {
      from_port   = var.rcon_port
      to_port     = var.rcon_port
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

}

