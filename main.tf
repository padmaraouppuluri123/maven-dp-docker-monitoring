provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# Create a VM instance for monitoring
resource "google_compute_instance" "monitoring_vm" {
  name         = "monitoring-vm"
  machine_type = "e2-medium"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }

  network_interface {
    network = "default"
    access_config {
      # Allocate a one-to-one NAT IP to the instance
    }
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y google-cloud-sdk
    gsutil cp gs://sm-test-bucket/init.sh /tmp/init.sh
    chmod +x /tmp/init.sh
    /tmp/init.sh
  EOF

  service_account {
    email  = "your-service-account@${var.project_id}.iam.gserviceaccount.com"
    scopes = ["cloud-platform"]
  }

  tags = ["prometheus-grafana"]
}

# Allow firewall rules for Prometheus and Grafana ports (9090 and 3000)
resource "google_compute_firewall" "allow_prometheus_grafana" {
  name    = "allow-prometheus-grafana"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["9090", "3000"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["prometheus-grafana"]
}

# Output the external IP of the monitoring VM
output "monitoring_vm_ip" {
  description = "The external IP address of the monitoring VM"
  value       = google_compute_instance.monitoring_vm.network_interface[0].access_config[0].nat_ip
}
