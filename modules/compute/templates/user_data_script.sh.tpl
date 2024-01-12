#!/bin/bash

# Create directories
mkdir /opt/steam
mkdir /ark-asa

# Install software
echo "[INFO] INSTALLING SOFTWARE"
apt-get update
apt-get install -y curl lib32gcc1 lsof git awscli

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
ExecStart=$STEAMDIR/compatibilitytools.d/$PROTON_NAME/proton run ArkAscendedServer.exe TheIsland_WP?listen?SessionName=${ark_session_name} \
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
    aws s3 cp "$src" "$dst"
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
    wget -O "$dst" "$src"
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
    aws s3 cp "$src" "$dst"
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
    wget -O "$dst" "$src"
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

if [[ ${use_custom_gameusersettings} == "true" ]]; then
echo "[INFO] CUSTOM GameUserSettings.INI REQUESTED FOR USE"
handle_gameusersettings ${use_custom_gameusersettings} ${custom_gameusersettings_s3} ${custom_gameusersettings_github} ${gameusersettings_bucket_arn} ${github_url}
fi

if [[ ${use_custom_game_ini} == "true" ]]; then
echo "[INFO] CUSTOM Game.INI REQUESTED FOR USE"
handle_gameini ${use_custom_game_ini} ${custom_gameini_s3} ${custom_gameini_github} ${gameini_bucket_arn} ${github_url_gameini}
fi

chown -R steam:steam /ark-asa/ShooterGame/Saved
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
aws s3 cp "\$BACKUP_FILENAME" s3://"\$S3_BUCKET_NAME"/

# Remove local backup file
echo "[INFO] Removing Local Ark Backup File"
rm "\$BACKUP_FILENAME"
EOD

chmod +x /ark-asa/ark_backup_script.sh

(crontab -l -u steam 2>/dev/null; echo "${backup_interval_cron_expression} /ark-asa/ark_backup_script.sh >> /ark-asa/ark_backup_log.log 2>&1") | crontab -u steam -
fi
