#!/bin/bash

mkdir /opt/steam

apt-get update
apt-get install -y curl lib32gcc1 lsof git

#snap install steam
#STEAMDIR="/snap/steam/current"

# Install Proton from Glorious Eggroll to allow windows games to run on linux
PROTON_URL="https://github.com/GloriousEggroll/proton-ge-custom/releases/download/GE-Proton8-21/GE-Proton8-21.tar.gz"
PROTON_TGZ="$(basename "$PROTON_URL")"
PROTON_NAME="$(basename "$PROTON_TGZ" ".tar.gz")"
if [ ! -e "/opt/steam/$PROTON_TGZ" ]; then
  wget "$PROTON_URL" -O "/opt/steam/$PROTON_TGZ"
fi

wget -P /opt/steam https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
tar -xzf /opt/steam/steamcmd_linux.tar.gz -C /opt/steam 

sudo -u steam useradd -m -U steam

sudo -u steam mkdir /ark-asa
STEAMDIR="/ark-asa"
# Extract GE Proton into this user's Steam path
sudo -u steam mkdir -p "$STEAMDIR/compatibilitytools.d"
sudo -u steam tar -x -C "$STEAMDIR/compatibilitytools.d/" -f "/opt/steam/$PROTON_TGZ"

# Install default prefix into game compatdata path
[ -d "$STEAMDIR/steamapps/compatdata" ] || sudo -u steam mkdir -p "$STEAMDIR/steamapps/compatdata"
[ -d "$STEAMDIR/steamapps/compatdata/2430930" ] || \
  sudo -u steam cp "$STEAMDIR/compatibilitytools.d/$PROTON_NAME/files/share/default_pfx" "$STEAMDIR/steamapps/compatdata/2430930" -r

cat <<EOF > /opt/steam/download-ark.txt
@ShutdownOnFailedCommand 1 //set to 0 if updating multiple servers at once
@NoPromptForPassword 1
@sSteamCmdForcePlatformType Linux
force_install_dir /ark-asa
login anonymous 
app_update 2430930 validate
quit
EOF

sudo -u steam /opt/steam/steamcmd.sh +runscript /opt/steam/download-ark.txt

# Install the systemd service file for ARK Survival Ascended Dedicated Server (Island)
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
ExecStart=$STEAMDIR/compatibilitytools.d/$PROTON_NAME/proton run ArkAscendedServer.exe TheIsland_WP?listen?SessionName=${ark_session_name}?ServerAdminPassword=${server_admin_password}?Port=${game_client_port}?QueryPort=${steam_query_port}?MaxPlayers=${max_players}
Restart=on-failure
RestartSec=20s

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable ark-island
systemctl start ark-island

#/ShooterGame/Binaries/Linux/ArkAscendedServer.exe TheIsland_WP?listen?SessionName=${ark_session_name}?ServerAdminPassword=${server_admin_password}?Port=${game_client_port}?QueryPort=${steam_query_port}?MaxPlayers=${max_players}
