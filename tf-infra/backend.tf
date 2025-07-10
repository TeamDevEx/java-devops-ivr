terraform {
  backend "gcs" {
    bucket = "tf-state-java-devops-ivr"
    prefix = "infra"
  }
}