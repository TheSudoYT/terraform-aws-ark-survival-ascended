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
  type = number
  default = 50
}

### Ark application variables ###
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