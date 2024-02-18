#!/bin/bash

# Create directories
mkdir /opt/steam
mkdir /ark-asa

# Install software
echo "[INFO] INSTALLING SOFTWARE"
apt-get update
apt-get install -y curl lib32gcc1 lsof git awscli

# Install AWS SSM Agent if enabled
if [[ ${enable_session_manager} == "true" ]]; then
echo "[INFO] Installing AWS SSM Agent..."
sudo snap install amazon-ssm-agent --classic
sudo systemctl enable snap.amazon-ssm-agent.amazon-ssm-agent.service
sudo systemctl start snap.amazon-ssm-agent.amazon-ssm-agent.service
echo "[INFO] AWS SSM Agent installation complete."
fi

# Install Proton from Glorious Eggroll to allow windows games to run on linux
echo "[INFO] DOWNLOADING PROTON FROM GE"
PROTON_URL="https://github.com/GloriousEggroll/proton-ge-custom/releases/download/GE-Proton${ge_proton_version}/GE-Proton${ge_proton_version}.tar.gz"
PROTON_TGZ="$(basename "$PROTON_URL")"
PROTON_NAME="$(basename "$PROTON_TGZ" ".tar.gz")"
wget "$PROTON_URL" -O "/opt/steam/$PROTON_TGZ"

# Install steam cmd
echo "[INFO] DOWNLOADING AND INSTALLING STEAM CMD"
wget -P /opt/steam https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
tar -xzf /opt/steam/steamcmd_linux.tar.gz -C /opt/steam 
chmod 755 /opt/steam/steamcmd.sh

# Create steam user
echo "[INFO] CREATING STEAM USER"
useradd -m -U steam
chown -R steam:steam /ark-asa

# Extract GE Proton into the steam directory
echo "[INFO] EXTRACTING GE PROTON INTO STEAM DIRECTORY"
STEAMDIR="/ark-asa"
sudo -u steam mkdir -p "$STEAMDIR/compatibilitytools.d"
sudo -u steam tar -x -C "$STEAMDIR/compatibilitytools.d/" -f "/opt/steam/$PROTON_TGZ"


# Install default prefix into game compatdata path
echo "SETTING UP PROTON TO WORK WITH ARK AND STEAM"
[ -d "$STEAMDIR/steamapps/compatdata" ] || sudo -u steam mkdir -p "$STEAMDIR/steamapps/compatdata"
[ -d "$STEAMDIR/steamapps/compatdata/2430930" ] || \
sudo -u steam cp "$STEAMDIR/compatibilitytools.d/$PROTON_NAME/files/share/default_pfx" "$STEAMDIR/steamapps/compatdata/2430930" -r

# Setup the steam cmd command to download for ASA
echo "[INFO] SETTING UP STEAMCMD INSTALLER TO DOWNLOAD ARK"
chown -R steam:steam /opt/steam
cat <<EOF > /opt/steam/download-ark.txt
@ShutdownOnFailedCommand 1 //set to 0 if updating multiple servers at once
@NoPromptForPassword 1
force_install_dir /ark-asa
login anonymous 
app_update 2430930 validate
quit
EOF

# Run steam cmd to download ASA
echo "[INFO] DOWNLOADING ARK"
sudo -u steam /opt/steam/steamcmd.sh +runscript /opt/steam/download-ark.txt

# Install the systemd service file for ASA Dedicated Server (Island)
echo "[INFO] CREATING SYSTEMD SERVICE ARK-ISLAND"
cat > /etc/systemd/system/ark-island.service <<EOF
[Unit]
Description=ARK Survival Ascended Dedicated Server (Island)
After=network.target

