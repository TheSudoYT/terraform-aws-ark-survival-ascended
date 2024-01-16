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

data "aws_region" "current" {}

data "template_file" "user_data_template" {
  template = file("${path.module}/templates/user_data_script.sh.tpl")
  vars = {
    use_battleye          = "${var.use_battleye}"
    auto_save_interval    = "${var.auto_save_interval}"
    ge_proton_version     = "${var.ge_proton_version}"
    max_players           = "${var.max_players}"
    enable_rcon           = "${var.enable_rcon}"
    rcon_port             = var.enable_rcon == true ? "${var.rcon_port}" : null
    steam_query_port      = "${var.steam_query_port}"
    game_client_port      = "${var.game_client_port}"
    server_admin_password = "${var.server_admin_password}"
    ark_session_name      = "${var.ark_session_name}"
    is_password_protected = "${var.is_password_protected}"
    join_password         = "${var.join_password}"
    # START GameUserSettings.ini inputs
    use_custom_gameusersettings    = "${var.use_custom_gameusersettings}"
    custom_gameusersettings_s3     = var.use_custom_gameusersettings == true ? "${var.custom_gameusersettings_s3}" : false
    gameusersettings_bucket_arn    = var.custom_gameusersettings_s3 == true && length(aws_s3_object.gameusersettings) > 0 ? "s3://${aws_s3_bucket.ark[0].bucket}/${aws_s3_object.gameusersettings[0].key}" : "na"
    custom_gameusersettings_github = var.use_custom_gameusersettings == true ? "${var.custom_gameusersettings_github}" : false
    github_url                     = var.custom_gameusersettings_github == true ? "${var.custom_gameusersettings_github_url}" : ""
    game_user_settings_ini_path    = var.custom_gameusersettings_s3 == true ? "${var.game_user_settings_ini_path}" : ""
    # END GameUserSettings.ini inputs
    # START Game.ini inputs
    use_custom_game_ini   = "${var.use_custom_game_ini}"
    custom_gameini_s3     = var.use_custom_game_ini == true ? "${var.custom_gameini_s3}" : false
    gameini_bucket_arn    = var.custom_gameini_s3 == true && length(aws_s3_object.gameini) > 0 ? "s3://${aws_s3_bucket.ark[0].bucket}/${aws_s3_object.gameini[0].key}" : "na"
    custom_gameini_github = var.use_custom_game_ini == true ? "${var.custom_gameini_github}" : false
    github_url_gameini    = var.custom_gameini_github == true ? "${var.custom_gameini_github_url}" : ""
    game_ini_path         = var.custom_gameini_s3 == true ? "${var.game_ini_path}" : ""
    # END Game.ini inputs
    # START backup related inputs
    enable_s3_backups               = var.enable_s3_backups
    backup_s3_bucket_name           = var.backup_s3_bucket_name
    backup_interval_cron_expression = var.backup_interval_cron_expression
    # END backup related inputs
    taming_speed_multiplier                      = "${var.taming_speed_multiplier}"
    xp_multiplier                                = "${var.xp_multiplier}"
    server_pve                                   = "${var.server_pve}"
    admin_logging                                = "${var.admin_logging}"
    allow_anyone_baby_imprint_cuddle             = "${var.allow_anyone_baby_imprint_cuddle}"
    allow_flyer_carry_pve                        = "${var.allow_flyer_carry_pve}"
    allow_raid_dino_feeding                      = "${var.allow_raid_dino_feeding}"
    allow_third_person_player                    = "${var.allow_third_person_player}"
    always_allow_structure_pickup                = "${var.always_allow_structure_pickup}"
    clamp_resource_harvest_damage                = "${var.clamp_resource_harvest_damage}"
    day_cycle_speed_scale                        = "${var.day_cycle_speed_scale}"
    night_time_speed_scale                       = "${var.night_time_speed_scale}"
    day_time_speed_scale                         = "${var.day_time_speed_scale}"
    difficulty_offset                            = "${var.difficulty_offset}"
    dino_character_food_drain_multiplier         = "${var.dino_character_food_drain_multiplier}"
    dino_character_health_recovery_multiplier    = "${var.dino_character_health_recovery_multiplier}"
    dino_character_stamina_drain_multiplier      = "${var.dino_character_stamina_drain_multiplier}"
    dino_damage_multiplier                       = "${var.dino_damage_multiplier}"
    dino_resistance_multiplier                   = "${var.dino_resistance_multiplier}"
    disable_dino_decay_pve                       = "${var.disable_dino_decay_pve}"
    disable_imprint_dino_buff                    = "${var.disable_imprint_dino_buff}"
    disable_pve_gamma                            = "${var.disable_pve_gamma}"
    enable_pvp_gamma                             = "${var.enable_pvp_gamma}"
    disable_structure_decay_pve                  = "${var.disable_structure_decay_pve}"
    disable_weather_fog                          = "${var.disable_weather_fog}"
    dont_notify_player_joined                    = "${var.dont_notify_player_joined}"
    enable_extra_structure_prevention_volumes    = "${var.enable_extra_structure_prevention_volumes}"
    harvest_ammount_multiplier                   = "${var.harvest_ammount_multiplier}"
    harvest_health_multiplier                    = "${var.harvest_health_multiplier}"
    item_stack_size_multiplier                   = "${var.item_stack_size_multiplier}"
    kick_idle_player_period                      = "${var.kick_idle_player_period}"
    max_personal_tamed_dinos                     = "${var.max_personal_tamed_dinos}"
    max_platform_saddle_structure_limit          = "${var.max_platform_saddle_structure_limit}"
    max_tamed_dinos                              = "${var.max_tamed_dinos}"
    non_permanent_diseases                       = "${var.non_permanent_diseases}"
    override_official_difficulty                 = "${var.override_official_difficulty}"
    override_structure_platform_prevention       = "${var.override_structure_platform_prevention}"
    oxygen_swim_speed_multiplier                 = "${var.oxygen_swim_speed_multiplier}"
    per_platform_max_structure_multiplier        = "${var.per_platform_max_structure_multiplier}"
    platform_saddle_build_area_bounds_multiplier = "${var.platform_saddle_build_area_bounds_multiplier}"
    player_character_food_drain_multiplier       = "${var.player_character_food_drain_multiplier}"
    player_character_health_recovery_multiplier  = "${var.player_character_health_recovery_multiplier}"
    player_character_stamina_drain_multiplier    = "${var.player_character_stamina_drain_multiplier}"
    player_character_water_drain_multiplier      = "${var.player_character_water_drain_multiplier}"
    player_damage_multiplier                     = "${var.player_damage_multiplier}"
    player_resistance_multiplier                 = "${var.player_resistance_multiplier}"
    prevent_diseases                             = "${var.prevent_diseases}"
    prevent_mate_boost                           = "${var.prevent_mate_boost}"
    prevent_offline_pvp                          = "${var.prevent_offline_pvp}"
    prevent_offline_pvp_interval                 = "${var.prevent_offline_pvp_interval}"
    prevent_spawn_animations                     = "${var.prevent_spawn_animations}"
    prevent_tribe_alliances                      = "${var.prevent_tribe_alliances}"
    pve_allow_structures_at_supply_drops         = "${var.pve_allow_structures_at_supply_drops}"
    raid_dino_character_food_drain_multiplier    = "${var.raid_dino_character_food_drain_multiplier}"
    random_supply_crate_pionts                   = "${var.random_supply_crate_pionts}"
    rcon_server_game_log_buffer                  = "${var.rcon_server_game_log_buffer}"
    resource_respawn_period_multiplier           = "${var.resource_respawn_period_multiplier}"
    server_hardcore                              = "${var.server_hardcore}"
    structure_pickup_hold_duration               = "${var.structure_pickup_hold_duration}"
    structure_pickup_time_after_placement        = "${var.structure_pickup_time_after_placement}"
    structure_prevent_resource_radius_multiplier = "${var.structure_prevent_resource_radius_multiplier}"
    structure_resistance_multiplier              = "${var.structure_resistance_multiplier}"
    the_max_structure_in_range                   = "${var.the_max_structure_in_range}"

    # Can't use a local file and render into the template to be placed into a file because the allowable length of user_data will be exceeded
    #gameusersettings_contents   = var.use_custom_gameusersettings == true ? file("${var.game_user_settings_ini_path}") : null  
  }

  lifecycle {
    precondition {
      condition     = var.enable_rcon == true && var.rcon_port != null || var.enable_rcon == false && var.rcon_port == null
      error_message = "rcon_port is defined when enable_rcon = false. rcon_port must be null unless enable_rcon = true."
    }

    precondition {
      condition     = var.enable_rcon == true && var.server_admin_password != "" || var.enable_rcon == false
      error_message = "server_admin_password must be set when enable_rcon = true"
    }
  }
}