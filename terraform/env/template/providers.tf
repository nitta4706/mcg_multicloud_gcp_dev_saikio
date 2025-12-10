terraform {
  backend "gcs" {
    bucket = "mcg-ope-admin-dev-gha-tfstate"
    prefix = "__company__-__dept__-__project__/__env__"
  }

  required_providers {
    google = ">= 4.0.0"
  }
}

provider "google" {
  region = var.region
}