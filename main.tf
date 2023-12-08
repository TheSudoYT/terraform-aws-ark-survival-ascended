module "ark_vpc" {
  source = "./modules/networking"
}

module "ark_compute" {
  source = "./modules/compute"

  ark_security_group_id = module.ark_vpc.security_group_id
  ark_subnet_id         = module.ark_vpc.subnet_id
  create_ssh_key        = true
  ssh_public_key        = "ark_public_key.pub"
}

module "ark_backup" {
  source = "./modules/backup"
}