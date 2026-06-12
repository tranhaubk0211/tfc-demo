# main.tf

terraform {
  required_version = ">= 1.3.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# ------------------------------------------------------------------------------
# NETWORKING
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

# ------------------------------------------------------------------------------
# HIGH-COST COMPUTE INSTANCE (To trigger Cost Estimation & Sentinel)
# ------------------------------------------------------------------------------
resource "google_compute_instance" "expensive_vm" {
  name         = "high-cost-demo-vm"
  # Using an a2 machine type with attached GPUs ensures a high monthly baseline cost
  machine_type = "a2-highgpu-1g" 
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      size  = 200
      type  = "pd-ssd"
    }
  }

  network_interface {
    network    = google_compute_network.ai_vpc.id
    subnetwork = google_compute_subnetwork.ai_subnet.id
  }
}
