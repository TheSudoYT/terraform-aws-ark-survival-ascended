resource "aws_s3_bucket" "ark_backup_bucket" {
  count = var.create_backup_s3_bucket == true ? 1 : 0

  bucket = "ark-backups-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_bucket_versioning" "ark_backup_versioning" {
  count = var.create_backup_s3_bucket == true ? 1 : 0

  bucket = aws_s3_bucket.ark_backup_bucket[0].id

  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "example" {
  count = var.create_backup_s3_bucket == true ? 1 : 0

  bucket = aws_s3_bucket.ark_backup_bucket[0].id

  rule {
    id = "BackupExpiration"

    status = "Enabled"

    expiration {
      days = var.s3_bucket_backup_retention
    }
  }
}