variables {
  // Infrastructure inputs
  instance_type         = "t3.large"
  create_ssh_key        = false
  //ssh_public_key        = "../../ark_public_key.pub"
  // Ark Application inputs
  ark_session_name      = "ark-aws-ascended"
  max_players           = "32"
  steam_query_port      = 27015
  game_client_port      = 7777
  server_admin_password = "RockwellSucks"
  is_password_protected = true
  join_password         = "RockWellSucks"
  // Custom GameUserSettings.ini inputs
  use_custom_gameusersettings        = true
  custom_gameusersettings_s3         = true
  game_user_settings_ini_path        = "TestGameUserSettings.ini"
  custom_gameusersettings_github     = true
  custom_gameusersettings_github_url = "https://raw.githubusercontent.com/TheSudoYT/ark-aws-ascended-infra/initial/TestGameUserSettings.ini?token=GHSAT0AAAAAACLHVUVTQQZCUG376AYN5MWYZMVX54Q"
  // Custom Game.ini inputs
  use_custom_game_ini       = true
  custom_gameini_s3         = true
  game_ini_path             = "TestGame.ini"
  custom_gameini_github     = true
  custom_gameini_github_url = "https://raw.githubusercontent.com/TheSudoYT/ark-aws-ascended-infra/initial/TestGame.ini?token=GHSAT0AAAAAACLHVUVSGK73KOM27224WCJWZMVYDPA"
  // Backup inputs
  enable_s3_backups               = false
  backup_s3_bucket_name           = ""
  backup_s3_bucket_arn            = ""
  backup_interval_cron_expression = "*/5 * * * *"
  create_backup_s3_bucket    = false
  s3_bucket_backup_retention = 7
  force_destroy              = true
}

provider "aws" {}

// Validate GameUserSettings.ini and Game.ini object when using custom ini with s3
run "validate_custom_ini_files_s3" {

  command = plan

  variables {
    use_custom_gameusersettings        = true
    custom_gameusersettings_s3         = true
    game_user_settings_ini_path        = "../../../TestGameUserSettings.ini"
    custom_gameusersettings_github     = false
    custom_gameusersettings_github_url = ""
    use_custom_game_ini       = true
    custom_gameini_s3         = true
    game_ini_path             = "../../../TestGame.ini"
    custom_gameini_github     = false
    custom_gameini_github_url = ""
  }

  # Check that GameUserSettings.ini object expected to exist in s3
  assert {
    condition     = aws_s3_object.gameusersettings[0].key == "GameUserSettings.ini"
    error_message = "Invalid GameUserSettings.ini in S3 or does not exist in S3 when its expected to."
  }

  # Check that Game.ini object expected to exist in s3
  assert {
    condition     = aws_s3_object.gameini[0].key == "Game.ini"
    error_message = "Invalid Game.ini in S3 or does not exist in S3 when its expected to."
  }
}

// Just make sure an s3 bucket is not created
run "validate_custom_ini_files_github" {

  command = plan

  variables {
    use_custom_gameusersettings        = true
    custom_gameusersettings_s3         = false
    game_user_settings_ini_path        = "../../../TestGameUserSettings.ini"
    custom_gameusersettings_github     = true
    custom_gameusersettings_github_url = "https://raw.githubusercontent.com/TheSudoYT/ark-aws-ascended-infra/initial/TestGameUserSettings.ini?token=GHSAT0AAAAAACLHVUVTFCHETVPC3XAVTGICZMVYWWQ"
    use_custom_game_ini       = true
    custom_gameini_s3         = false
    game_ini_path             = "../../../TestGame.ini"
    custom_gameini_github     = true
    custom_gameini_github_url = "https://raw.githubusercontent.com/TheSudoYT/ark-aws-ascended-infra/initial/TestGame.ini?token=GHSAT0AAAAAACLHVUVTSLPHAJ32H24IUCP4ZMVYWUA"
  }


  # Check that GameUserSettings.ini object expected to exist in s3
  assert {
    condition     = length(aws_s3_bucket.ark) == 0
    error_message = "S3 bucket attempting to be created when an S3 bucket is not expected to be created."
  }
}