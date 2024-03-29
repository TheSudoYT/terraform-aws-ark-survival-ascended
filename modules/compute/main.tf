resource "aws_key_pair" "ssh_key" {
  count = var.create_ssh_key == true ? 1 : 0

  key_name   = var.ssh_key_name
  public_key = file(var.ssh_public_key)
}

resource "aws_instance" "ark_server" {

  lifecycle {
    precondition {
      condition     = var.use_custom_gameusersettings == true ? var.use_custom_gameusersettings == true && var.custom_gameusersettings_s3 == true && var.custom_gameusersettings_github == false || var.use_custom_gameusersettings == true && var.custom_gameusersettings_s3 == false && var.custom_gameusersettings_github == true : var.use_custom_gameusersettings == false && var.custom_gameusersettings_s3 == false && var.custom_gameusersettings_github == false
      error_message = "Cannot use a custom GameUserSettings.ini file from s3 and github at the same time OR you have custom_gameusersettings_s3 defined but use_custom_gameusersettings false."
    }

    precondition {
      condition     = var.use_custom_game_ini == true ? var.use_custom_game_ini == true && var.custom_gameini_s3 == true && var.custom_gameini_github == false || var.use_custom_game_ini == true && var.custom_gameini_s3 == false && var.custom_gameini_github == true : var.use_custom_game_ini == false && var.custom_gameini_s3 == false && var.custom_gameini_github == false
      error_message = "Cannot use a custom Game.ini file from s3 and github at the same time OR you have custom_game_s3 defined but use_custom_game_ini false."
    }
  }

  ami                    = var.ami_id != null ? var.ami_id : data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.create_ssh_key == true ? aws_key_pair.ssh_key[0].key_name : var.existing_ssh_key_name
  subnet_id              = var.ark_subnet_id
  vpc_security_group_ids = [var.ark_security_group_id]

  user_data = data.template_file.user_data_template.rendered

  iam_instance_profile = var.custom_gameusersettings_s3 == true && length(aws_iam_instance_profile.instance_profile) > 0 || var.custom_gameini_s3 == true && length(aws_iam_instance_profile.instance_profile) > 0 || var.enable_session_manager == true ? aws_iam_instance_profile.instance_profile[0].name : null


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

check "ge_proton_version_check" {
  data "http" "ge_proton" {
    url = "https://github.com/GloriousEggroll/proton-ge-custom/releases/tag/GE-Proton${var.ge_proton_version}"
  }

  assert {
    condition     = data.http.ge_proton.status_code == 200
    error_message = "${data.http.ge_proton.url} returned an unhealthy status code for version ${var.ge_proton_version}"
  }
}
