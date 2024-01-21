resource "aws_s3_bucket" "ark" {
  count = var.use_custom_gameusersettings == true && var.custom_gameusersettings_s3 == true || var.use_custom_gameusersettings == true && var.custom_gameini_s3 == true ? 1 : 0

  bucket = "ark-app-${data.aws_region.current.name}-${data.aws_caller_identity.current.account_id}"

}

resource "aws_s3_bucket_versioning" "ark" {
  count = var.use_custom_gameusersettings == true && var.custom_gameusersettings_s3 == true || var.use_custom_gameusersettings == true && var.custom_gameini_s3 == true ? 1 : 0

  bucket = aws_s3_bucket.ark[0].id

  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_object" "gameusersettings" {
  count = var.use_custom_gameusersettings == true && var.custom_gameusersettings_s3 == true ? 1 : 0

  bucket = aws_s3_bucket.ark[0].id
  key    = "GameUserSettings.ini"
  source = var.game_user_settings_ini_path
}

resource "aws_s3_object" "gameini" {
  count = var.use_custom_gameusersettings == true && var.custom_gameini_s3 == true ? 1 : 0

  bucket = aws_s3_bucket.ark[0].id
  key    = "Game.ini"
  source = var.game_ini_path
}


### Start From Backup ###
resource "aws_s3_bucket" "ark_bootstrap" {
  count = var.start_from_backup == true && var.backup_files_storage_type == "local" ? 1 : 0

  bucket = "ark-bootstrap-local-saves-${data.aws_region.current.name}-${data.aws_caller_identity.current.account_id}"

}

resource "aws_s3_bucket_versioning" "ark_bootstrap" {
  count = var.start_from_backup == true && var.backup_files_storage_type == "local" ? 1 : 0

  bucket = aws_s3_bucket.ark_bootstrap[0].id

  versioning_configuration {
    status = "Disabled"
  }
}

locals {
  files = var.start_from_backup == true && var.backup_files_storage_type == "local" ? fileset(var.backup_files_local_path, "*") : []
}

resource "aws_s3_object" "bootstrap_savegame_files" {
  for_each = { for f in local.files : f => f }

  bucket = aws_s3_bucket.ark_bootstrap[0].id
  key    = basename(each.value)
  source = "${var.backup_files_local_path}/${each.value}"
}