[Service]
Type=simple
LimitNOFILE=10000
User=steam
Group=steam
ExecStartPre=/opt/steam/steamcmd.sh +runscript /opt/steam/download-ark.txt
WorkingDirectory=/ark-asa/ShooterGame/Binaries/Win64
Environment=XDG_RUNTIME_DIR=/run/user/$(id -u)
Environment="STEAM_COMPAT_CLIENT_INSTALL_PATH=$STEAMDIR"
Environment="STEAM_COMPAT_DATA_PATH=$STEAMDIR/steamapps/compatdata/2430930"
ExecStart=$STEAMDIR/compatibilitytools.d/$PROTON_NAME/proton run ArkAscendedServer.exe TheIsland_WP?listen?SessionName=${ark_session_name}%{ if auto_save_interval != "15.0" ~}?AutoSavePeriodMinutes=${auto_save_interval}%{ endif ~}%{ if taming_speed_multiplier != "1" ~}?TamingSpeedMultiplier=${taming_speed_multiplier}%{ endif ~}%{ if xp_multiplier != "1" ~}?XPMultiplier=${xp_multiplier}%{ endif ~}%{ if server_pve == "true" ~}?ServerPVE=true%{ endif ~}%{ if admin_logging == "true" ~}?AdminLogging=true%{ endif ~}%{ if allow_anyone_baby_imprint_cuddle == "true" ~}?AllowAnyoneBabyImprintCuddle=true%{ endif ~}%{ if allow_flyer_carry_pve == "true" ~}?AllowFlyerCarryPvE=true%{ endif ~}%{ if allow_raid_dino_feeding == "true" ~}?AllowRaidDinoFeeding=true%{ endif ~}%{ if allow_third_person_player == "false" ~}?AllowThirdPersonPlayer=false%{ endif ~}%{ if always_allow_structure_pickup == "true" ~}?AlwaysAllowStructurePickup=true%{ endif ~}%{ if clamp_resource_harvest_damage == "true" ~}?ClampResourceHarvestDamage=true%{ endif ~}%{ if day_cycle_speed_scale != "1" ~}?DayCycleSpeedScale=${day_cycle_speed_scale}%{ endif ~}%{ if night_time_speed_scale != "1" ~}?NightTimeSpeedScale=${night_time_speed_scale}%{ endif ~}%{ if day_time_speed_scale != "1" ~}?DayTimeSpeedScale=${day_time_speed_scale}%{ endif ~}%{ if difficulty_offset != "1" ~}?DifficultyOffset=${difficulty_offset}%{ endif ~}%{ if dino_character_food_drain_multiplier != "1" ~}?DinoCharacterFoodDrainMultiplier=${dino_character_food_drain_multiplier}%{ endif ~}%{ if dino_character_health_recovery_multiplier != "1" ~}?DinoCharacterHealthRecoveryMultiplier=${dino_character_health_recovery_multiplier}%{ endif ~}%{ if dino_character_stamina_drain_multiplier != "1" ~}?DinoCharacterStaminaDrainMultiplier=${dino_character_stamina_drain_multiplier}%{ endif ~}%{ if dino_damage_multiplier != "1" ~}?DinoDamageMultiplier=${dino_damage_multiplier}%{ endif ~}%{ if dino_resistance_multiplier != "1" ~}?DinoResistanceMultiplier=${dino_resistance_multiplier}%{ endif ~}%{ if disable_dino_decay_pve == "true" ~}?DisableDinoDecayPvE=true%{ endif ~}%{ if disable_imprint_dino_buff == "true" ~}?DisableImprintDinoBuff=true%{ endif ~}%{ if disable_pve_gamma == "true" ~}?DisablePvEGamma=true%{ endif ~}%{ if enable_pvp_gamma == "true" ~}?EnablePvPGamma=true%{ endif ~}%{ if disable_structure_decay_pve == "true" ~}?DisableStructureDecayPvE=true%{ endif ~}%{ if disable_weather_fog == "true" ~}?DisableWeatherFog=true%{ endif ~}%{ if dont_notify_player_joined == "true" ~}?DontNotifyPlayerJoined=true%{ endif ~}%{ if enable_extra_structure_prevention_volumes == "true" ~}?EnableExtraStructurePreventionVolumes=true%{ endif ~}%{ if harvest_ammount_multiplier != "1" ~}?HarvestAmountMultiplier=${harvest_ammount_multiplier}%{ endif ~}%{ if harvest_health_multiplier != "1" ~}?HarvestHealthMultiplier=${harvest_health_multiplier}%{ endif ~}%{ if item_stack_size_multiplier != "1" ~}?ItemStackSizeMultiplier=${item_stack_size_multiplier}%{ endif ~}%{ if kick_idle_player_period != "3600" ~}?KickIdlePlayerPeriod=${kick_idle_player_period}%{ endif ~}%{ if max_personal_tamed_dinos != "0" ~}?MaxPersonalTamedDinos=${max_personal_tamed_dinos}%{ endif ~}%{ if max_platform_saddle_structure_limit != "75" ~}?MaxPlatformSaddleStructureLimit=${max_platform_saddle_structure_limit}%{ endif ~}%{ if max_tamed_dinos != "5000" ~}?MaxTamedDinos=${max_tamed_dinos}%{ endif ~}%{ if non_permanent_diseases == "true" ~}?NonPermanentDiseases=true%{ endif ~}%{ if override_official_difficulty != "0" ~}?OverrideOfficialDifficulty=${override_official_difficulty}%{ endif ~}%{ if override_structure_platform_prevention == "true" ~}?OverrideStructurePlatformPrevention=true%{ endif ~}%{ if oxygen_swim_speed_multiplier != "1" ~}?OxygenSwimSpeedMultiplier=${oxygen_swim_speed_multiplier}%{ endif ~}%{ if per_platform_max_structure_multiplier != "1" ~}?PerPlatformMaxStructureMultiplier=${per_platform_max_structure_multiplier}%{ endif ~}%{ if platform_saddle_build_area_bounds_multiplier != "1" ~}?PlatformSaddleBuildAreaBoundsMultiplier=${platform_saddle_build_area_bounds_multiplier}%{ endif ~}%{ if player_character_food_drain_multiplier != "1" ~}?PlayerCharacterFoodDrainMultiplier=${player_character_food_drain_multiplier}%{ endif ~}%{ if player_character_health_recovery_multiplier != "1" ~}?PlayerCharacterHealthRecoveryMultiplier=${player_character_health_recovery_multiplier}%{ endif ~}%{ if player_character_stamina_drain_multiplier != "1" ~}?PlayerCharacterStaminaDrainMultiplier=${player_character_stamina_drain_multiplier}%{ endif ~}%{ if player_character_water_drain_multiplier != "1" ~}?PlayerCharacterWaterDrainMultiplier=${player_character_water_drain_multiplier}%{ endif ~}%{ if player_damage_multiplier != "1" ~}?PlayerDamageMultiplier=${player_damage_multiplier}%{ endif ~}%{ if player_resistance_multiplier != "1" ~}?PlayerResistanceMultiplier=${player_resistance_multiplier}%{ endif ~}%{ if prevent_diseases == "true" ~}?PreventDiseases=true%{ endif ~}%{ if prevent_mate_boost == "true" ~}?PreventMateBoost=true%{ endif ~}%{ if prevent_offline_pvp == "true" ~}?PreventOfflinePvP=true%{ endif ~}%{ if prevent_offline_pvp_interval != "0" ~}?PreventOfflinePvPInterval=${prevent_offline_pvp_interval}%{ endif ~}%{ if prevent_spawn_animations == "true" ~}?PreventSpawnAnimations=true%{ endif ~}%{ if prevent_tribe_alliances == "true" ~}?PreventTribeAlliances=true%{ endif ~}%{ if pve_allow_structures_at_supply_drops == "true" ~}?PvEAllowStructuresAtSupplyDrops=true%{ endif ~}%{ if raid_dino_character_food_drain_multiplier != "1" ~}?RaidDinoCharacterFoodDrainMultiplier=${raid_dino_character_food_drain_multiplier}%{ endif ~}%{ if random_supply_crate_points == "true" ~}?RandomSupplyCratePoints=true%{ endif ~}%{ if rcon_server_game_log_buffer != "600" ~}?RCONServerGameLogBuffer=${rcon_server_game_log_buffer}%{ endif ~}%{ if resource_respawn_period_multiplier != "1" ~}?ResourceRespawnPeriodMultiplier=${resource_respawn_period_multiplier}%{ endif ~}%{ if server_hardcore == "true" ~}?ServerHardcore=true%{ endif ~}%{ if structure_pickup_hold_duration != "0.5" ~}?StructurePickupHoldDuration=${structure_pickup_hold_duration}%{ endif ~}%{ if structure_pickup_time_after_placement != "30" ~}?StructurePickupTimeAfterPlacement=${structure_pickup_time_after_placement}%{ endif ~}%{ if structure_prevent_resource_radius_multiplier != "1" ~}?StructurePreventResourceRadiusMultiplier=${structure_prevent_resource_radius_multiplier}%{ endif ~}%{ if structure_resistance_multiplier != "1" ~}?StructureResistanceMultiplier=${structure_resistance_multiplier}%{ endif ~}%{ if the_max_structure_in_range != "10500" ~}?TheMaxStructureInRange=${the_max_structure_in_range}%{ endif ~} \
-ServerAdminPassword=${server_admin_password} \
-Port=${game_client_port} \
-QueryPort=${steam_query_port} \
-WinLiveMaxPlayers=${max_players} \
%{ if is_password_protected == "true" ~}
-ServerPassword=${join_password} \
%{ endif ~}
%{ if enable_rcon == "true" ~}
-RCONEnabled=${enable_rcon} \
-RCONPort=${rcon_port} \
%{ endif ~}
%{ if use_battleye != "true" ~}
-NoBattlEye \
%{ endif ~}
%{ if length(mod_list) > 0 ~}
-mods=${mod_list} \
%{ endif ~}
%{ if supported_server_platforms != "PC"  ~}
-ServerPlatform=${supported_server_platforms} \
%{ endif ~}


