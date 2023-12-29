resource "aws_s3_bucket" "ark" {
  count = var.custom_gameusersettings_s3 || var.custom_gameini_s3 == true ? 1 : 0

  bucket = "ark-app-${data.aws_region.current.name}-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_bucket_versioning" "ark" {
  count = var.custom_gameusersettings_s3 || var.custom_gameini_s3 == true ? 1 : 0

  bucket = aws_s3_bucket.ark[0].id

  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_object" "gameusersettings" {
  count = var.custom_gameusersettings_s3 == true ? 1 : 0

  bucket = aws_s3_bucket.ark[0].id
  key    = "GameUserSettings.ini"
  source = var.game_user_settings_ini_path
}

resource "aws_s3_object" "gameini" {
  count = var.custom_gameini_s3 == true ? 1 : 0

  bucket = aws_s3_bucket.ark[0].id
  key    = "Game.ini"
  source = var.game_ini_path
}