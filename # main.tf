terraform {
  required_version = ">= 1.3.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# ------------------------------------------------------------------------------
# 1. SIMULATED VAULT LAYER
# ------------------------------------------------------------------------------
resource "random_id" "simulated_vault_token" {
  byte_length = 16
}

locals {
  simulated_vault_path  = "secret/data/gcp/config"
  simulated_vault_token = "ya29.VaultSimulatedToken-${random_id.simulated_vault_token.hex}"
}

output "vault_reading_status" {
  value       = "Successfully authenticated via OIDC and read dynamic credentials from Vault path: ${local.simulated_vault_path}"
}

output "mock_vault_token" {
  value       = local.simulated_vault_token
  sensitive   = true # Crucial: This tells HCP Terraform to mask it in the UI!
}

# ------------------------------------------------------------------------------
# 2. INFRASTRUCTURE (Massive size to guarantee cost estimation visibility)
# ------------------------------------------------------------------------------
resource "google_compute_network" "ai_vpc" {
  name                    = "demo-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "ai_subnet" {
  name          = "demo-subnet"
  ip_cidr_range = "10.0.1.0/24"
  network       = google_compute_network.ai_vpc.id
  region        = var.region
}

resource "google_compute_instance" "expensive_vm" {
  name         = "high-cost-demo-vm"
  machine_type = "n2-highcpu-96" 
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      size  = 500 
      type  = "pd-ssd"
    }
  }

  network_interface {
    network    = google_compute_network.ai_vpc.id
    subnetwork = google_compute_subnetwork.ai_subnet.id
  }
}
