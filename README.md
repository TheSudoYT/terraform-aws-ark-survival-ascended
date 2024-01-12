# ark-aws-ascended-infra
Ark Survival Ascended (ASA) Server Infrastructure Terraform module.

## Donate
I do this in my free time. Consider donating to keep the project going and motivate me to maintain the repo, add new features, etc :) 

![Support on Patreon](https://img.shields.io/badge/Patreon-F96854?style=for-the-badge&logo=patreon&logoColor=white) 

[Support on Patreon](https://patreon.com/ThSudo?utm_medium=clipboard_copy&utm_source=copyLink&utm_campaign=creatorshare_creator&utm_content=join_link)

![Support on By Me A Coffee](https://img.shields.io/badge/Buy_Me_A_Coffee-FFDD00?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black)

[Support on BuyMeACoffee](https://www.buymeacoffee.com/TheSudo)

![Subscribe](https://img.shields.io/badge/YouTube-FF0000?style=for-the-badge&logo=youtube&logoColor=white)

[Subscribe on YouTube](https://www.youtube.com/c/TheSudo)

# How to Use
## Prerequisites
You must have the following to use this Terraform module:
- Terraform version >= 1.3.0 - [Install Terraform](https://developer.hashicorp.com/terraform/install)
- An AWS account

## Usage
Took 20 minutes on a t3.large

## Backups
This module includes the option to enable backups. Enabling this will backup the `ShooterGame/Saved` directory to an S3 bucket at the interval specified using cron. Backups will be retained in S3 based on the number of days specified by the input `s3_bucket_backup_retention`. This is to save money. Versioning, kms, and replication are disabled to save money.

>Note: Enabling this creates an additional S3 bucket. In testing, this adds an additional 0.10 USD ( 10 cents ) a month on average depending on the duration of backup retention, how often you backup, and how often you restore from backup. https://calculator.aws/#/addService

2 Files will be created on the ark server; `ark_backup_script.sh` on install and `ark_backup_log.log` when the first backup job runs. The backup log should show similiar to the one below if backup is a success:
```bash
ubuntu@ip-10-0-1-250:/ark-asa$ ls
Engine  Manifest_DebugFiles_Win64.txt  Manifest_NonUFSFiles_Win64.txt  Manifest_UFSFiles_Win64.txt  ShooterGame  ark_backup_log.log  ark_backup_script.sh  compatibilitytools.d  linux64  steamapps  steamclient.so
ubuntu@ip-10-0-1-250:/ark-asa$ cat ark_backup_log.log 
[INFO] Creating Ark Backup
tar: Removing leading `/' from member names
/ark-asa/ShooterGame/Saved/
/ark-asa/ShooterGame/Saved/SavedArks/
/ark-asa/ShooterGame/Saved/SavedArks/TheIsland_WP/
/ark-asa/ShooterGame/Saved/SavedArks/TheIsland_WP/TheIsland_WP.ark
/ark-asa/ShooterGame/Saved/Logs/
/ark-asa/ShooterGame/Saved/Logs/ShooterGame.log
/ark-asa/ShooterGame/Saved/Logs/FailedWaterDinoSpawns.log
/ark-asa/ShooterGame/Saved/Config/
/ark-asa/ShooterGame/Saved/Config/CrashReportClient/
/ark-asa/ShooterGame/Saved/Config/CrashReportClient/UECC-Windows-9D515DBA45100CBD707E679881FCDE73/
/ark-asa/ShooterGame/Saved/Config/CrashReportClient/UECC-Windows-9D515DBA45100CBD707E679881FCDE73/CrashReportClient.ini
/ark-asa/ShooterGame/Saved/Config/WindowsServer/
/ark-asa/ShooterGame/Saved/Config/WindowsServer/GameUserSettings.ini
/ark-asa/ShooterGame/Saved/Config/WindowsServer/Game.ini
[INFO] Uploading Ark Backup to s3
upload: ./ark-aws-ascended_backup_2024-01-01-18-47-04.tar.gz to s3://ark-backups-12345678912345/ark-aws-ascended_backup_2024-01-01-18-47-04.tar.gz
[INFO] Removing Local Ark Backup File
```

An the backup should be visible in the AWS S3 bucket.
- move data off EBS and restore from the target location OR
- Restore from EBS snapshot
- Price difference?
- 8.9 MB 

### Compute
- Can I make this stateless?

### Networking

## Using an Existing GameUserSettings.ini
You can use an existing GameUserSettings.ini so that the server starts with your custom settings. The following inputs are required to do this:

>Note: Terraform Module inputs that are also key=value pairs in the .ini files overwrite the .ini file options. For example, the `ark_session_name` input will overwrite the value for SessionName in your GameUserSettings.ini file if you provided a custom one.

| Input | Description |
| ------------- | ------------- |
| use_custom_gameusersettings = true | Must be set to pass a custom GameUserSettings.ini to the server on startup |
| custom_gameusersettings_s3 = true | Cannot be set when `custom_gameusersettings_github = true`. Set to true if you would like to upload an existing GameUserSettings.ini to an S3 bucket during terraform apply. Setting this to true will create an S3 bucket and upload the file from your PC to the S3 bucket. It will then download the file from the S3 bucket on server startup. You MUST also set `game_user_settings_ini_path` as a path on your local system relative to the terraform working directory. It is easiest to just place GameUserSettings.ini in the root of your terraform working directory and just provide `game_user_settings_ini_path = GameUserSettings.ini`. |
| game_user_settings_ini_path = "path/on/my/pc" | A path on your local system relative to the terraform working directory. It is easiest to just place GameUserSettings.ini in the root of your terraform working directory and just provide `game_user_settings_ini_path = GameUserSettings.ini`. Only used when `custom_gameusersettings_s3 = true`. |
| custom_gameusersettings_github = true | Cannot be set when `custom_gameusersettings_s3 = true`. Set to true if you would like to download an existing GameUserSettings.ini to the server from a GitHub URL. Must also provide `custom_gameusersettings_github_url = "https://my.url.com` with a valid URL to a public GitHub repo. |
| custom_gameusersettings_github_url = "https://my.url.com | A valid URL to a public GitHub repo to download an existing GameUserSettings.ini from onto the server during startup. Must have `custom_gameusersettings_github = true` and `use_custom_gameusersettings = true` to use.|

- Using the S3 option will instruct terraform to create an S3 bucket along with an EC2 instance profile that will have permissions to assume an IAM role that is also created. This role contains a policy to allow only the EC2 instance to access the S3 bucket to download GameUserSettings.ini. This also instructs the user_data script that runs when the server starts to download GameUserSettings.ini from that S3 bucket and place it in `/ark-asa/ShooterGame/Saved/Config/WindowsServer/GameUserSettings.ini`

- Using the GitHub option will simply instruct the user_data script that runs when the server starts to download GameUserSettings.ini to the server and place it in `/ark-asa/ShooterGame/Saved/Config/WindowsServer/GameUserSettings.ini`

## Using an Existing Game.ini
You can use an existing Game.ini so that the server starts with your custom settings. The following inputs are required to do this:

>Note: Terraform Module inputs that are also key=value pairs in the .ini files overwrite the .ini file options. For example, the `ark_session_name` input will overwrite the value for SessionName in your GameUserSettings.ini file if you provided a custom one.

| Input | Description |
| ------------- | ------------- |
| use_custom_game_ini = true | Must be set to pass a custom Game.ini to the server on startup |
| custom_gameini_s3 = true | Cannot be set when `custom_gameini_github = true`. Set to true if you would like to upload an existing Gameini.ini to an S3 bucket during terraform apply. Setting this to true will create an S3 bucket and upload the file from your PC to the S3 bucket. It will then download the file from the S3 bucket on server startup. You MUST also set `game_ini_path` as a path on your local system relative to the terraform working directory. It is easiest to just place Game.ini in the root of your terraform working directory and just provide `game_ini_path = Game.ini`. |
| game_ini_path = "path/on/my/pc" | A path on your local system relative to the terraform working directory. It is easiest to just place Game.ini in the root of your terraform working directory and just provide `game_ini_path = Game.ini`. Only used when `custom_gameini_s3 = true`. |
| custom_gameini_github = true | Cannot be set when `custom_gameini_s3 = true`. Set to true if you would like to download an existing Game.ini to the server from a GitHub URL. Must also provide `custom_gameini_github_url = "https://my.url.com` with a valid URL to a public GitHub repo. |
| custom_gameini_github_url = "https://my.url.com | A valid URL to a public GitHub repo to download an existing Game.ini from onto the server during startup. Must have `custom_gameini_github = true` and `use_custom_game_ini = true` to use.|

- Using the S3 option will instruct terraform to create an S3 bucket along with an EC2 instance profile that will have permissions to assume an IAM role that is also created. This role contains a policy to allow only the EC2 instance to access the S3 bucket to download Game.ini. This also instructs the user_data script that runs when the server starts to download Game.ini from that S3 bucket and place it in `/ark-asa/ShooterGame/Saved/Config/WindowsServer/Game.ini`

- Using the GitHub option will simply instruct the user_data script that runs when the server starts to download Game.ini to the server and place it in `/ark-asa/ShooterGame/Saved/Config/WindowsServer/Game.ini`

## Troubleshooting
- Monitoring the installation - You can view the user_data script that ran by connecting to your server via SSH using the public key you provided, ubuntu user, and the IP address of the server. Example: `ssh -i .\ark_public_key ubuntu@34.225.216.87`. Once on the server you can view the progress of the user_data script that installs and configures ark using the command `journalctl -xu cloud-final`. Use the space bar to scroll through the output line by line or `shift+g` to scroll the end of the output. If there is an obvios reason that ark failed to install or start in the way you expect, you can most likely find it here.

- Checking the ark service is running - You can run `systemctl status ark-island` to view the status of the ark server. The service should say `Active: active (running)`. If it does not, then the ark server failed to start or has stopped for some reason.

## Abandoned Features
| Feature | Reason for Abandoning | Comparable Feature Implemented |
| ------------- | ------------- | ------------- |
| Allow users to pass in GameUserSettings.ini from their local machine by providing the path to the file relative to the terraform working directory.  | Impossible without exceeding the allowable length of user_data.  | Using the AWS CLI and an EC2 instance profile to download GameUserSettings.ini from S3 or another remote location such as GitHub. |
| KMS Encryption  | It can get expensive and this is Ark not a bank or government system.  | None |
| S3 Replication  | Again, it can get expensive and this is Ark not a bank or government system.  | None |

## Future Features Roadmap
| Feature | Target Date |
| ------- | ----------- |
| RCON port | :white_check_mark: |
| port validation variable | :white_check_mark: |
| Input for GE Proton version | :white_check_mark: |
| Save interval | Jan 2024 |
| Restart interval | Jan 2024 |
| Backups - RPO interval, rolling histroy, restoring | Jan 2024 |
| Inputs for platform type | Jan 2024 |
| Inputs for mods list(string) | Jan 2024 |
| Allow users to define which map to use | Jan 2024 |
| Allow users to launch a cluster of multiple maps | Feb 2024 |
| Allow users to upload existing save game data when the server is started | Feb / March 2024 |
| Paramterize all available inputs for servers such as rates, crafting resource requirements, supply crate drops, etc. | April 2024 |
| Make compute stateless. Store data external from compute via RDS and EFS | Sometime 2024 ( I don't even know if this is possible ) |
| AWS SSM Support | Feb 2024 |
| Autoscaling Group Support | Feb 2024 |