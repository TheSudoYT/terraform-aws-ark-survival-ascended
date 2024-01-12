module "ark_vpc" {
  source = "./modules/networking"

  vpc_cidr_block           = var.vpc_cidr_block
  subnet_cidr_block        = var.subnet_cidr_block
  subnet_availability_zone = var.subnet_availability_zone
  enable_rcon              = var.enable_rcon
  rcon_port                = var.rcon_port
  steam_query_port         = var.steam_query_port
  game_client_port         = var.game_client_port
}

module "ark_compute" {
  source = "./modules/compute"

  // Infrastructure inputs
  auto_save_interval       = var.auto_save_interval
  ge_proton_version        = var.ge_proton_version
  instance_type            = var.instance_type
  ark_security_group_id    = module.ark_vpc.security_group_id
  ark_subnet_id            = module.ark_vpc.subnet_id
  create_ssh_key           = var.create_ssh_key
  ssh_public_key           = var.create_ssh_key == true ? var.ssh_public_key : ""
  existing_ssh_key_name    = var.existing_ssh_key_name
  ssh_key_name             = var.ssh_key_name
  ssh_ingress_allowed_cidr = var.ssh_ingress_allowed_cidr
  ami_id                   = var.ami_id
  ebs_volume_size          = var.ebs_volume_size
  // Ark Application inputs
  ark_session_name      = var.ark_session_name
  max_players           = var.max_players
  steam_query_port      = var.steam_query_port
  game_client_port      = var.game_client_port
  enable_rcon           = var.enable_rcon
  rcon_port             = var.rcon_port
  server_admin_password = var.server_admin_password
  is_password_protected = var.is_password_protected
  join_password         = var.join_password
  // Custom GameUserSettings.ini inputs
  use_custom_gameusersettings        = var.use_custom_gameusersettings
  custom_gameusersettings_s3         = var.custom_gameusersettings_s3
  game_user_settings_ini_path        = var.game_user_settings_ini_path
  custom_gameusersettings_github     = var.custom_gameusersettings_github
  custom_gameusersettings_github_url = var.custom_gameusersettings_github_url
  // Custom Game.ini inputs
  use_custom_game_ini       = var.use_custom_game_ini
  custom_gameini_s3         = var.custom_gameini_s3
  game_ini_path             = var.game_ini_path
  custom_gameini_github     = var.custom_gameini_github
  custom_gameini_github_url = var.custom_gameini_github_url
  // Backup inputs
  enable_s3_backups               = var.enable_s3_backups
  backup_s3_bucket_name           = var.enable_s3_backups == true ? module.ark_backup.backup_s3_bucket_name[0] : ""
  backup_s3_bucket_arn            = var.enable_s3_backups == true ? module.ark_backup.backup_s3_bucket_arn[0] : ""
  backup_interval_cron_expression = var.backup_interval_cron_expression
}

module "ark_backup" {
  source = "./modules/backup"

  create_backup_s3_bucket    = var.create_backup_s3_bucket
  s3_bucket_backup_retention = var.s3_bucket_backup_retention
  force_destroy              = var.force_destroy
}

# maybe try just using data to look it up instead of getting a return
# data "http" "example" {
#   count = var.custom_gameusersettings_s3 == true || var.custom_gameini_s3 == true ? 1 : 0
#   url = "s3://${module.ark_compute.gameusersettings_s3_bucket[0]}/${module.ark_compute.custom_gameusersettings_file_name[0]}"
# }

# locals {

# }