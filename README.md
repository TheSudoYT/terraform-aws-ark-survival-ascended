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

# About
This module allows you to quickly deploy an Ark Survival Ascended server on AWS. Ark will run using GloriousEggroll Proton. A desired version of GE Proton can be chosen using the `ge_proton_version` input. 

### Key Features
- Ark SA running on Ubuntu with GE Proton
- The ability to use an existing GameUserSettings.ini and Game.ini
- Most GameUserSettings.ini settings are configurable inputs for creating a brand new configuration
- Ability to store backups in S3 at a defined interval

### Supported Maps
| Map Name | Systemd Service Name |
| -------- | --------------- |
| The Island | ark-island |

### Planned Features Roadmap
| Feature | Target Date |
| ------- | ----------- |
| Inputs for mods list(string) | Jan 2024 |
| Inputs for platform type | Jan 2024 |
| Replace stand alone EC2 instance with Autoscaling group | Feb 2024 |
| Parametrize Game.ini options | Feb 2024
| Configurable Restart interval | Feb 2024 |
| Restore from backups and use existing save games | Feb 2024 |
| Allow users to define which map to use | Feb 2024 |
| Allow users to launch a cluster of multiple maps | March 2024 |
| Make compute stateless. Store data external from compute via RDS and EFS | Sometime 2024 ( I don't even know if this is possible ) |
| AWS SSM Support for SSH | March 2024 |

# How to Use
## Prerequisites
You must have the following to use this Terraform module:
- Terraform version >= 1.5.0 - [Install Terraform](https://developer.hashicorp.com/terraform/install)
- An AWS account

## Usage
1. Create a file named `main.tf`
2. Add the following as a minimum. See all available inputs in the "Inputs" section of this README. Inputs not defined will use their default values.
```hcl
module "ark-survival-ascended" {
  source  = "TheSudoYT/ark-survival-ascended/aws"

  ge_proton_version = "8-27"
  instance_type     = "t3.xlarge"
  create_ssh_key    = true
  ssh_public_key    = "../../ark_public_key.pub"
  ark_session_name      = "ark-aws-ascended"
  max_players           = "32"
  is_password_protected = true
  join_password         = "RockWellSucks"
  enable_s3_backups               = false
}
```
3. Choose your inputs - `GameUserSettings.ini` inputs use default values unless you provide a value OTHER than the default value. Ark will use the settings from a custom GameUserSettings.ini file if you choose to use one. Modifying an input that is a GameUserSettings.ini setting while also using a custom GameUserSettings.ini file will result in that specific setting being overwritten in your custom file.
4. Initialize Terraform - Run `terraform init` to download the module and providers.
5. Create the Ark server and Infrastructure - Run `terraform apply` to start deploying the infrastructure.

## Accessing the Server
> [!NOTE]
> In testing it takes approximately 15 to 20 minutes on a t3.xlarge for steam to download and configure ark.

The terraform apply will complete, but the server will not appear in the server list until this completes. You can SSH into your server `ssh -i my_ark_key.pem ubuntu@1.2.3.4` and use `journalctl -xu cloud-final` to monitor the install. See the troubleshooting section of the README if you continue to have problems.

> [!NOTE]
> In testing it takes approximately 3 to 5 minutes for your server to appear on the server list after installation is complete.

Ensure you tick the `show player servers` box to view your server:
![Show Player Servers](docs/images/show_player_servers.jpg)


## Backups
This module includes the option to enable backups. Enabling this will backup the `ShooterGame/Saved` directory to an S3 bucket at the interval specified using cron. Backups will be retained in S3 based on the number of days specified by the input `s3_bucket_backup_retention`. This is to save money. Versioning, kms, and replication are disabled to save money.

> [!NOTE] 
> Enabling this creates an additional S3 bucket. In testing, this adds an additional 0.10 USD ( 10 cents ) a month on average depending on the duration of backup retention, how often you backup, and how often you restore from backup. https://calculator.aws/#/addService

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

The backup should be visible in the AWS S3 bucket after the first specified backup interval time frame passes.

## Using an Existing GameUserSettings.ini
You can use an existing GameUserSettings.ini so that the server starts with your custom settings. The following inputs are required to do this:

> [!NOTE]
> Terraform Module inputs that are also `key=value` pairs in the .ini files overwrite the .ini file options. For example, the `ark_session_name` input will overwrite the value for SessionName in your GameUserSettings.ini file if you provided a custom one.

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

> [!NOTE]
> Terraform Module inputs that are also `key=value` pairs in the .ini files overwrite the .ini file options. For example, the `ark_session_name` input will overwrite the value for SessionName in your GameUserSettings.ini file if you provided a custom one.

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

## Future Features Roadmap (TO DO)
| Feature | Target Date |
| ------- | ----------- |
| RCON port | :white_check_mark: |
| port validation variable | :white_check_mark: |
| Input for GE Proton version | :white_check_mark: |
| Save interval | :white_check_mark: |
| Paramaterize most of GUS.ini | :white_check_mark: |
| What happens if the session name is taken? | idk |
| Add terraform-test to CI precommit and PR | now |
| lifecycle ignore ssh 22 | meh |
| Parametrize Game.ini options | Jan 2024
| Restart interval | Jan 2024 |
| Backups - RPO interval, rolling histroy, restoring | Jan 2024 |
| Inputs for platform type | Jan 2024 |
| Inputs for mods list(string) | Jan 2024 |
| Allow users to define which map to use | Jan 2024 |
| Allow users to launch a cluster of multiple maps | Feb 2024 |
| Allow users to upload existing save game data when the server is started | Feb / March 2024 |
| Parameterize missing inputs | April 2024 or whenever someone requests a feature |
| Make compute stateless. Store data external from compute via RDS and EFS | Sometime 2024 ( I don't even know if this is possible ) |
| AWS SSM Support | Feb 2024 |
| Autoscaling Group Support | Feb 2024 |

## Examples
- [Using a Custom GameUserSettings and Game.ini From S3](https://github.com/TheSudoYT/terraform-aws-ark-survival-ascended/tree/main/examples/custom_ini_with_s3)
- [Using a Custom GameUserSettings and Game.ini From GitHub](https://github.com/TheSudoYT/terraform-aws-ark-survival-ascended/tree/main/examples/custom_ini_with_s3)
- [Enabling backups to S3](https://github.com/TheSudoYT/terraform-aws-ark-survival-ascended/tree/main/examples/backups_enabled)
- [Using Default Ark Settings](https://github.com/TheSudoYT/terraform-aws-ark-survival-ascended/tree/main/examples/vanilla_ark_default_settings)
- [All Inputs]() Combines custom INI files with inputs that overwrite the custom settings

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ark_backup"></a> [ark\_backup](#module\_ark\_backup) | ./modules/backup | n/a |
| <a name="module_ark_compute"></a> [ark\_compute](#module\_ark\_compute) | ./modules/compute | n/a |
| <a name="module_ark_vpc"></a> [ark\_vpc](#module\_ark\_vpc) | ./modules/networking | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_logging"></a> [admin\_logging](#input\_admin\_logging) | If True, logs all admin commands to in-game chat. | `bool` | `false` | no |
| <a name="input_allow_anyone_baby_imprint_cuddle"></a> [allow\_anyone\_baby\_imprint\_cuddle](#input\_allow\_anyone\_baby\_imprint\_cuddle) | If True, allows anyone to take care of a baby creatures (cuddle etc.), not just whomever imprinted on it. | `bool` | `false` | no |
| <a name="input_allow_flyer_carry_pve"></a> [allow\_flyer\_carry\_pve](#input\_allow\_flyer\_carry\_pve) | If True, allows flying creatures to pick up wild creatures in PvE. | `bool` | `false` | no |
| <a name="input_allow_raid_dino_feeding"></a> [allow\_raid\_dino\_feeding](#input\_allow\_raid\_dino\_feeding) | If True, allows Titanosaurs to be permanently tamed (namely allow them to be fed). Note: in The Island only spawns a maximum of 3 Titanosaurs, so 3 tamed ones should ultimately block any more ones from spawning. | `bool` | `false` | no |
| <a name="input_allow_third_person_player"></a> [allow\_third\_person\_player](#input\_allow\_third\_person\_player) | If False, disables third person camera allowed by default on all dedicated servers. | `bool` | `true` | no |
| <a name="input_always_allow_structure_pickup"></a> [always\_allow\_structure\_pickup](#input\_always\_allow\_structure\_pickup) | If True disables the timer on the quick pick-up system. | `bool` | `false` | no |
| <a name="input_ami_id"></a> [ami\_id](#input\_ami\_id) | The AMI ID to use. Not providing one will result in the latest version of Ubuntu Focal 20.04 being used | `string` | `null` | no |
| <a name="input_ark_security_group_id"></a> [ark\_security\_group\_id](#input\_ark\_security\_group\_id) | The ID of the security group to use with the EC2 instance | `string` | `""` | no |
| <a name="input_ark_session_name"></a> [ark\_session\_name](#input\_ark\_session\_name) | The name of the Ark server as it appears in the list of servers when users look for a server to join | `string` | `"ark-aws-ascended"` | no |
| <a name="input_ark_subnet_id"></a> [ark\_subnet\_id](#input\_ark\_subnet\_id) | The ID of the security group to use with the EC2 instance | `string` | `""` | no |
| <a name="input_auto_save_interval"></a> [auto\_save\_interval](#input\_auto\_save\_interval) | Set interval for automatic saves. Must be a float. pattern allows float numbers like 15.0, 3.14, etc. Setting this to 0 will cause constant saving. | `number` | `15` | no |
| <a name="input_backup_interval_cron_expression"></a> [backup\_interval\_cron\_expression](#input\_backup\_interval\_cron\_expression) | How often to backup the ShooterGame/Saved directory to S3 in cron expression format (https://crontab.cronhub.io/) | `string` | `""` | no |
| <a name="input_backup_s3_bucket_arn"></a> [backup\_s3\_bucket\_arn](#input\_backup\_s3\_bucket\_arn) | The ARN of the s3 bucket that you would like to use for ShooterGame/Saved directory backups | `string` | `""` | no |
| <a name="input_backup_s3_bucket_name"></a> [backup\_s3\_bucket\_name](#input\_backup\_s3\_bucket\_name) | The name of the S3 bucket to backup the ShooterGame/Saved directory to | `string` | `""` | no |
| <a name="input_clamp_resource_harvest_damage"></a> [clamp\_resource\_harvest\_damage](#input\_clamp\_resource\_harvest\_damage) | If True, limit the damage caused by a tame to a resource on harvesting based on resource remaining health. Note: enabling this setting may result in sensible resource harvesting reduction using high damage tools or creatures. | `bool` | `false` | no |
| <a name="input_create_backup_s3_bucket"></a> [create\_backup\_s3\_bucket](#input\_create\_backup\_s3\_bucket) | True or False. Do you want to create an S3 bucket to FTP backups into | `bool` | `false` | no |
| <a name="input_create_ssh_key"></a> [create\_ssh\_key](#input\_create\_ssh\_key) | True or False. Determines if an SSH key is created in AWS | `bool` | `true` | no |
| <a name="input_custom_gameini_github"></a> [custom\_gameini\_github](#input\_custom\_gameini\_github) | True or False. Set true if use\_custom\_gameini is true and you want to download them from github. Must be a public repo. | `bool` | `false` | no |
| <a name="input_custom_gameini_github_url"></a> [custom\_gameini\_github\_url](#input\_custom\_gameini\_github\_url) | The URL to the Game.ini file on a public GitHub repo. Used when custom\_gameini\_github and use\_custom\_game\_ini both == true. | `string` | `""` | no |
| <a name="input_custom_gameini_s3"></a> [custom\_gameini\_s3](#input\_custom\_gameini\_s3) | True or False. Set true if use\_custom\_gameini is true and you want to upload and download them from an S3 bucket during installation | `bool` | `false` | no |
| <a name="input_custom_gameusersettings_github"></a> [custom\_gameusersettings\_github](#input\_custom\_gameusersettings\_github) | True or False. Set true if use\_custom\_gameusersettings is true and you want to download them from github. Must be a public repo. | `bool` | `false` | no |
| <a name="input_custom_gameusersettings_github_url"></a> [custom\_gameusersettings\_github\_url](#input\_custom\_gameusersettings\_github\_url) | The URL to the GameUserSettings.ini file on a public GitHub repo. Used when custom\_gameusersettings\_github and custom\_game\_usersettings both == true. | `string` | `""` | no |
| <a name="input_custom_gameusersettings_s3"></a> [custom\_gameusersettings\_s3](#input\_custom\_gameusersettings\_s3) | True or False. Set true if use\_custom\_gameusersettings is true and you want to upload and download them from an S3 bucket during installation | `bool` | `false` | no |
| <a name="input_day_cycle_speed_scale"></a> [day\_cycle\_speed\_scale](#input\_day\_cycle\_speed\_scale) | Specifies the scaling factor for the passage of time in the ARK during the day. This value determines the length of each day, relative to the length of each night (as specified by NightTimeSpeedScale). Lowering this value increases the length of each day. | `number` | `1` | no |      
| <a name="input_day_time_speed_scale"></a> [day\_time\_speed\_scale](#input\_day\_time\_speed\_scale) | Specifies the scaling factor for the passage of time in the ARK during the day. This value determines the length of each day, relative to the length of each night (as specified by NightTimeSpeedScale). Lowering this value increases the length of each day. | `number` | `1` | no |
| <a name="input_difficulty_offset"></a> [difficulty\_offset](#input\_difficulty\_offset) | Specifies the difficulty level. | `number` | `1` | no |
| <a name="input_dino_character_food_drain_multiplier"></a> [dino\_character\_food\_drain\_multiplier](#input\_dino\_character\_food\_drain\_multiplier) | Specifies the scaling factor for creatures' food consumption. Higher values increase food consumption (creatures get hungry faster). It also affects the taming-times. | `number` | `1` | no |
| <a name="input_dino_character_health_recovery_multiplier"></a> [dino\_character\_health\_recovery\_multiplier](#input\_dino\_character\_health\_recovery\_multiplier) | Specifies the scaling factor for creatures' health recovery. Higher values increase the recovery rate (creatures heal faster). | `number` | `1` | no |
| <a name="input_dino_character_stamina_drain_multiplier"></a> [dino\_character\_stamina\_drain\_multiplier](#input\_dino\_character\_stamina\_drain\_multiplier) | Specifies the scaling factor for creatures' stamina consumption. Higher values increase stamina consumption (creatures get tired faster). | `number` | `1` | no |
| <a name="input_dino_damage_multiplier"></a> [dino\_damage\_multiplier](#input\_dino\_damage\_multiplier) | Specifies the scaling factor for the damage wild creatures deal with their attacks. The default value 1 provides normal damage. Higher values increase damage. Lower values decrease it. | `number` | `1` | no |
| <a name="input_dino_resistance_multiplier"></a> [dino\_resistance\_multiplier](#input\_dino\_resistance\_multiplier) | Specifies the scaling factor for the resistance to damage wild creatures receive when attacked. The default value 1 provides normal damage. Higher values decrease resistance, increasing damage per attack. Lower values increase it, reducing damage per attack. A value of 0.5 results in a creature taking half damage while a value of 2.0 would result in a creature taking double normal damage. | `number` | `1` | no |
| <a name="input_disable_dino_decay_pve"></a> [disable\_dino\_decay\_pve](#input\_disable\_dino\_decay\_pve) | If True, disables the creature decay in PvE mode. Note: after patch 273.691, in PvE mode the creature auto-unclaim after decay period has been disabled. | `bool` | `false` | no |
| <a name="input_disable_imprint_dino_buff"></a> [disable\_imprint\_dino\_buff](#input\_disable\_imprint\_dino\_buff) | If True, disables the creature imprinting player Stat Bonus. Where whomever specifically imprinted on the creature, and raised it to have an Imprinting Quality, gets extra Damage/Resistance buff. | `bool` | `false` | no |
| <a name="input_disable_pve_gamma"></a> [disable\_pve\_gamma](#input\_disable\_pve\_gamma) | If True, prevents use of console command gamma in PvE mode. | `bool` | `false` | no |
| <a name="input_disable_structure_decay_pve"></a> [disable\_structure\_decay\_pve](#input\_disable\_structure\_decay\_pve) | If True, disables the gradual auto-decay of player structures. | `bool` | `false` | no |
| <a name="input_disable_weather_fog"></a> [disable\_weather\_fog](#input\_disable\_weather\_fog) | If True, disables fog. | `bool` | `false` | no |
| <a name="input_dont_notify_player_joined"></a> [dont\_notify\_player\_joined](#input\_dont\_notify\_player\_joined) | If True, globally disables player joins notifications. | `bool` | `false` | no |
| <a name="input_ebs_volume_size"></a> [ebs\_volume\_size](#input\_ebs\_volume\_size) | The size of the EBS volume attached to the EC2 instance | `number` | `50` | no |
| <a name="input_enable_extra_structure_prevention_volumes"></a> [enable\_extra\_structure\_prevention\_volumes](#input\_enable\_extra\_structure\_prevention\_volumes) | If True, disables building in specific resource-rich areas, in particular setup on The Island around the major mountains. | `bool` | `false` | no |
| <a name="input_enable_pvp_gamma"></a> [enable\_pvp\_gamma](#input\_enable\_pvp\_gamma) | If True, allows use of console command gamma in PvP mode. | `bool` | `false` | no |
| <a name="input_enable_rcon"></a> [enable\_rcon](#input\_enable\_rcon) | True or False. Enable RCON or not | `bool` | `false` | no |
| <a name="input_enable_s3_backups"></a> [enable\_s3\_backups](#input\_enable\_s3\_backups) | True or False. Set to true to enable backing up of the ShooterGame/Saved directory to S3 | `bool` | `false` | no |
| <a name="input_existing_ssh_key_name"></a> [existing\_ssh\_key\_name](#input\_existing\_ssh\_key\_name) | The name of an EXISTING SSH key for use with the EC2 instance | `string` | `null` | no |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | True or False. Set to true if you want Terraform destroy commands to have the ability to destroy the backup bucket while it still containts backup files | `bool` | `false` | no |
| <a name="input_game_client_port"></a> [game\_client\_port](#input\_game\_client\_port) | The port that the game client listens on | `number` | `7777` | no |
| <a name="input_game_ini_path"></a> [game\_ini\_path](#input\_game\_ini\_path) | Path to Game.ini relative to your Terraform working directory. Will be uploaded to the server. Required if use\_custom\_game\_ini = true | `string` | `""` | no |
| <a name="input_game_user_settings_ini_path"></a> [game\_user\_settings\_ini\_path](#input\_game\_user\_settings\_ini\_path) | Path to GameUserSettings.ini relative to your Terraform working directory. Will be uploaded to the server. Required if use\_custom\_gameusersettings = true | `string` | `""` | no |
| <a name="input_ge_proton_version"></a> [ge\_proton\_version](#input\_ge\_proton\_version) | The version of GE Proton to use when installing Ark. Example: 8-21 (https://github.com/GloriousEggroll/proton-ge-custom/releases) | `string` | `"8-21"` | no |
| <a name="input_harvest_ammount_multiplier"></a> [harvest\_ammount\_multiplier](#input\_harvest\_ammount\_multiplier) | Specifies the scaling factor for yields from all harvesting activities (chopping down trees, picking berries, carving carcasses, mining rocks, etc.). Higher values increase the amount of materials harvested with each strike. | `number` | `1` | no |
| <a name="input_harvest_health_multiplier"></a> [harvest\_health\_multiplier](#input\_harvest\_health\_multiplier) | Specifies the scaling factor for the health of items that can be harvested (trees, rocks, carcasses, etc.). Higher values increase the amount of damage (i.e., number of strikes) such objects can withstand before being destroyed, which results in higher overall harvest yields. | `number` | `1` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | The instance type to use | `string` | `"t3.xlarge"` | no |
| <a name="input_is_password_protected"></a> [is\_password\_protected](#input\_is\_password\_protected) | True or False. Is a password required for players to join the server | `bool` | `true` | no |
| <a name="input_item_stack_size_multiplier"></a> [item\_stack\_size\_multiplier](#input\_item\_stack\_size\_multiplier) | Allow increasing or decreasing global item stack size, this means all default stack sizes will be multiplied by the value given (excluding items that have a stack size of 1 by default). | `number` | `1` | no |
| <a name="input_join_password"></a> [join\_password](#input\_join\_password) | The password required for players to join the server. Only required if is\_password\_protected = true | `string` | `"TinyTrexArms123!"` | no |
| <a name="input_kick_idle_player_period"></a> [kick\_idle\_player\_period](#input\_kick\_idle\_player\_period) | Time in seconds after which characters that have not moved or interacted will be kicked (if -EnableIdlePlayerKick as command line parameter is set). Note: although at code level it is defined as a floating-point number, it is suggested to use an integer instead. | `number` | `3600` | no |
| <a name="input_max_personal_tamed_dinos"></a> [max\_personal\_tamed\_dinos](#input\_max\_personal\_tamed\_dinos) | Sets a per-tribe creature tame limit (500 on official PvE servers, 300 in official PvP servers). The default value of 0 disables such limit. | `number` | `0` | no |
| <a name="input_max_platform_saddle_structure_limit"></a> [max\_platform\_saddle\_structure\_limit](#input\_max\_platform\_saddle\_structure\_limit) | Changes the maximum number of platformed-creatures/rafts allowed on the ARK (a potential performance cost). Example: MaxPlatformSaddleStructureLimit=10 would only allow 10 platform saddles/rafts across the entire ARK. | `number` | `75` | no |
| <a name="input_max_players"></a> [max\_players](#input\_max\_players) | The number of max players the server allows | `string` | `"32"` | no |
| <a name="input_max_tamed_dinos"></a> [max\_tamed\_dinos](#input\_max\_tamed\_dinos) | Changes the maximum number of platformed-creatures/rafts allowed on the ARK (a potential performance cost). Example: MaxPlatformSaddleStructureLimit=10 would only allow 10 platform saddles/rafts across the entire ARK. | `number` | `5000` | no |
| <a name="input_night_time_speed_scale"></a> [night\_time\_speed\_scale](#input\_night\_time\_speed\_scale) | Specifies the scaling factor for the passage of time in the ARK during night time. This value determines the length of each night, relative to the length of each day (as specified by DayTimeSpeedScale) Lowering this value increases the length of each night. | `number` | `1` | no | 
| <a name="input_non_permanent_diseases"></a> [non\_permanent\_diseases](#input\_non\_permanent\_diseases) | If True, makes permanent diseases not permanent. Players will lose them if on re-spawn. | `bool` | `false` | no |
| <a name="input_override_official_difficulty"></a> [override\_official\_difficulty](#input\_override\_official\_difficulty) | Allows you to override the default server difficulty level of 4 with 5 to match the new official server difficulty level. Default value of 0.0 disables the override. A value of 5.0 will allow common creatures to spawn up to level 150. Originally (247.95) available only as command line option. | `number` | `0` | no |
| <a name="input_override_structure_platform_prevention"></a> [override\_structure\_platform\_prevention](#input\_override\_structure\_platform\_prevention) | If True, turrets becomes be buildable and functional on platform saddles. Since 247.999 applies on spike structure too. Note: despite patch notes, in ShooterGameServer it's coded OverrideStructurePlatformPrevention with two r. | `bool` | `false` | no |
| <a name="input_oxygen_swim_speed_multiplier"></a> [oxygen\_swim\_speed\_multiplier](#input\_oxygen\_swim\_speed\_multiplier) | Use this to set how swim speed is multiplied by level spent in oxygen. The value was reduced by 80% in 256.0. | `number` | `1` | no |
| <a name="input_per_platform_max_structure_multiplier"></a> [per\_platform\_max\_structure\_multiplier](#input\_per\_platform\_max\_structure\_multiplier) | Higher value increases (from a percentage scale) max number of items place-able on saddles and rafts. | `number` | `1` | no |
| <a name="input_platform_saddle_build_area_bounds_multiplier"></a> [platform\_saddle\_build\_area\_bounds\_multiplier](#input\_platform\_saddle\_build\_area\_bounds\_multiplier) | Increasing the number allows structures being placed further away from the platform. | `number` | `1` | no |
| <a name="input_player_character_food_drain_multiplier"></a> [player\_character\_food\_drain\_multiplier](#input\_player\_character\_food\_drain\_multiplier) | Specifies the scaling factor for player characters' food consumption. Higher values increase food consumption (player characters get hungry faster). | `number` | `1` | no |
| <a name="input_player_character_health_recovery_multiplier"></a> [player\_character\_health\_recovery\_multiplier](#input\_player\_character\_health\_recovery\_multiplier) | Specifies the scaling factor for player characters' health recovery. Higher values increase the recovery rate (player characters heal faster). | `number` | `1` | no |
| <a name="input_player_character_stamina_drain_multiplier"></a> [player\_character\_stamina\_drain\_multiplier](#input\_player\_character\_stamina\_drain\_multiplier) | Specifies the scaling factor for player characters' stamina consumption. Higher values increase stamina consumption (player characters get tired faster). | `number` | `1` | no |
| <a name="input_player_character_water_drain_multiplier"></a> [player\_character\_water\_drain\_multiplier](#input\_player\_character\_water\_drain\_multiplier) | Specifies the scaling factor for player characters' water consumption. Higher values increase water consumption (player characters get thirsty faster). | `number` | `1` | no |
| <a name="input_player_damage_multiplier"></a> [player\_damage\_multiplier](#input\_player\_damage\_multiplier) | Specifies the scaling factor for the damage players deal with their attacks. The default value 1 provides normal damage. Higher values increase damage. Lower values decrease it. | `number` | `1` | no |
| <a name="input_player_resistance_multiplier"></a> [player\_resistance\_multiplier](#input\_player\_resistance\_multiplier) | Specifies the scaling factor for the resistance to damage players receive when attacked. The default value 1 provides normal damage. Higher values decrease resistance, increasing damage per attack. Lower values increase it, reducing damage per attack. A value of 0.5 results in a player taking half damage while a value of 2.0 would result in taking double normal damage. | `number` | `1` | no |
| <a name="input_prevent_diseases"></a> [prevent\_diseases](#input\_prevent\_diseases) | If True, completely diseases on the server. Thus far just Swamp Fever. | `bool` | `false` | no |
| <a name="input_prevent_mate_boost"></a> [prevent\_mate\_boost](#input\_prevent\_mate\_boost) | If True, disables creature mate boosting. | `bool` | `false` | no |
| <a name="input_prevent_offline_pvp"></a> [prevent\_offline\_pvp](#input\_prevent\_offline\_pvp) | If True, enables the Offline Raiding Prevention (ORP). When all tribe members are logged off, tribe characters, creature and structures become invulnerable. Creature starvation still applies, moreover, characters and creature can still die if drowned. Despite the name, it works on both PvE and PvP game modes. Due to performance reason, it is recommended to set a minimum interval with PreventOfflinePvPInterval option before ORP becomes active. ORP also helps lowering memory and CPU usage on a server. Enabled by default on Official PvE since 258.3 | `bool` | `false` | no |
| <a name="input_prevent_offline_pvp_interval"></a> [prevent\_offline\_pvp\_interval](#input\_prevent\_offline\_pvp\_interval) | Seconds to wait before a ORP becomes active for tribe/players and relative creatures/structures (10 seconds in official PvE servers). Note: although at code level it is defined as a floating-point number, it is suggested to use an integer instead. | `number` | `0` | no |
| <a name="input_prevent_spawn_animations"></a> [prevent\_spawn\_animations](#input\_prevent\_spawn\_animations) | If True, player characters (re)spawn without the wake-up animation. | `bool` | `false` | no |
| <a name="input_prevent_tribe_alliances"></a> [prevent\_tribe\_alliances](#input\_prevent\_tribe\_alliances) | If True, prevents tribes from creating Alliances. | `bool` | `false` | no |
| <a name="input_pve_allow_structures_at_supply_drops"></a> [pve\_allow\_structures\_at\_supply\_drops](#input\_pve\_allow\_structures\_at\_supply\_drops) | If True, allows building near supply drop points in PvE mode. | `bool` | `false` | no |
| <a name="input_raid_dino_character_food_drain_multiplier"></a> [raid\_dino\_character\_food\_drain\_multiplier](#input\_raid\_dino\_character\_food\_drain\_multiplier) | Affects how quickly the food drains on such raid dinos (e.g.: Titanosaurus) | `number` | `1` | no |
| <a name="input_random_supply_crate_pionts"></a> [random\_supply\_crate\_pionts](#input\_random\_supply\_crate\_pionts) | If True, supply drops are in random locations. Note: This setting is known to cause artifacts becoming inaccessible on Ragnarok if active. | `bool` | `false` | no |
| <a name="input_rcon_port"></a> [rcon\_port](#input\_rcon\_port) | The port number that RCON listens on if enabled | `number` | `null` | no |
| <a name="input_rcon_server_game_log_buffer"></a> [rcon\_server\_game\_log\_buffer](#input\_rcon\_server\_game\_log\_buffer) | Determines how many lines of game logs are send over the RCON. Note: despite being coded as a float it's suggested to treat it as integer. | `number` | `600` | no |
| <a name="input_resource_respawn_period_multiplier"></a> [resource\_respawn\_period\_multiplier](#input\_resource\_respawn\_period\_multiplier) | Specifies the scaling factor for the re-spawn rate for resource nodes (trees, rocks, bushes, etc.). Lower values cause nodes to re-spawn more frequently. | `number` | `1` | no |
| <a name="input_s3_bucket_backup_retention"></a> [s3\_bucket\_backup\_retention](#input\_s3\_bucket\_backup\_retention) | Lifecycle rule. The number of days to keep backups in S3 before they are deleted | `number` | `7` | no |
| <a name="input_server_admin_password"></a> [server\_admin\_password](#input\_server\_admin\_password) | The admin password for the Ark server to perform admin commands | `string` | `"adminandypassword"` | no |
| <a name="input_server_hardcore"></a> [server\_hardcore](#input\_server\_hardcore) | If True, enables Hardcore mode (player characters revert to level 1 upon death) | `bool` | `false` | no |
| <a name="input_server_pve"></a> [server\_pve](#input\_server\_pve) | If True, disables PvP and enables PvE. | `bool` | `false` | no |
| <a name="input_ssh_ingress_allowed_cidr"></a> [ssh\_ingress\_allowed\_cidr](#input\_ssh\_ingress\_allowed\_cidr) | The CIDR range to allow SSH incoming connections from | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_ssh_key_name"></a> [ssh\_key\_name](#input\_ssh\_key\_name) | The name of the SSH key to be created for use with the EC2 instance | `string` | `"ark-ssh-key"` | no |
| <a name="input_ssh_public_key"></a> [ssh\_public\_key](#input\_ssh\_public\_key) | The path to the ssh public key to be used with the EC2 instance | `string` | `"~/.ssh/ark_public_key.pub"` | no |
| <a name="input_steam_query_port"></a> [steam\_query\_port](#input\_steam\_query\_port) | The query port for steam server browser | `number` | `27015` | no |
| <a name="input_structure_pickup_hold_duration"></a> [structure\_pickup\_hold\_duration](#input\_structure\_pickup\_hold\_duration) | Specifies the quick pick-up hold duration, a value of 0 results in instant pick-up. | `number` | `0.5` | no |
| <a name="input_structure_pickup_time_after_placement"></a> [structure\_pickup\_time\_after\_placement](#input\_structure\_pickup\_time\_after\_placement) | Amount of time in seconds after placement that quick pick-up is available. | `number` | `30` | no |
| <a name="input_structure_prevent_resource_radius_multiplier"></a> [structure\_prevent\_resource\_radius\_multiplier](#input\_structure\_prevent\_resource\_radius\_multiplier) | Same as ResourceNoReplenishRadiusStructures in Game.ini. If both settings are set both multiplier will be applied. Can be useful when cannot change the Game.ini file as it works as a command line option too. | `number` | `1` | no |
| <a name="input_structure_resistance_multiplier"></a> [structure\_resistance\_multiplier](#input\_structure\_resistance\_multiplier) | Specifies the scaling factor for the resistance to damage structures receive when attacked. The default value 1 provides normal damage. Higher values decrease resistance, increasing damage per attack. Lower values increase it, reducing damage per attack. A value of 0.5 results in a structure taking half damage while a value of 2.0 would result in a structure taking double normal damage. | `number` | `1` | no |
| <a name="input_subnet_availability_zone"></a> [subnet\_availability\_zone](#input\_subnet\_availability\_zone) | The AZ of the subnet to be created within the VPC | `string` | `"us-east-1a"` | no |
| <a name="input_subnet_cidr_block"></a> [subnet\_cidr\_block](#input\_subnet\_cidr\_block) | The CIDR block of the  subnet to be created within the VPC | `string` | `"10.0.1.0/24"` | no |
| <a name="input_taming_speed_multiplier"></a> [taming\_speed\_multiplier](#input\_taming\_speed\_multiplier) | Specifies the scaling factor for creature taming speed. Higher values make taming faster. | `number` | `1` | no |
| <a name="input_the_max_structure_in_range"></a> [the\_max\_structure\_in\_range](#input\_the\_max\_structure\_in\_range) | Specifies the maximum number of structures that can be constructed within a certain (currently hard-coded) range. Replaces the old value NewMaxStructuresInRange | `number` | `10500` | no |
| <a name="input_use_battleye"></a> [use\_battleye](#input\_use\_battleye) | True or False. True will set the -noBattlEye flag. | `bool` | `false` | no |
| <a name="input_use_custom_game_ini"></a> [use\_custom\_game\_ini](#input\_use\_custom\_game\_ini) | True or False. Set true if you want to provide your own Game.ini file when the server is started. Required if game\_user\_settings\_ini\_path is defined | `bool` | `false` | no |
| <a name="input_use_custom_gameusersettings"></a> [use\_custom\_gameusersettings](#input\_use\_custom\_gameusersettings) | True or False. Set true if you want to provide your own GameUserSettings.ini file when the server is started. Required if game\_user\_settings\_ini\_path is defined | `bool` | `false` | no |
| <a name="input_vpc_cidr_block"></a> [vpc\_cidr\_block](#input\_vpc\_cidr\_block) | The CIDR block of the VPC to be created | `string` | `"10.0.0.0/16"` | no |
| <a name="input_xp_multiplier"></a> [xp\_multiplier](#input\_xp\_multiplier) | Specifies the scaling factor for the experience received by players, tribes and tames for various actions. The default value 1 provides the same amounts of experience as in the single player experience (and official public servers). Higher values increase XP amounts awarded for various actions; lower values decrease it. | `number` | `1` | no |

## Outputs

No outputs.

test