Restart=on-failure
RestartSec=20s

[Install]
WantedBy=multi-user.target
EOF

# Function for getting GameUserSettings from S3
retrieve_obj_from_s3() {
  local src="$1"
  local dst="/ark-asa/ShooterGame/Saved/Config/WindowsServer/GameUserSettings.ini"

  echo "[INFO] GETTING GameUserSettings.ini FROM S3"

  if [[ "$src" == "" ]]; then
    echo "[ERROR] Did not detect a valid path."
    exit_script 10
  else
    echo "[INFO] Copying $src to $dst..."
    aws s3 cp "$src" "$dst" --region ${aws_region}
    chown steam:steam /ark-asa/ShooterGame/Saved/Config/WindowsServer/GameUserSettings.ini
  fi
}

# Function for getting GameUserSettings from GitHub raw
retrieve_obj_from_github() {
  local src="$1"
  local dst="/ark-asa/ShooterGame/Saved/Config/WindowsServer/GameUserSettings.ini"

  echo "[INFO] GETTING GameUserSettings.ini FROM GITHUB"

  if [[ "$src" == "" ]]; then
    echo "[ERROR] Did not detect a valid path."
    exit_script 10
  else
    echo "[INFO] Copying $src to $dst..."
    curl "$src" --create-dirs -o "$dst"
    chown steam:steam /ark-asa/ShooterGame/Saved/Config/WindowsServer/GameUserSettings.ini
  fi
}

