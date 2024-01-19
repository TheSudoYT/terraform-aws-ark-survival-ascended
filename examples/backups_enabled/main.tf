module "asa" {
  source = "TheSudoYT/ark-survival-ascended/aws"

  # Infrastructure inputs
  ge_proton_version = "8-27"
  instance_type     = "t3.xlarge"
  create_ssh_key    = true
  ssh_public_key    = "../../ark_public_key.pub"
  # Ark Application inputs
  use_battleye               = false
  auto_save_interval         = 20.0
  ark_session_name           = "ark-aws-ascended"
  max_players                = "32"
  enable_rcon                = true
  rcon_port                  = 27011
  steam_query_port           = 27015
  game_client_port           = 7777
  server_admin_password      = "RockwellSucks"
  is_password_protected      = true
  join_password              = "RockWellSucks"
  enable_s3_backups          = true
  create_backup_s3_bucket    = true
  s3_bucket_backup_retention = 7
  force_destroy              = true
  backup_s3_bucket_arn       = ""
  backup_s3_bucket_name      = ""
}
