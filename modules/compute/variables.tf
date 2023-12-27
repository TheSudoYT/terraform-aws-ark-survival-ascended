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
}

variable "ark_subnet_id" {
  description = "The ID of the security group to use with the EC2 instance"
  type        = string
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

variable "custom_gameusersettings_s3" {
  description = "True or False. Set true if use_custom_gameusersettings is true and you want to upload and download them from an S3 bucket during installation"
  type = bool
  default = false
}

variable "custom_gameusersettings_github" {
  description = "True or False. Set true if use_custom_gameusersettings is true and you want to download them from github. Must be a public repo."
  type = bool
  default = false
}

variable "game_user_settings_ini_path" {
  description = "Path to GameUserSettings.ini relative to your Terraform working directory. Will be uploaded to the server. Required if use_custom_gameusersettings = true"
  type        = string
  default     = null
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