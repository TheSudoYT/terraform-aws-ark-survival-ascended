output "ssh_key_name" {
  value = aws_key_pair.ssh_key[*].key_name
}

output "server_using_custom_gameusersettingsini" {
  value = var.use_custom_gameusersettings
}

output "server_using_custom_gameini" {
  value = var.use_custom_game_ini
}

output "server_is_password_protected" {
  value = var.is_password_protected
}

output "join_password" {
  value = var.join_password
}

output "max_players" {
  value = var.max_players
}

output "steam_query_port" {
  value = var.steam_query_port
}

output "game_client_port" {
  value = var.game_client_port
}

output "admin_commands_password" {
  value = var.server_admin_password
}

output "session_name" {
  value = var.ark_session_name
}


