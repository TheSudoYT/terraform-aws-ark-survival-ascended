module "asa" {
  source = "../.."

  ge_proton_version = "8-27"
  instance_type     = "t3.xlarge"
  create_ssh_key    = true
  ssh_public_key    = "../../ark_public_key.pub"
  subnet_availability_zone = "us-east-1a"
  ark_session_name  = "ark-aws-ascended"
  taming_speed_multiplier                      = 1.0
  xp_multiplier                                = 1.0
  server_pve                                   = true
  admin_logging                                = false
  allow_anyone_baby_imprint_cuddle             = false
  allow_flyer_carry_pve                        = false
  allow_raid_dino_feeding                      = false
  allow_third_person_player                    = false
  always_allow_structure_pickup                = false
  clamp_resource_harvest_damage                = false
  day_cycle_speed_scale                        = 1.0
  night_time_speed_scale                       = 1.0
  day_time_speed_scale                         = 1.0
  difficulty_offset                            = 0.0
  dino_character_food_drain_multiplier         = 1.0
  dino_character_health_recovery_multiplier    = 1.0
  dino_character_stamina_drain_multiplier      = 1.0
  dino_damage_multiplier                       = 1.0
  dino_resistance_multiplier                   = 1.0
  disable_dino_decay_pve                       = false
  disable_imprint_dino_buff                    = false
  disable_pve_gamma                            = false
  enable_pvp_gamma                             = false
  disable_structure_decay_pve                  = false
  disable_weather_fog                          = false
  dont_notify_player_joined                    = false
  enable_extra_structure_prevention_volumes    = false
  harvest_ammount_multiplier                   = 1.0
  harvest_health_multiplier                    = 1.0
  item_stack_size_multiplier                   = 1.0
  kick_idle_player_period                      = 0
  max_personal_tamed_dinos                     = 0
  max_platform_saddle_structure_limit          = 0
  max_tamed_dinos                              = 0
  non_permanent_diseases                       = false
  override_official_difficulty                 = 1.0
  override_structure_platform_prevention       = false
  oxygen_swim_speed_multiplier                 = 1.0
  per_platform_max_structure_multiplier        = 1.0
  platform_saddle_build_area_bounds_multiplier = 1.0
  player_character_food_drain_multiplier       = 1.0
  player_character_health_recovery_multiplier  = 1.0
  player_character_stamina_drain_multiplier    = 1.0
  player_character_water_drain_multiplier      = 1.0
  player_damage_multiplier                     = 1.0
  player_resistance_multiplier                 = 1.0
  prevent_diseases                             = false
  prevent_mate_boost                           = false
  prevent_offline_pvp                          = false
  prevent_offline_pvp_interval                 = 0
  prevent_spawn_animations                     = false
  prevent_tribe_alliances                      = false
  pve_allow_structures_at_supply_drops         = false
  raid_dino_character_food_drain_multiplier    = 1.0
  random_supply_crate_points                   = false
  rcon_server_game_log_buffer                  = 0
  resource_respawn_period_multiplier           = 1.0
  server_hardcore                              = false
  structure_pickup_hold_duration               = 0
  structure_pickup_time_after_placement        = 0
  structure_prevent_resource_radius_multiplier = 1.0
  structure_resistance_multiplier              = 1.0
  the_max_structure_in_range                   = 0
}
