### Networking Variables ###
variable "vpc_cidr_block" {
  description = "The CIDR block of the VPC to be created"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr_block" {
  description = "The CIDR block of the  subnet to be created within the VPC"
  type        = string
  default     = "10.0.1.0/24"
}

variable "subnet_availability_zone" {
  description = "The AZ of the subnet to be created within the VPC"
  type        = string
  default     = "us-east-1a"
}

### Security Group Variables ###
variable "enable_rcon" {
  description = "True or False. Enable RCON or not"
  type        = bool
  default     = false
}

variable "rcon_port" {
  description = "The port number that RCON listens on if enabled"
  type        = number
  default     = null
}

variable "steam_query_port" {
  description = "The query port for steam server browser"
  type        = number
  default     = 27015

  validation {
    condition     = var.steam_query_port < 27020 || var.steam_query_port > 27050
    error_message = "Steam uses ports 27020 to 27050. Please choose a different query port."
  }
}

variable "game_client_port" {
  description = "The port that the game client listens on"
  type        = number
  default     = 7777
}

### ssh variables ###
variable "create_ssh_key" {
  description = "True or False. Determines if an SSH key is created in AWS"
  type        = bool
  default     = true
}

variable "existing_ssh_key_name" {
  description = "The name of an EXISTING SSH key for use with the EC2 instance"
  type        = string
  default     = null
}

variable "ssh_key_name" {
  description = "The name of the SSH key to be created for use with the EC2 instance"
  type        = string
  default     = "ark-ssh-key"
}

variable "ssh_public_key" {
  description = "The path to the ssh public key to be used with the EC2 instance"
  type        = string
  default     = "~/.ssh/ark_public_key.pub"
}

