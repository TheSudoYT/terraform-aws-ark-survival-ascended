# Starting an Ark Server From Existing Save Data ( Restoring from Backup )
An example of using the inputs required to start the server with existing save data.

## Details
These inputs are required when migrating from an existing server with existing data or recovering from a deleted server.

> [!WARNING]
> When `backup_files_storage_type = "s3"` using The objects in the S3 bucket must not be compressed and must be in the root of the S3 bucket. The bucket's root directroy will be synced to the SaveGame directory.

> [!WARNING]
> When `backup_files_storage_type = "local"` using The objects/files in the directory you specify with `backup_files_local_path` must not be compressed. Terraform will iterate through each file in that directory and upload it to the root of an S3 bucket it creates.

- `backup_files_storage_type = "local"` will instruct terraform to create an S3 bucket named `ark-bootstrap-local-saves-region-accID` and upload the save files from your local PC `backup_files_local_path` directory specified to that bucket. The user_data script on the EC2 instance will download the files from that S3 bucket when the server starts and place them in the `/ark-ark-survival-ascended/ShooterGame/Saved/SaveGames` directory.

- `backup_files_storage_type = "s3"` Is informing terraform that you have an existing S3 bucket somewhere that contains the save game data. The EC2 user_data script will attempt to sync the root of that S3 bucket with the SaveGames directory of ark. That is why it is important that the objects be uncompressed and in the root of the directory. 

> [!WARNING]
> When `backup_files_storage_type = "local"` using The objects/files in the directory you specify with `backup_files_local_path` must not be compressed. Terraform will iterate through each file in that directory and upload it to the root of an S3 bucket it creates.

## Usage - Restore From Local Files
Relevant inputs:

```HCL
  start_from_backup         = true
  backup_files_storage_type = "local"
  backup_files_local_path   = "../../assets"
```

> [!WARNING]
> When `backup_files_storage_type = "s3"` using The objects in the S3 bucket must not be compressed and must be in the root of the S3 bucket. The bucket's root directroy will be synced to the SaveGame directory.

## Usage - Restore From an Existing S3 Bucket ( Bring Your Own S3 Bucket)
Relevant inputs:

```HCL
  start_from_backup         = true
  backup_files_storage_type = "s3"
  existing_backup_files_bootstrap_bucket_arn  = "arn:aws:s3:::ark-existing-s3-bucket-bootstrap"
  existing_backup_files_bootstrap_bucket_name = "ark-existing-s3-bucket-bootstrap"
```
