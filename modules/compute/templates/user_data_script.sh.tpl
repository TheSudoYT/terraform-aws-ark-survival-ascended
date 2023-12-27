#!/bin/bash

# Create directories
mkdir /opt/steam
mkdir /ark-asa

# Install software
apt-get update
apt-get install -y curl lib32gcc1 lsof git awscli

# Install Proton from Glorious Eggroll to allow windows games to run on linux
echo "[INFO] DOWNLOADING PROTON FROM GE"
PROTON_URL="https://github.com/GloriousEggroll/proton-ge-custom/releases/download/GE-Proton8-21/GE-Proton8-21.tar.gz"
PROTON_TGZ="$(basename "$PROTON_URL")"
PROTON_NAME="$(basename "$PROTON_TGZ" ".tar.gz")"
wget "$PROTON_URL" -O "/opt/steam/$PROTON_TGZ"

# Install steam cmd
echo "[INFO] DOWNLOADING AND INSTALLING STEAM CMD"
wget -P /opt/steam https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
tar -xzf /opt/steam/steamcmd_linux.tar.gz -C /opt/steam 
chmod 755 /opt/steam/steamcmd.sh

# Create steam user
useradd -m -U steam
chown -R steam:steam /ark-asa

# Extract GE Proton into the steam directory
STEAMDIR="/ark-asa"
sudo -u steam mkdir -p "$STEAMDIR/compatibilitytools.d"
sudo -u steam tar -x -C "$STEAMDIR/compatibilitytools.d/" -f "/opt/steam/$PROTON_TGZ"


# Install default prefix into game compatdata path
[ -d "$STEAMDIR/steamapps/compatdata" ] || sudo -u steam mkdir -p "$STEAMDIR/steamapps/compatdata"
[ -d "$STEAMDIR/steamapps/compatdata/2430930" ] || \
sudo -u steam cp "$STEAMDIR/compatibilitytools.d/$PROTON_NAME/files/share/default_pfx" "$STEAMDIR/steamapps/compatdata/2430930" -r

# Setup the steam cmd command to download for ASA
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
sudo -u steam /opt/steam/steamcmd.sh +runscript /opt/steam/download-ark.txt

# Install the systemd service file for ASA Dedicated Server (Island)
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

Restart=on-failure
RestartSec=20s

[Install]
WantedBy=multi-user.target
EOF

# Function for getting GameUserSettings from S3
retrieve_obj_from_s3() {
  local src="$1"
  local dst="/ark-asa/ShooterGame/Saved/Config/WindowsServer/GameUserSettings.ini"

  if [[ "$src" == "" ]]; then
    echo "[ERROR] Did not detect a valid path."
    exit_script 10
  else
    echo "[INFO] Copying $src to $dst..."
    aws s3 cp "$src" "$dst"
  fi
}

# Function for getting GameUserSettings from GitHub raw
retrieve_obj_from_web() {
  local src="$1"
  local dst="/ark-asa/ShooterGame/Saved/Config/WindowsServer/GameUserSettings.ini"

  if [[ "$src" == "" ]]; then
    echo "[ERROR] Did not detect a valid path."
    exit_script 10
  else
    echo "[INFO] Copying $src to $dst..."
    wget "$src" "$dst"
  fi
}

# Upload custom GameUserSettings.ini if user has use_custom_gameusersettings true and game_user_settings_ini_path defined
%{ if use_custom_gameusersettings == "true" && custom_gameusersettings_s3 == "true" ~}
retrieve_obj_from_s3 "${game_user_settings_ini_path}"
%{ else use_custom_gameusersettings == "true" && custom_gameusersettings_github == "true"~}
retrieve_obj_from_web "${game_user_settings_ini_path}"
%{ endif ~}

# Start and enable the ASA service
systemctl daemon-reload
systemctl enable ark-island
systemctl start ark-island