variable "ssh_ingress_allowed_cidr" {
  description = "The CIDR range to allow SSH incoming connections from"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

### ec2 variables ###
variable "ami_id" {
  description = "The AMI ID to use. Not providing one will result in the latest version of Ubuntu Focal 20.04 being used"
  type        = string
  default     = null
}

variable "instance_type" {
  description = "The instance type to use"
  type        = string
  default     = "t3.xlarge"
}

# variable "ark_security_group_id" {
#   description = "The ID of the security group to use with the EC2 instance"
#   type        = string
#   default     = ""
# }

# variable "ark_subnet_id" {
#   description = "The ID of the security group to use with the EC2 instance"
#   type        = string
#   default     = ""
# }

variable "ebs_volume_size" {
  description = "The size of the EBS volume attached to the EC2 instance"
  type        = number
  default     = 50
}

### Ark application variables ###
variable "use_custom_gameusersettings" {
  description = "True or False. Set true if you want to provide your own GameUserSettings.ini file when the server is started. Required if game_user_settings_ini_path is defined"
  type        = bool
  default     = false
}

variable "use_custom_game_ini" {
  description = "True or False. Set true if you want to provide your own Game.ini file when the server is started. Required if game_user_settings_ini_path is defined"
  type        = bool
  default     = false
}

variable "custom_gameusersettings_s3" {
  description = "True or False. Set true if use_custom_gameusersettings is true and you want to upload and download them from an S3 bucket during installation"
  type        = bool
  default     = false
}

variable "custom_gameini_s3" {
  description = "True or False. Set true if use_custom_gameini is true and you want to upload and download them from an S3 bucket during installation"
  type        = bool
  default     = false
}

variable "custom_gameusersettings_github" {
  description = "True or False. Set true if use_custom_gameusersettings is true and you want to download them from github. Must be a public repo."
  type        = bool
  default     = false
}

variable "custom_gameini_github" {
  description = "True or False. Set true if use_custom_gameini is true and you want to download them from github. Must be a public repo."
  type        = bool
  default     = false
}

variable "custom_gameusersettings_github_url" {
  description = "The URL to the GameUserSettings.ini file on a public GitHub repo. Used when custom_gameusersettings_github and custom_game_usersettings both == true."
  type        = string
  default     = ""
}

variable "custom_gameini_github_url" {
  description = "The URL to the Game.ini file on a public GitHub repo. Used when custom_gameini_github and use_custom_game_ini both == true."
  type        = string
  default     = ""
}

variable "game_user_settings_ini_path" {
  description = "Path to GameUserSettings.ini relative to your Terraform working directory. Will be uploaded to the server. Required if use_custom_gameusersettings = true and custom_game_usersettings_s3 = true."
  type        = string
  default     = ""
}

variable "game_ini_path" {
  description = "Path to Game.ini relative to your Terraform working directory. Will be uploaded to the server. Required if use_custom_game_ini = true and custom_game_ini_s3 = true."
  type        = string
  default     = ""
}

variable "is_password_protected" {
  description = "True or False. Is a password required for players to join the server"
  type        = bool
  default     = true
}

variable "join_password" {
  description = "The password required for players to join the server. Only required if is_password_protected = true"
  type        = string
  default     = "TinyTrexArms123!"
}

variable "max_players" {
  description = "The number of max players the server allows"
  type        = string
  default     = "32"
}

variable "server_admin_password" {
  description = "The admin password for the Ark server to perform admin commands"
  type        = string
  default     = "adminandypassword"
}

variable "ark_session_name" {
  description = "The name of the Ark server as it appears in the list of servers when users look for a server to join"
  type        = string
  default     = "ark-aws-ascended"
}

variable "enable_s3_backups" {
  description = "True or False. Set to true to enable backing up of the ShooterGame/Saved directory to S3"
  type        = bool
  default     = false
}

variable "backup_s3_bucket_arn" {
  description = "The ARN of the s3 bucket that you would like to use for ShooterGame/Saved directory backups"
  type        = string
  default     = ""
}

variable "backup_s3_bucket_name" {
  description = "The name of the S3 bucket to backup the ShooterGame/Saved directory to"
  type        = string
  default     = ""
}

variable "backup_interval_cron_expression" {
  description = "How often to backup the ShooterGame/Saved directory to S3 in cron expression format (https://crontab.cronhub.io/)"
  type        = string
  default     = "0 23 * * *"
}

# Backup inputs
variable "create_backup_s3_bucket" {
  description = "True or False. Do you want to create an S3 bucket to FTP backups into"
  type        = bool
  default     = false
}

variable "s3_bucket_backup_retention" {
  description = "Lifecycle rule. The number of days to keep backups in S3 before they are deleted"
  type        = number
  default     = 7
}

variable "force_destroy" {
  description = "True or False. Set to true if you want Terraform destroy commands to have the ability to destroy the backup bucket while it still containts backup files"
  type        = bool
  default     = false
}

variable "ge_proton_version" {
  description = "The version of GE Proton to use when installing Ark. Example: 8-21 (https://github.com/GloriousEggroll/proton-ge-custom/releases)"
  type        = string
  default     = "8-21"
}

variable "auto_save_interval" {
  description = "Set interval for automatic saves. Must be a float. pattern allows float numbers like 15.0, 3.14, etc. Setting this to 0 will cause constant saving."
  type        = number
  default     = 15

  #   validation {
  # condition     = can(regex("^[0-9]+\\\\.[0-9]+$", var.auto_save_interval))
  #     error_message = "Invalid auto_save_interval value. Must be a float number. This pattern allows float numbers like 15.0, 3.14, etc."
  #   }

}

variable "use_battleye" {
  type        = bool
  description = "True or False. True will set the -noBattlEye flag."
  default     = false
}

variable "taming_speed_multiplier" {
  description = "Specifies the scaling factor for creature taming speed. Higher values make taming faster."
  type        = number
  default     = 1.0
}


variable "xp_multiplier" {
  description = "Specifies the scaling factor for the experience received by players, tribes and tames for various actions. The default value 1 provides the same amounts of experience as in the single player experience (and official public servers). Higher values increase XP amounts awarded for various actions; lower values decrease it."
  type        = number
  default     = 1.0
}

variable "server_pve" {
  description = "If True, disables PvP and enables PvE."
  type        = bool
  default     = false
}

variable "admin_logging" {
  description = "If True, logs all admin commands to in-game chat."
  type        = bool
  default     = false
}

variable "allow_anyone_baby_imprint_cuddle" {
  description = "If True, allows anyone to take care of a baby creatures (cuddle etc.), not just whomever imprinted on it."
  type        = bool
  default     = false
}

variable "allow_flyer_carry_pve" {
  description = "If True, allows flying creatures to pick up wild creatures in PvE."
  type        = bool
  default     = false
}

variable "allow_raid_dino_feeding" {
  description = "If True, allows Titanosaurs to be permanently tamed (namely allow them to be fed). Note: in The Island only spawns a maximum of 3 Titanosaurs, so 3 tamed ones should ultimately block any more ones from spawning."
  type        = bool
  default     = false
}

variable "allow_third_person_player" {
  description = "If False, disables third person camera allowed by default on all dedicated servers."
  type        = bool
  default     = true
}

variable "always_allow_structure_pickup" {
  description = "If True disables the timer on the quick pick-up system."
  type        = bool
  default     = false
}

variable "clamp_resource_harvest_damage" {
  description = "If True, limit the damage caused by a tame to a resource on harvesting based on resource remaining health. Note: enabling this setting may result in sensible resource harvesting reduction using high damage tools or creatures."
  type        = bool
  default     = false
}

variable "day_cycle_speed_scale" {
  description = "Specifies the scaling factor for the passage of time in the ARK during the day. This value determines the length of each day, relative to the length of each night (as specified by NightTimeSpeedScale). Lowering this value increases the length of each day."
  type        = number
  default     = 1.0
}

variable "night_time_speed_scale" {
  description = "Specifies the scaling factor for the passage of time in the ARK during night time. This value determines the length of each night, relative to the length of each day (as specified by DayTimeSpeedScale) Lowering this value increases the length of each night."
  type        = number
  default     = 1.0
}

variable "day_time_speed_scale" {
  description = "Specifies the scaling factor for the passage of time in the ARK during the day. This value determines the length of each day, relative to the length of each night (as specified by NightTimeSpeedScale). Lowering this value increases the length of each day."
  type        = number
  default     = 1.0
}

variable "difficulty_offset" {
  description = "Specifies the difficulty level."
  type        = number
  default     = 1.0
}

variable "dino_character_food_drain_multiplier" {
  description = "Specifies the scaling factor for creatures' food consumption. Higher values increase food consumption (creatures get hungry faster). It also affects the taming-times."
  type        = number
  default     = 1.0
}

variable "dino_character_health_recovery_multiplier" {
  description = "Specifies the scaling factor for creatures' health recovery. Higher values increase the recovery rate (creatures heal faster)."
  type        = number
  default     = 1.0
}

variable "dino_character_stamina_drain_multiplier" {
  description = "Specifies the scaling factor for creatures' stamina consumption. Higher values increase stamina consumption (creatures get tired faster)."
  type        = number
  default     = 1.0
}

variable "dino_damage_multiplier" {
  description = "Specifies the scaling factor for the damage wild creatures deal with their attacks. The default value 1 provides normal damage. Higher values increase damage. Lower values decrease it."
  type        = number
  default     = 1.0
}

variable "dino_resistance_multiplier" {
  description = "Specifies the scaling factor for the resistance to damage wild creatures receive when attacked. The default value 1 provides normal damage. Higher values decrease resistance, increasing damage per attack. Lower values increase it, reducing damage per attack. A value of 0.5 results in a creature taking half damage while a value of 2.0 would result in a creature taking double normal damage."
  type        = number
  default     = 1.0
}

variable "disable_dino_decay_pve" {
  description = "If True, disables the creature decay in PvE mode. Note: after patch 273.691, in PvE mode the creature auto-unclaim after decay period has been disabled."
  type        = bool
  default     = false
}

variable "disable_imprint_dino_buff" {
  description = "If True, disables the creature imprinting player Stat Bonus. Where whomever specifically imprinted on the creature, and raised it to have an Imprinting Quality, gets extra Damage/Resistance buff."
  type        = bool
  default     = false
}

variable "disable_pve_gamma" {
  description = "If True, prevents use of console command gamma in PvE mode."
  type        = bool
  default     = false
}

variable "enable_pvp_gamma" {
  description = "If True, allows use of console command gamma in PvP mode."
  type        = bool
  default     = false
}

variable "disable_structure_decay_pve" {
  description = "If True, disables the gradual auto-decay of player structures."
  type        = bool
  default     = false
}

variable "disable_weather_fog" {
  description = "If True, disables fog."
  type        = bool
  default     = false
}

variable "dont_notify_player_joined" {
  description = "If True, globally disables player joins notifications."
  type        = bool
  default     = false
}

variable "enable_extra_structure_prevention_volumes" {
  description = "If True, disables building in specific resource-rich areas, in particular setup on The Island around the major mountains."
  type        = bool
  default     = false
}

variable "harvest_ammount_multiplier" {
  description = "Specifies the scaling factor for yields from all harvesting activities (chopping down trees, picking berries, carving carcasses, mining rocks, etc.). Higher values increase the amount of materials harvested with each strike."
  type        = number
  default     = 1.0
}

variable "harvest_health_multiplier" {
  description = "Specifies the scaling factor for the health of items that can be harvested (trees, rocks, carcasses, etc.). Higher values increase the amount of damage (i.e., number of strikes) such objects can withstand before being destroyed, which results in higher overall harvest yields."
  type        = number
  default     = 1.0
}

variable "item_stack_size_multiplier" {
  description = "Allow increasing or decreasing global item stack size, this means all default stack sizes will be multiplied by the value given (excluding items that have a stack size of 1 by default)."
  type        = number
  default     = 1.0
}

variable "kick_idle_player_period" {
  description = "Time in seconds after which characters that have not moved or interacted will be kicked (if -EnableIdlePlayerKick as command line parameter is set). Note: although at code level it is defined as a floating-point number, it is suggested to use an integer instead."
  type        = number
  default     = 3600.0
}

variable "max_personal_tamed_dinos" {
  description = "Sets a per-tribe creature tame limit (500 on official PvE servers, 300 in official PvP servers). The default value of 0 disables such limit."
  type        = number
  default     = 0
}

variable "max_platform_saddle_structure_limit" {
  description = "Changes the maximum number of platformed-creatures/rafts allowed on the ARK (a potential performance cost). Example: MaxPlatformSaddleStructureLimit=10 would only allow 10 platform saddles/rafts across the entire ARK."
  type        = number
  default     = 75
}

variable "max_tamed_dinos" {
  description = "Changes the maximum number of platformed-creatures/rafts allowed on the ARK (a potential performance cost). Example: MaxPlatformSaddleStructureLimit=10 would only allow 10 platform saddles/rafts across the entire ARK."
  type        = number
  default     = 5000.0
}

variable "non_permanent_diseases" {
  description = "If True, makes permanent diseases not permanent. Players will lose them if on re-spawn."
  type        = bool
  default     = false
}

variable "override_official_difficulty" {
  description = "Allows you to override the default server difficulty level of 4 with 5 to match the new official server difficulty level. Default value of 0.0 disables the override. A value of 5.0 will allow common creatures to spawn up to level 150. Originally (247.95) available only as command line option."
  type        = number
  default     = 0.0
}

variable "override_structure_platform_prevention" {
  description = "If True, turrets becomes be buildable and functional on platform saddles. Since 247.999 applies on spike structure too. Note: despite patch notes, in ShooterGameServer it's coded OverrideStructurePlatformPrevention with two r."
  type        = bool
  default     = false
}

variable "oxygen_swim_speed_multiplier" {
  description = "Use this to set how swim speed is multiplied by level spent in oxygen. The value was reduced by 80% in 256.0."
  type        = number
  default     = 1.0
}

variable "per_platform_max_structure_multiplier" {
  description = "Higher value increases (from a percentage scale) max number of items place-able on saddles and rafts."
  type        = number
  default     = 1.0
}

variable "platform_saddle_build_area_bounds_multiplier" {
  description = "Increasing the number allows structures being placed further away from the platform."
  type        = number
  default     = 1.0
}

variable "player_character_food_drain_multiplier" {
  description = "Specifies the scaling factor for player characters' food consumption. Higher values increase food consumption (player characters get hungry faster)."
  type        = number
  default     = 1.0
}

variable "player_character_health_recovery_multiplier" {
  description = "Specifies the scaling factor for player characters' health recovery. Higher values increase the recovery rate (player characters heal faster)."
  type        = number
  default     = 1.0
}

variable "player_character_stamina_drain_multiplier" {
  description = "Specifies the scaling factor for player characters' stamina consumption. Higher values increase stamina consumption (player characters get tired faster)."
  type        = number
  default     = 1.0
}

variable "player_character_water_drain_multiplier" {
  description = "Specifies the scaling factor for player characters' water consumption. Higher values increase water consumption (player characters get thirsty faster)."
  type        = number
  default     = 1.0
}

variable "player_damage_multiplier" {
  description = "Specifies the scaling factor for the damage players deal with their attacks. The default value 1 provides normal damage. Higher values increase damage. Lower values decrease it."
  type        = number
  default     = 1.0
}

variable "player_resistance_multiplier" {
  description = "Specifies the scaling factor for the resistance to damage players receive when attacked. The default value 1 provides normal damage. Higher values decrease resistance, increasing damage per attack. Lower values increase it, reducing damage per attack. A value of 0.5 results in a player taking half damage while a value of 2.0 would result in taking double normal damage."
  type        = number
  default     = 1.0
}

variable "prevent_diseases" {
  description = "If True, completely diseases on the server. Thus far just Swamp Fever."
  type        = bool
  default     = false
}

variable "prevent_mate_boost" {
  description = "If True, disables creature mate boosting."
  type        = bool
  default     = false
}

variable "prevent_offline_pvp" {
  description = "If True, enables the Offline Raiding Prevention (ORP). When all tribe members are logged off, tribe characters, creature and structures become invulnerable. Creature starvation still applies, moreover, characters and creature can still die if drowned. Despite the name, it works on both PvE and PvP game modes. Due to performance reason, it is recommended to set a minimum interval with PreventOfflinePvPInterval option before ORP becomes active. ORP also helps lowering memory and CPU usage on a server. Enabled by default on Official PvE since 258.3"
  type        = bool
  default     = false
}

variable "prevent_offline_pvp_interval" {
  description = "Seconds to wait before a ORP becomes active for tribe/players and relative creatures/structures (10 seconds in official PvE servers). Note: although at code level it is defined as a floating-point number, it is suggested to use an integer instead."
  type        = number
  default     = 0.0
}

variable "prevent_spawn_animations" {
  description = "If True, player characters (re)spawn without the wake-up animation."
  type        = bool
  default     = false
}

variable "prevent_tribe_alliances" {
  description = "If True, prevents tribes from creating Alliances."
  type        = bool
  default     = false
}

variable "pve_allow_structures_at_supply_drops" {
  description = "If True, allows building near supply drop points in PvE mode."
  type        = bool
  default     = false
}

variable "raid_dino_character_food_drain_multiplier" {
  description = "Affects how quickly the food drains on such raid dinos (e.g.: Titanosaurus)"
  type        = number
  default     = 1.0
}

variable "random_supply_crate_points" {
  description = "If True, supply drops are in random locations. Note: This setting is known to cause artifacts becoming inaccessible on Ragnarok if active."
  type        = bool
  default     = false
}

variable "rcon_server_game_log_buffer" {
  description = "Determines how many lines of game logs are send over the RCON. Note: despite being coded as a float it's suggested to treat it as integer."
  type        = number
  default     = 600.0
}

variable "resource_respawn_period_multiplier" {
  description = "Specifies the scaling factor for the re-spawn rate for resource nodes (trees, rocks, bushes, etc.). Lower values cause nodes to re-spawn more frequently."
  type        = number
  default     = 1.0
}

variable "server_hardcore" {
  description = "If True, enables Hardcore mode (player characters revert to level 1 upon death)"
  type        = bool
  default     = false
}

variable "structure_pickup_hold_duration" {
  description = "Specifies the quick pick-up hold duration, a value of 0 results in instant pick-up."
  type        = number
  default     = 0.5
}

variable "structure_pickup_time_after_placement" {
  description = "Amount of time in seconds after placement that quick pick-up is available."
  type        = number
  default     = 30.0
}

variable "structure_prevent_resource_radius_multiplier" {
  description = "Same as ResourceNoReplenishRadiusStructures in Game.ini. If both settings are set both multiplier will be applied. Can be useful when cannot change the Game.ini file as it works as a command line option too."
  type        = number
  default     = 1.0
}

variable "structure_resistance_multiplier" {
  description = "Specifies the scaling factor for the resistance to damage structures receive when attacked. The default value 1 provides normal damage. Higher values decrease resistance, increasing damage per attack. Lower values increase it, reducing damage per attack. A value of 0.5 results in a structure taking half damage while a value of 2.0 would result in a structure taking double normal damage."
  type        = number
  default     = 1.0
}

variable "the_max_structure_in_range" {
  description = "Specifies the maximum number of structures that can be constructed within a certain (currently hard-coded) range. Replaces the old value NewMaxStructuresInRange"
  type        = number
  default     = 10500
}

### Mods ###
variable "mod_list" {
  description = "A list of mod IDs to add to the server. List of strings. Example: mod_list = ['935813', '900062']"
  type        = list(string)
  default     = [""]
}

### Platform Types ###
variable "supported_server_platforms" {
  description = "Allows the server to accept specified platforms. Options are PC for Steam, PS5 for PlayStation 5, XSX for XBOX, WINGDK for Microsoft Store, ALL for crossplay between PC and all consoles. Note: Steam dedicated server supports only PC and ALL options. Example: supported_server_platforms = ['PC', 'PS5']"
  type        = list(string)
  default     = ["PC"]

  validation {
    condition     = alltrue([for v in var.supported_server_platforms : contains(["PC", "PS5", "XSX", "WINGDK", "ALL"], v)])
    error_message = "Each supported server platform must be one of 'PC', 'PS5', 'XSX', 'WINGDK', or 'ALL'."
  }
}

## Restore from backups
variable "start_from_backup" {
  description = "True of False. Set true to start the server from an existing Ark save. Requires existing save game files."
  type        = bool
  default     = false
}

variable "backup_files_storage_type" {
  description = "The location of your save game files that you wish to start the server with. Supported options are `local` or `s3'. `local` means the save game files exist somewhere on the host you are running terraform apply from. `s3` means the files exist in an s3 bucket."
  type        = string
  default     = "local"

  validation {
    condition     = var.backup_files_storage_type == "local" || var.backup_files_storage_type == "s3"
    error_message = "Invalid storage type. The only valid inputs are 'local' or 's3'."
  }

}

# if backup_files_storage_type local && start_from_backup = true. Local needs to upload files to an s3 bucket and download.
variable "backup_files_local_path" {
  description = "Path to existing save game files relative to your Terraform working directory. Will be uploaded to the server. Required if `backup_files_storage_path = local` "
  type        = string
  default     = ""
}

variable "existing_backup_files_bootstrap_bucket_arn" {
  description = "The ARN of an existing S3 bucket with ARK save game data. Files will be downloaded to the server. Objects must be in the root of the S3 bucket and not compressed."
  type        = string
  default     = ""
}

variable "existing_backup_files_bootstrap_bucket_name" {
  description = "The Name of an existing S3 bucket with ARK save game data. Files will be downloaded to the server. Objects must be in the root of the S3 bucket and not compressed."
  type        = string
  default     = ""
}
