#!/bin/bash

apt-get update
apt-get install -y curl lib32gcc1 lsof git

mkdir /ark-asa
mkdir /opt/steam

wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz && tar -xzf steamcmd_linux.tar.gz -C /opt/steam 

cat <<EOF > /opt/steam/download-ark.txt
@ShutdownOnFailedCommand 1 //set to 0 if updating multiple servers at once
@NoPromptForPassword 1
@sSteamCmdForcePlatformType Linux
force_install_dir /ark-asa
login anonymous 
app_update 2430930 validate
quit
EOF

/opt/steam/steamcmd.sh +runscript /opt/steam/download-ark.txt

/ShooterGame/Binaries/Linux/ArkAscendedServer.exe TheIsland_WP?listen?SessionName=${ark_session_name}?ServerAdminPassword=${server_admin_password}?Port=${game_client_port}?QueryPort=${steam_query_port}?MaxPlayers=${max_players}
