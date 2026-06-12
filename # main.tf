# ------------------------------------------------------------------------------
# HEAVY STANDARD COMPUTE INSTANCE (Guaranteed to trigger Cost Estimation)
# ------------------------------------------------------------------------------
resource "google_compute_instance" "expensive_vm" {
  name         = "high-cost-demo-vm"
  # n2-highcpu-96 is a massive 96 vCPU machine that forces a high, easy-to-estimate cost
  machine_type = "n2-highcpu-96" 
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      size  = 500 # Larger disk size adds more measurable cost
      type  = "pd-ssd"
    }
  }

  network_interface {
    network    = google_compute_network.ai_vpc.id
    subnetwork = google_compute_subnetwork.ai_subnet.id
  }
}
