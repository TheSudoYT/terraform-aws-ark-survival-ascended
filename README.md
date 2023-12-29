# ark-aws-ascended-infra
ASA Server Infrastructure

## Donate
I do this in my free time. Consider donating to keep the project going and motivate me to maintain the repo, add new features, etc :)

## Submodules

### Backup
- data is persisted on an EBS volume
- move data off EBS and restore from the target location OR
- Restore from EBS snapshot
- Price difference?

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

## Abandoned Features
| Feature | Reason for Abandoning | Comparable Feature Implemented |
| ------------- | ------------- | ------------- |
| Allow users to pass in GameUserSettings.ini from their local machine by providing the path to the file relative to the terraform working directory.  | Impossible without exceeding the allowable length of user_data.  | Using the AWS CLI and an EC2 instance profile to download GameUserSettings.ini from S3 or another remote location such as GitHub. |
| KMS Encryption  | It can get expensive and this is Ark not a bank or government system.  | None |
| S3 Replication  | Again, it can get expensive and this is Ark not a bank or government system.  | None |

## Future Features Roadmap
| Feature | Target Date |
| ------- | ----------- |
| Allow users to define which map to use | Jan 2024 |
| Allow users to launch a cluster of multiple maps | Feb 2024 |
| Allow users to upload existing save game data when the server is started | Feb / March 2024