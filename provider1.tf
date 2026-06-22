terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.36.1"
    }
  }
  required_version = ">= 1.7.5"
}

provider "google" {
  project = local.project_id
  region  = local.region
}
