resource "google_container_cluster" "my_cluster" {
  name               = "java-ivr-app"
  location           = var.region
  enable_autopilot   = true
  deletion_protection = false
}
