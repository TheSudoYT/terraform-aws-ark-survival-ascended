module "ark_vpc" {
  source = "./modules/networking"
}

module "ark_compute" {
  source = "./modules/compute"

  instance_type                  = "t3.xlarge"
  ark_security_group_id          = module.ark_vpc.security_group_id
  ark_subnet_id                  = module.ark_vpc.subnet_id
  create_ssh_key                 = true
  ssh_public_key                 = "ark_public_key.pub"
  ark_session_name               = "ark-aws-ascended"
  max_players                    = "32"
  steam_query_port               = 27015
  game_client_port               = 7777
  server_admin_password          = "RockwellSucks"
  is_password_protected          = true
  join_password                  = "RockWellSucks"
  use_custom_gameusersettings    = true
  custom_gameusersettings_s3     = true
  custom_gameusersettings_github = false
  # Can't use a local file and render into the template to be placed into a file because the allowable length of user_data will be exceeded
  game_user_settings_ini_path = "GameUserSettings.ini"
}

module "ark_backup" {
  source = "./modules/backup"
}