handle_gameusersettings() {
    local use_custom_gameusersettings="$1"
    local custom_gameusersettings_s3="$2"
    local custom_gameusersettings_github="$3"
    local gameusersettings_bucket_arn="$4"
    local github_url="$5"

    echo "[INFO] CHECKING FOR CUSTOM GameUserSettings.ini OPTIONS"
    echo "[INFO] use_custom_gameusersettings SET TO $use_custom_gameusersettings"
    echo "[INFO] custom_gameusersettings_s3 SET TO $custom_gameusersettings_s3"
    echo "[INFO] custom_gameusersettings_github SET TO $custom_gameusersettings_github"
    echo "[INFO] gameusersettings_bucket_arn SET TO $gameusersettings_bucket_arn"
    echo "[INFO] github_url SET TO $github_url"

    if [[ $use_custom_gameusersettings == "true" ]]; then
        if [[ $custom_gameusersettings_s3 == "true" && $custom_gameusersettings_github == "true" ]]; then
            echo "Error: Both custom_gameusersettings_s3 and custom_gameusersettings_github cannot be true simultaneously."
        elif [[ $custom_gameusersettings_s3 == "true" ]]; then
            echo "[INFO] custom_gameusersettings_s3 == true"
            retrieve_obj_from_s3 "$gameusersettings_bucket_arn"
        elif [[ $custom_gameusersettings_github == "true" ]]; then
            echo "[INFO] custom_gameusersettings_github == true"
            retrieve_obj_from_github "$github_url"
        else
            echo "Error: Invalid configuration for use_custom_gameusersettings."
        fi
    fi
}

