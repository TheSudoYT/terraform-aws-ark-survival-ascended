# ark-aws-ascended-infra
ASA Server Infrastructure

## Submodules

### Backup
- data is persisted on an EBS volume
- move data off EBS and restore from the target location OR
- Restore from EBS snapshot
- Price difference?

### Compute
- Can I make this stateless?

### Networking

## Abandoned Features
| Feature | Reason for Abandoning | Comparable Feature Implemented |
| ------------- | ------------- | ------------- |
| Allow users to pass in GameUserSettings.ini from their local machine by providing the path to the file relative to the terraform working directory.  | Impossible without exceeding the allowable length of user_data.  | Using the AWS CLI and an EC2 instance profile to download GameUserSettings.ini from S3 or another remote location such as GitHub. |
| KMS Encryption  | It can get expensive and this is Ark not bank or government system.  | None |
| S3 Replication  | Again, it can get expensive and this is Ark not bank or government system.  | None |