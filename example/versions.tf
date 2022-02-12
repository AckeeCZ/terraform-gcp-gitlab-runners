terraform {
  required_version = "0.15.5"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 3.79.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 3.90.0"
    }
  }
}
