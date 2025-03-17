#!/bin/bash

# Update and install Docker
apt-get update
apt-get install -y docker.io

# Start and enable Docker
systemctl start docker
systemctl enable docker

# Verify Docker installation
if ! docker --version; then
  echo "Docker installation failed"
  exit 1
fi

# Create Prometheus configuration directory
mkdir -p /etc/prometheus

# Download prometheus.yml from GitHub
curl -o /etc/prometheus/prometheus.yml https://raw.githubusercontent.com/<your-username>/<your-repository>/main/prometheus.yml

# Pull Docker images for Prometheus and Grafana
docker pull prom/prometheus
docker pull grafana/grafana

# Run Prometheus with restart policy
docker run -d --name prometheus \
  --restart unless-stopped \
  -p 9090:9090 \
  -v /etc/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml \
  prom/prometheus

# Run Grafana with restart policy
docker run -d --name grafana \
  --restart unless-stopped \
  -p 3000:3000 \
  grafana/grafana

echo "Prometheus and Grafana containers are up and running"
