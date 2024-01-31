module "ark-survival-ascended" {
  source = "../../"

  ge_proton_version          = "8-27"
  instance_type              = "t3.xlarge"
  create_ssh_key             = true
  ssh_public_key             = "../../ark_public_key.pub"
  supported_server_platforms = ["ALL"]
}
