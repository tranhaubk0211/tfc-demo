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
# NETWORKING & IAM SECURITY
# ------------------------------------------------------------------------------
resource "google_compute_network" "ai_vpc" {
  name                    = "ai-app-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "ai_subnet" {
  name          = "ai-app-subnet"
  ip_cidr_range = "10.0.1.0/24"
  network       = google_compute_network.ai_vpc.id
  region        = var.region
}

resource "google_service_account" "workbench_sa" {
  account_id   = "vertex-ai-workbench-sa"
  display_name = "Least Privilege Service Account for AI Application"
}

resource "google_project_iam_member" "vertex_user" {
  project = var.project_id
  role    = "roles/aiplatform.user"
  member  = "serviceAccount:${google_service_account.workbench_sa.email}"
}

# ------------------------------------------------------------------------------
# COST-OPTIMIZED STORAGE (For datasets, models, or RAG assets)
# ------------------------------------------------------------------------------
resource "google_storage_bucket" "ai_assets" {
  name                        = "ai-app-assets-${var.project_id}"
  location                    = var.region
  uniform_bucket_level_access = true
  force_destroy               = true # Set to false in production to prevent data loss

  lifecycle_rule {
    condition {
      age = 30 # Move older, unutilized dev data to Nearline storage
    }
    action {
      type = "SetStorageClass"
      storage_class = "NEARLINE"
    }
  }
}

# ------------------------------------------------------------------------------
# VERTEX AI WORKBENCH INSTANCE
# ------------------------------------------------------------------------------
resource "google_workbench_instance" "cost_optimized_workbench" {
  name     = "ai-development-notebook"
  location = var.zone

  gce_setup {
    # e2 instances are highly cost-efficient for testing and processing pipelines
    machine_type = "e2-standard-4" 

    boot_disk {
      disk_size_gb = 100
      disk_type    = "PD_BALANCED" # Balanced performance and cost compared to SSD
    }

    # Explicitly omitting 'accelerator_configs' to stay CPU-only for cost optimization.
    # GPUs can be integrated downstream via Vertex AI Training pipelines only when needed.

    network_interfaces {
      network = google_compute_network.ai_vpc.id
      # Change 'subnetwork' to 'subnet'
      subnet  = google_compute_subnetwork.ai_subnet.id 
    }

    service_accounts {
      email = google_service_account.workbench_sa.email
    }
  }
}
