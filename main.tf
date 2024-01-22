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

  # Infrastructure inputs
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
  # Ark Application inputs
  mod_list                   = var.mod_list
  supported_server_platforms = var.supported_server_platforms
  use_battleye               = var.use_battleye
  auto_save_interval         = var.auto_save_interval
  ark_session_name           = var.ark_session_name
  max_players                = var.max_players
  steam_query_port           = var.steam_query_port
  game_client_port           = var.game_client_port
  enable_rcon                = var.enable_rcon
  rcon_port                  = var.rcon_port
  server_admin_password      = var.server_admin_password
  is_password_protected      = var.is_password_protected
  join_password              = var.join_password
  # Custom GameUserSettings.ini inputs
  use_custom_gameusersettings        = var.use_custom_gameusersettings
  custom_gameusersettings_s3         = var.custom_gameusersettings_s3
  game_user_settings_ini_path        = var.game_user_settings_ini_path
  custom_gameusersettings_github     = var.custom_gameusersettings_github
  custom_gameusersettings_github_url = var.custom_gameusersettings_github_url
  # Custom Game.ini inputs
  use_custom_game_ini       = var.use_custom_game_ini
  custom_gameini_s3         = var.custom_gameini_s3
  game_ini_path             = var.game_ini_path
  custom_gameini_github     = var.custom_gameini_github
  custom_gameini_github_url = var.custom_gameini_github_url
  # Backup inputs
  enable_s3_backups                            = var.enable_s3_backups
  backup_s3_bucket_name                        = var.enable_s3_backups == true && var.create_backup_s3_bucket == true ? module.ark_backup.backup_s3_bucket_name[0] : var.backup_s3_bucket_name
  backup_s3_bucket_arn                         = var.enable_s3_backups == true && var.create_backup_s3_bucket == true ? module.ark_backup.backup_s3_bucket_arn[0] : var.backup_s3_bucket_arn
  backup_interval_cron_expression              = var.backup_interval_cron_expression
  taming_speed_multiplier                      = var.taming_speed_multiplier
  xp_multiplier                                = var.xp_multiplier
  server_pve                                   = var.server_pve
  admin_logging                                = var.admin_logging
  allow_anyone_baby_imprint_cuddle             = var.allow_anyone_baby_imprint_cuddle
  allow_flyer_carry_pve                        = var.allow_flyer_carry_pve
  allow_raid_dino_feeding                      = var.allow_raid_dino_feeding
  allow_third_person_player                    = var.allow_third_person_player
  always_allow_structure_pickup                = var.always_allow_structure_pickup
  clamp_resource_harvest_damage                = var.clamp_resource_harvest_damage
  day_cycle_speed_scale                        = var.day_cycle_speed_scale
  night_time_speed_scale                       = var.night_time_speed_scale
  day_time_speed_scale                         = var.day_time_speed_scale
  difficulty_offset                            = var.difficulty_offset
  dino_character_food_drain_multiplier         = var.dino_character_food_drain_multiplier
  dino_character_health_recovery_multiplier    = var.dino_character_health_recovery_multiplier
  dino_character_stamina_drain_multiplier      = var.dino_character_stamina_drain_multiplier
  dino_damage_multiplier                       = var.dino_damage_multiplier
  dino_resistance_multiplier                   = var.dino_resistance_multiplier
  disable_dino_decay_pve                       = var.disable_dino_decay_pve
  disable_imprint_dino_buff                    = var.disable_imprint_dino_buff
  disable_pve_gamma                            = var.disable_pve_gamma
  enable_pvp_gamma                             = var.enable_pvp_gamma
  disable_structure_decay_pve                  = var.disable_structure_decay_pve
  disable_weather_fog                          = var.disable_weather_fog
  dont_notify_player_joined                    = var.dont_notify_player_joined
  enable_extra_structure_prevention_volumes    = var.enable_extra_structure_prevention_volumes
  harvest_ammount_multiplier                   = var.harvest_ammount_multiplier
  harvest_health_multiplier                    = var.harvest_health_multiplier
  item_stack_size_multiplier                   = var.item_stack_size_multiplier
  kick_idle_player_period                      = var.kick_idle_player_period
  max_personal_tamed_dinos                     = var.max_personal_tamed_dinos
  max_platform_saddle_structure_limit          = var.max_platform_saddle_structure_limit
  max_tamed_dinos                              = var.max_tamed_dinos
  non_permanent_diseases                       = var.non_permanent_diseases
  override_official_difficulty                 = var.override_official_difficulty
  override_structure_platform_prevention       = var.override_structure_platform_prevention
  oxygen_swim_speed_multiplier                 = var.oxygen_swim_speed_multiplier
  per_platform_max_structure_multiplier        = var.per_platform_max_structure_multiplier
  platform_saddle_build_area_bounds_multiplier = var.platform_saddle_build_area_bounds_multiplier
  player_character_food_drain_multiplier       = var.player_character_food_drain_multiplier
  player_character_health_recovery_multiplier  = var.player_character_health_recovery_multiplier
  player_character_stamina_drain_multiplier    = var.player_character_stamina_drain_multiplier
  player_character_water_drain_multiplier      = var.player_character_water_drain_multiplier
  player_damage_multiplier                     = var.player_damage_multiplier
  player_resistance_multiplier                 = var.player_resistance_multiplier
  prevent_diseases                             = var.prevent_diseases
  prevent_mate_boost                           = var.prevent_mate_boost
  prevent_offline_pvp                          = var.prevent_offline_pvp
  prevent_offline_pvp_interval                 = var.prevent_offline_pvp_interval
  prevent_spawn_animations                     = var.prevent_spawn_animations
  prevent_tribe_alliances                      = var.prevent_tribe_alliances
  pve_allow_structures_at_supply_drops         = var.pve_allow_structures_at_supply_drops
  raid_dino_character_food_drain_multiplier    = var.raid_dino_character_food_drain_multiplier
  random_supply_crate_pionts                   = var.random_supply_crate_pionts
  rcon_server_game_log_buffer                  = var.rcon_server_game_log_buffer
  resource_respawn_period_multiplier           = var.resource_respawn_period_multiplier
  server_hardcore                              = var.server_hardcore
  structure_pickup_hold_duration               = var.structure_pickup_hold_duration
  structure_pickup_time_after_placement        = var.structure_pickup_time_after_placement
  structure_prevent_resource_radius_multiplier = var.structure_prevent_resource_radius_multiplier
  structure_resistance_multiplier              = var.structure_resistance_multiplier
  the_max_structure_in_range                   = var.the_max_structure_in_range
  start_from_backup                            = var.start_from_backup
  backup_files_storage_type                    = var.backup_files_storage_type
  backup_files_local_path                      = var.backup_files_local_path
  existing_backup_files_bootstrap_bucket_arn   = var.existing_backup_files_bootstrap_bucket_arn
  existing_backup_files_bootstrap_bucket_name  = var.existing_backup_files_bootstrap_bucket_name
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

# Notes
# terraform turns floats into integers. When specifying a number input of 1.0 terraform converts it to 1.
