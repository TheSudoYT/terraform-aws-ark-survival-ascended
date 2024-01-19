module "asa" {
  source = "../../"

  ge_proton_version = "8-27"
  instance_type     = "t3.xlarge"
  create_ssh_key    = true
  ssh_public_key    = "../../ark_public_key.pub"
  mod_list          = ["935813", "900062"]
}
