provider "google" {
  # credentials = file("$HOME/.config/gcloud/SAKEY.json")
  region = var.region
}

terraform {
  required_version            = "= 1.0.2"
  required_providers {
    google = {
      source                  = "hashicorp/google"
      version                 = "= 3.77"
    }
  }
  backend "gcs" {
    bucket                    = "tf-demo-mmelendezdou"
    prefix                    = "tf-demo-mmelendezdou/"
  }
}

data "google_project" "demo" { project_id = "mauriciomelendezdou" }

resource "google_storage_bucket" "tf-demo-mmelendezdou" {
  name                        = "tf-demo-mmelendezdou"
  location                    = "US-CENTRAL1"
  storage_class               = "STANDARD"
  project                     = data.google_project.demo.project_id
  versioning {
    enabled                   = true
  }
}
