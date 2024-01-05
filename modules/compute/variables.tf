### ssh variables ###
variable "create_ssh_key" {
  description = "True or False. Determines if an SSH key is created in AWS"
  type        = bool
  default     = true
}

variable "existing_ssh_key_name" {
  description = "The name of an EXISTING SSH key for use with the EC2 instance"
  type        = string
  default     = null
}

variable "ssh_key_name" {
  description = "The name of the SSH key to be created for use with the EC2 instance"
  type        = string
  default     = "ark-ssh-key"
}

variable "ssh_public_key" {
  description = "The path to the ssh public key to be used with the EC2 instance"
  type        = string
  default     = "~/.ssh/ark_public_key.pub"
}

variable "ssh_ingress_allowed_cidr" {
  description = "The CIDR range to allow SSH incoming connections from"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

### ec2 variables ###
variable "ami_id" {
  description = "The AMI ID to use. Not providing one will result in the latest version of Ubuntu Focal 20.04 being used"
  type        = string
  default     = null
}

variable "instance_type" {
  description = "The instance type to use"
  type        = string
  default     = "t3.xlarge"
}

variable "ark_security_group_id" {
  description = "The ID of the security group to use with the EC2 instance"
  type        = string
  default     = ""
}

variable "ark_subnet_id" {
  description = "The ID of the security group to use with the EC2 instance"
  type        = string
  default     = ""
}

variable "ebs_volume_size" {
  description = "The size of the EBS volume attached to the EC2 instance"
  type        = number
  default     = 50
}

### Ark application variables ###
variable "use_custom_gameusersettings" {
  description = "True or False. Set true if you want to provide your own GameUserSettings.ini file when the server is started. Required if game_user_settings_ini_path is defined"
  type        = bool
  default     = false
}

variable "use_custom_game_ini" {
  description = "True or False. Set true if you want to provide your own Game.ini file when the server is started. Required if game_user_settings_ini_path is defined"
  type        = bool
  default     = false
}

variable "custom_gameusersettings_s3" {
  description = "True or False. Set true if use_custom_gameusersettings is true and you want to upload and download them from an S3 bucket during installation"
  type        = bool
  default     = false
}

variable "custom_gameini_s3" {
  description = "True or False. Set true if use_custom_gameini is true and you want to upload and download them from an S3 bucket during installation"
  type        = bool
  default     = false
}

variable "custom_gameusersettings_github" {
  description = "True or False. Set true if use_custom_gameusersettings is true and you want to download them from github. Must be a public repo."
  type        = bool
  default     = false
}

variable "custom_gameini_github" {
  description = "True or False. Set true if use_custom_gameini is true and you want to download them from github. Must be a public repo."
  type        = bool
  default     = false
}

variable "custom_gameusersettings_github_url" {
  description = "The URL to the GameUserSettings.ini file on a public GitHub repo. Used when custom_gameusersettings_github and custom_game_usersettings both == true."
  type        = string
  default     = ""
}

variable "custom_gameini_github_url" {
  description = "The URL to the Game.ini file on a public GitHub repo. Used when custom_gameini_github and use_custom_game_ini both == true."
  type        = string
  default     = ""
}

variable "game_user_settings_ini_path" {
  description = "Path to GameUserSettings.ini relative to your Terraform working directory. Will be uploaded to the server. Required if use_custom_gameusersettings = true"
  type        = string
  default     = ""
}

variable "game_ini_path" {
  description = "Path to Game.ini relative to your Terraform working directory. Will be uploaded to the server. Required if use_custom_game_ini = true"
  type        = string
  default     = ""
}

variable "is_password_protected" {
  description = "True or False. Is a password required for players to join the server"
  type        = bool
  default     = true
}

variable "join_password" {
  description = "The password required for players to join the server. Only required if is_password_protected = true"
  type        = string
  default     = "TinyTrexArms123!"
}

variable "max_players" {
  description = "The number of max players the server allows"
  type        = string
  default     = "32"
}

// TO DO: Add validation. Query Port cannot be between 27020 and 27050 due to Steam using those ports.
variable "steam_query_port" {
  description = "The query port for steam server browser"
  type        = number
  default     = 27015

  validation {
    condition     = var.steam_query_port < 27020 || var.steam_query_port > 27050
    error_message = "Steam uses ports 27020 to 27050. Please choose a different query port."
  }

}

variable "game_client_port" {
  description = "The port that the game client listens on"
  type        = number
  default     = 7777
}

variable "server_admin_password" {
  description = "The admin password for the Ark server to perform admin commands"
  type        = string
  default     = "adminandypassword"
}

variable "ark_session_name" {
  description = "The name of the Ark server as it appears in the list of servers when users look for a server to join"
  type        = string
  default     = "ark-aws-ascended"
}

variable "enable_s3_backups" {
  description = "True or False. Set to true to enable backing up of the ShooterGame/Saved directory to S3"
  type        = bool
  default     = false
}

variable "backup_s3_bucket_arn" {
  description = "The ARN of the s3 bucket that you would like to use for ShooterGame/Saved directory backups"
  type        = string
  default     = ""
}

variable "backup_s3_bucket_name" {
  description = "The name of the S3 bucket to backup the ShooterGame/Saved directory to"
  type        = string
  default     = ""
}

variable "backup_interval_cron_expression" {
  description = "How often to backup the ShooterGame/Saved directory to S3 in cron expression format (https://crontab.cronhub.io/)"
  type        = string
  default     = ""

  # Ill try this again later
  # validation {
  #   condition     = can(regex("^(*|(\\/[0-5]?[0-9]|[0-5]?[0-9])(\\,(\\/[0-5]?[0-9]|[0-5]?[0-9]))) (\\|(\\/[0-1]?[0-9]|2[0-3]|[0-1]?[0-9]|2[0-3])(\\,(\\/[0-1]?[0-9]|2[0-3]|[0-1]?[0-9]|2[0-3]))) (\\|(\\/[1-9]|[12][0-9]|3[01]|[1-9]|[12][0-9]|3[01])(\\,(\\/[1-9]|[12][0-9]|3[01]|[1-9]|[12][0-9]|3[01]))) (\\|(\\/[1-9]|1[0-2]|[1-9]|1[0-2])(\\,(\\/[1-9]|1[0-2]|[1-9]|1[0-2]))) (\\|(\\/[0-6]|[0-6])(\\,(\\/[0-6]|[0-6]))*)$", var.backup_interval_cron_expression))
  #   error_message = "The backup_interval_cron_expression must be a valid cron expression."
  # }
}