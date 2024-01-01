module "ark_vpc" {
  source = "./modules/networking"
}

module "ark_compute" {
  source = "./modules/compute"

  // Infrastructure inputs
  instance_type         = "t3.xlarge"
  ark_security_group_id = module.ark_vpc.security_group_id
  ark_subnet_id         = module.ark_vpc.subnet_id
  create_ssh_key        = true
  ssh_public_key        = "ark_public_key.pub"
  // Ark Application inputs
  ark_session_name      = "ark-aws-ascended"
  max_players           = "32"
  steam_query_port      = 27015
  game_client_port      = 7777
  server_admin_password = "RockwellSucks"
  is_password_protected = true
  join_password         = "RockWellSucks"
  // Custom GameUserSettings.ini inputs
  use_custom_gameusersettings        = true
  custom_gameusersettings_s3         = true
  game_user_settings_ini_path        = "GameUserSettings.ini"
  custom_gameusersettings_github     = false
  custom_gameusersettings_github_url = ""
  // Custom Game.ini inputs
  use_custom_game_ini       = true
  custom_gameini_s3         = true
  game_ini_path             = "Game.ini"
  custom_gameini_github     = false
  custom_gameini_github_url = ""
  // Backup inputs
  enable_s3_backups               = false
  backup_s3_bucket_name           = module.ark_backup.backup_s3_bucket_name
  backup_s3_bucket_arn            = module.ark_backup.backup_s3_bucket_arn
  backup_interval_cron_expression = "*/5 * * * *"
}

module "ark_backup" {
  source = "./modules/backup"

  create_backup_s3_bucket    = false
  s3_bucket_backup_retention = 7
  force_destroy              = true
}