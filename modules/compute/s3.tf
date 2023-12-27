resource "aws_s3_bucket" "ark" {
  bucket = "ark-app-${data.aws_region.current.name}-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_bucket_versioning" "ark" {
  bucket = aws_s3_bucket.ark.id

  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_object" "gameusersettings" {
  bucket = aws_s3_bucket.ark.id
  key    = "GameUserSettings.ini"
  source = var.game_user_settings_ini_path
}