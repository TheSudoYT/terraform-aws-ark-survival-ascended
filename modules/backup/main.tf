// get the account ID. Used to create a globally unique S3 bucket name.
resource "aws_s3_bucket" "ark_backup_bucket" {
  count  = var.create_backup_s3_bucket == true ? 1 : 0

  bucket = "${data.aws_caller_identity.current.account_id}-${var.backup_s3_bucket_name}"
}

resource "aws_s3_bucket_acl" "ark_backup_bucket" {
  count = var.create_backup_s3_bucket == true ? 1 : 0

  bucket = aws_s3_bucket.ark_backup_bucket[0].id
  acl    = "private"
}

resource "aws_s3_account_public_access_block" "ark_backup_bucket" {
  count  = var.create_backup_s3_bucket == true ? 1 : 0

  block_public_acls   = true
  block_public_policy = true
}

resource "aws_s3_bucket_lifecycle_configuration" "example" {
  count  = var.create_backup_s3_bucket == true ? 1 : 0

  bucket = aws_s3_bucket.ark_backup_bucket[0].id

  rule {
    id = "BackupExpiration"

    status = "Enabled"

    expiration {
      days = var.s3_bucket_backup_retention
    }
  }
}