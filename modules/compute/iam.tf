resource "aws_iam_role" "instance_role" {
  count = var.custom_gameusersettings_s3 == true || var.custom_gameini_s3 == true || var.start_from_backup == true || var.enable_s3_backups == true ? 1 : 0

  name               = "ark-instance-role-${data.aws_region.current.name}"
  path               = "/"
  assume_role_policy = file("${path.module}/templates/ark-instance-role.json")
}

resource "aws_iam_role_policy" "instance_role_policy" {
  count = var.use_custom_gameusersettings == true && var.custom_gameusersettings_s3 == true || var.use_custom_gameusersettings == true && var.custom_gameini_s3 == true || var.start_from_backup == true || var.enable_s3_backups == true ? 1 : 0

  name   = "ark-instance-role-policy-${data.aws_region.current.name}"
  policy = data.aws_iam_policy_document.ark_policy[0].json

  # Keeping for my own edification
  # templatefile(
  #     "${path.module}/templates/ark-instance-role-policy.json",
  #     {
  #       gameusersettings_s3_bucket_arn = var.custom_gameusersettings_s3 == true ? aws_s3_bucket.ark[0].arn : ""
  #       custom_gameusersettings_s3     = var.custom_gameusersettings_s3 == true ? "${var.custom_gameusersettings_s3}" : false
  #       gameini_s3_bucket_arn          = var.custom_gameini_s3 == true ? aws_s3_bucket.ark[0].arn : ""
  #       custom_gameini_s3              = var.custom_gameini_s3 == true ? "${var.custom_gameini_s3}" : false
  #       enable_s3_backups              = var.enable_s3_backups == true ? "${var.enable_s3_backups}" : false
  #       backup_s3_bucket_arn           = var.enable_s3_backups == true ? "${var.backup_s3_bucket_arn}" : ""
  #     }
  #   )
  role = aws_iam_role.instance_role[0].id
}


resource "aws_iam_instance_profile" "instance_profile" {
  count = var.use_custom_gameusersettings == true && var.custom_gameusersettings_s3 == true || var.use_custom_gameusersettings == true && var.custom_gameini_s3 == true || var.start_from_backup == true || var.enable_s3_backups == true ? 1 : 0

  name = "ark-instance-profile-${data.aws_region.current.name}"
  path = "/"
  role = aws_iam_role.instance_role[0].name
}

data "aws_iam_policy_document" "ark_policy" {
  count = var.use_custom_gameusersettings == true && var.custom_gameusersettings_s3 == true || var.use_custom_gameusersettings == true && var.custom_gameini_s3 || var.start_from_backup == true || var.enable_s3_backups == true == true ? 1 : 0
  statement {
    sid = "InteractWithS3"

    actions = [
      "s3:PutObject",
      "s3:ListBucket",
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:GetBucketLocation",
    ]

    resources = compact([
      var.custom_gameusersettings_s3 == true ? aws_s3_bucket.ark[0].arn : "",
      var.custom_gameusersettings_s3 == true ? "${aws_s3_bucket.ark[0].arn}/*" : "",
      var.custom_gameini_s3 == true ? aws_s3_bucket.ark[0].arn : "",
      var.custom_gameini_s3 == true ? "${aws_s3_bucket.ark[0].arn}/*" : "",
      var.enable_s3_backups == true ? var.backup_s3_bucket_arn : "",
      var.enable_s3_backups == true ? "${var.backup_s3_bucket_arn}/*" : "",
      var.start_from_backup == true && var.backup_files_storage_type == "local" ? aws_s3_bucket.ark_bootstrap[0].arn : "",
      var.start_from_backup == true && var.backup_files_storage_type == "local" ? "${aws_s3_bucket.ark_bootstrap[0].arn}/*" : "",
    ])
  }
}