# Function for getting Game.ini from S3
retrieve_obj_from_s3_gameini() {
  local src="$1"
  local dst="/ark-asa/ShooterGame/Saved/Config/WindowsServer/Game.ini"

  echo "[INFO] GETTING Game.ini FROM S3"

  if [[ "$src" == "" ]]; then
    echo "[ERROR] Did not detect a valid path."
    exit_script 10
  else
    echo "[INFO] Copying $src to $dst..."
    aws s3 cp "$src" "$dst" --region ${aws_region}
  fi
}

# Function for getting Game.ini from GitHub raw
retrieve_obj_from_github_gameini() {
  local src="$1"
  local dst="/ark-asa/ShooterGame/Saved/Config/WindowsServer/Game.ini"

  echo "[INFO] GETTING Game.ini FROM GITHUB"

  if [[ "$src" == "" ]]; then
    echo "[ERROR] Did not detect a valid path."
    exit_script 10
  else
    echo "[INFO] Copying $src to $dst..."
    curl "$src" --create-dirs -o "$dst"
  fi
}

handle_gameini() {
    local use_custom_game_ini="$1"
    local custom_gameini_s3="$2"
    local custom_gameini_github="$3"
    local gameini_bucket_arn="$4"
    local github_url_gameini="$5"

    echo "[INFO] CHECKING FOR CUSTOM Game.ini OPTIONS"
    echo "[INFO] use_custom_game_ini SET TO $use_custom_game_ini"
    echo "[INFO] custom_gameini_s3 SET TO $custom_gameini_s3"
    echo "[INFO] custom_gameini_github SET TO $custom_gameini_github"
    echo "[INFO] gameini_bucket_arn SET TO $gameini_bucket_arn"
    echo "[INFO] github_url_gameini SET TO $github_url_gameini"

    if [[ $use_custom_game_ini == "true" ]]; then
        if [[ $custom_gameini_s3 == "true" && $custom_gameini_github == "true" ]]; then
            echo "Error: Both custom_gameini_s3 and custom_gameini_github cannot be true simultaneously."
        elif [[ $custom_gameini_s3 == "true" ]]; then
            echo "[INFO] custom_gameini_s3 == true"
            retrieve_obj_from_s3_gameini "$gameini_bucket_arn"
        elif [[ $custom_gameini_github == "true" ]]; then
            echo "[INFO] custom_gameini_github == true"
            retrieve_obj_from_github_gameini "$github_url_gameini"
        else
            echo "Error: Invalid configuration for use_custom_game_ini."
        fi
    fi
}

##
# DONT FORGET TO PARAMETERIZE THE MAP NAME WHEN YOU DO MULTIPLE MAPS!! ##
#####
# Function for getting save game files from S3
retrieve_obj_from_new_s3_backup() {
  local src="$1"
  local dst="/ark-asa/ShooterGame/Saved/SavedArks/TheIsland_WP"

  echo "[INFO] GETTING SAVE BACKUP FILES FROM TERRAFORM GENERATED S3"

  if [[ "$src" == "" ]]; then
    echo "[ERROR] Did not detect a valid path."
    exit_script 10
  else
    echo "[INFO] Copying $src to $dst..."
    aws s3 sync "$src" "$dst" --region ${aws_region}
  fi
}

retrieve_obj_from_existing_s3_backup() {
  local src="$1"
  local dst="/ark-asa/ShooterGame/Saved/SavedArks/TheIsland_WP"

  echo "[INFO] GETTING SAVE BACKUP FILES FROM USER PROVIDED S3"

  if [[ "$src" == "" ]]; then
    echo "[ERROR] Did not detect a valid path."
    exit_script 10
  else
    echo "[INFO] Copying $src to $dst..."
    aws s3 sync "$src" "$dst" --region ${aws_region}
  fi
}

