module "gcp" {
  source     = "./modules/gcp"
  project_id = var.project_id
  region     = var.region
}


