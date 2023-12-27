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

data "aws_caller_identity" "current" {}

data "aws_region"  "current" {}

data "template_file" "user_data_template" {
  template = file("${path.module}/templates/user_data_script.sh.tpl")
  vars = {
    max_players                 = "${var.max_players}"
    steam_query_port            = "${var.steam_query_port}"
    game_client_port            = "${var.game_client_port}"
    server_admin_password       = "${var.server_admin_password}"
    ark_session_name            = "${var.ark_session_name}"
    is_password_protected       = "${var.is_password_protected}"
    join_password               = "${var.join_password}"
    use_custom_gameusersettings = "${var.use_custom_gameusersettings}"
    custom_gameusersettings_s3  = var.use_custom_gameusersettings == true ? "${var.custom_gameusersettings_s3}" : false
    gameusersettings_bucket_arn = var.custom_gameusersettings_s3 == true ? "${aws_s3_bucket.ark.bucket}/${aws_s3_bucket_object.gameusersettings.key}" : null
    custom_gameusersettings_github  = var.use_custom_gameusersettings == true ? "${var.custom_gameusersettings_github}" : false
    # Can't use a local file and render into the template to be placed into a file because the allowable length of user_data will be exceeded
    game_user_settings_ini_path = var.use_custom_gameusersettings == true ? "${var.game_user_settings_ini_path}" : null
    # Can't use a local file and render into the template to be placed into a file because the allowable length of user_data will be exceeded
    #gameusersettings_contents   = var.use_custom_gameusersettings == true ? file("${var.game_user_settings_ini_path}") : null
  }
}