handle_start_from_backup() {
    local start_from_backup="$1"
    local backup_files_storage_type="$2"
    local backup_files_local_path="$3"
    local backup_files_bootstrap_bucket_name="$4"
    local existing_backup_files_bootstrap_bucket_name="$5"

    echo "[INFO] CHECKING FOR START_FROM_BACKUP OPTIONS"
    echo "[INFO] start_from_backup SET TO $start_from_backup"
    echo "[INFO] backup_files_storage_type SET TO $backup_files_storage_type"
    echo "[INFO] backup_files_local_path SET TO $backup_files_local_path"
    echo "[INFO] backup_files_bootstrap_bucket_name SET TO $backup_files_local_path"
    echo "[INFO] existing_backup_files_bootstrap_bucket_name SET TO $existing_backup_files_bootstrap_bucket_name"

    if [[ $start_from_backup == "true" ]]; then
        if [[ $backup_files_storage_type == "local" ]]; then
            echo "[INFO] backup_files_storage_type == local"
            retrieve_obj_from_new_s3_backup "$backup_files_bootstrap_bucket_name"
        elif [[ $backup_files_storage_type == "s3" ]]; then
            echo "[INFO] backup_files_storage_type == s3"
            retrieve_obj_from_existing_s3_backup "$existing_backup_files_bootstrap_bucket_name"
        else
            echo "Error: Invalid configuration for start_from_backup"
        fi
    fi
}

if [[ ${start_from_backup} == "true" ]]; then
echo "[INFO] START FROM EXISTING SAVE DATA/BACKUP REQUESTED FOR USE"
handle_start_from_backup ${start_from_backup} ${backup_files_storage_type} ${backup_files_local_path} ${backup_files_bootstrap_bucket_name} ${existing_backup_files_bootstrap_bucket_name}
fi

if [[ ${use_custom_gameusersettings} == "true" ]]; then
echo "[INFO] CUSTOM GameUserSettings.INI REQUESTED FOR USE"
handle_gameusersettings ${use_custom_gameusersettings} ${custom_gameusersettings_s3} ${custom_gameusersettings_github} ${gameusersettings_bucket_arn} ${github_url}
fi

if [[ ${use_custom_game_ini} == "true" ]]; then
echo "[INFO] CUSTOM Game.INI REQUESTED FOR USE"
handle_gameini ${use_custom_game_ini} ${custom_gameini_s3} ${custom_gameini_github} ${gameini_bucket_arn} ${github_url_gameini}
fi


chown -R steam:steam /ark-asa/ShooterGame/Saved
chmod -R 775 /ark-asa/ShooterGame/Saved
# Upload custom GameUserSettings.ini if user has use_custom_gameusersettings true and game_user_settings_ini_path defined
# %{ if use_custom_gameusersettings == "true" && custom_gameusersettings_s3 == "true" ~}
# retrieve_obj_from_s3 "${gameusersettings_bucket_arn}"
# %{ endif ~} 
# %{ if use_custom_gameusersettings == "true" && custom_gameusersettings_github == "true" ~}
# retrieve_obj_from_github "${gameusersettings_bucket_arn}"
# %{ endif ~}

# Start and enable the ASA service
systemctl daemon-reload
echo "[INFO] ENABLING ARK-ISLAND.SERVICE"
systemctl enable ark-island
echo "[INFO] STARTING ARK-ISLAND.SERVICE"
systemctl start ark-island

if [[ ${enable_s3_backups} == "true" ]]; then
echo "[INFO] S3 BBACKUPS ENABLED. CREATING /ark-asa/ark_backup_script.sh"
cat > /ark-asa/ark_backup_script.sh <<EOD
#!/bin/bash

# Backup variables
DIR_TO_BACKUP="/ark-asa/ShooterGame/Saved"
S3_BUCKET_NAME="${backup_s3_bucket_name}"

generate_timestamp() {
date '+%Y-%m-%d-%H-%M-%S'
}

TIMESTAMP="\$(generate_timestamp)"
BACKUP_FILENAME="${ark_session_name}_backup_"\$TIMESTAMP".tar.gz"

# Create backup
echo "[INFO] Creating Ark Backup"
tar -zcvf "\$BACKUP_FILENAME" "\$DIR_TO_BACKUP"

# Upload backup to S3
echo "[INFO] Uploading Ark Backup to s3"
aws s3 cp "\$BACKUP_FILENAME" s3://"\$S3_BUCKET_NAME"/ --region ${aws_region}

# Remove local backup file
echo "[INFO] Removing Local Ark Backup File"
rm "\$BACKUP_FILENAME"
EOD

chmod +x /ark-asa/ark_backup_script.sh

(crontab -l -u steam 2>/dev/null; echo "${backup_interval_cron_expression} /ark-asa/ark_backup_script.sh >> /ark-asa/ark_backup_log.log 2>&1") | crontab -u steam -
fi
