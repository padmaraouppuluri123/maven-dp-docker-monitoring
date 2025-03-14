provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

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
      // Allocate a one-to-one NAT IP to the instance
    }
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y docker.io
    systemctl start docker
    systemctl enable docker

    # Install Prometheus
    docker run -d --name prometheus \
      -p 9090:9090 \
      -v /prometheus.yml:/etc/prometheus/prometheus.yml \
      prom/prometheus

    # Install Grafana
    docker run -d --name grafana \
      -p 3000:3000 \
      grafana/grafana
  EOF
}

resource "google_compute_firewall" "allow_prometheus_grafana" {
  name    = "allow-prometheus-grafana"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["9090", "3000"]
  }

  target_tags = ["prometheus-grafana"]
}

resource "google_compute_instance" "monitoring_vm_tags" {
  name         = google_compute_instance.monitoring_vm.name
  machine_type = google_compute_instance.monitoring_vm.machine_type
  zone         = google_compute_instance.monitoring_vm.zone

  boot_disk {
    initialize_params {
      image = google_compute_instance.monitoring_vm.boot_disk.initialize_params.image
    }
  }

  network_interface {
    network = google_compute_instance.monitoring_vm.network_interface.network
    access_config {
      // Allocate a one-to-one NAT IP to the instance
    }
  }

  metadata_startup_script = google_compute_instance.monitoring_vm.metadata_startup_script

  tags = ["prometheus-grafana"]
}
