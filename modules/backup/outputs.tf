output "backup_s3_bucket_name" {
  value = aws_s3_bucket.ark_backup_bucket[*].id
}

output "backup_s3_bucket_arn" {
  value = aws_s3_bucket.ark_backup_bucket[*].arn
}
