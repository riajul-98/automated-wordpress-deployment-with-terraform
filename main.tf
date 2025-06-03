module "resources" {
  source = "./modules"

  db_password = var.db_password

  providers = {
    cloudflare = cloudflare.cloudflare
  }
}
