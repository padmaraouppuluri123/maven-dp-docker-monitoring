#!/bin/bash

# Install Docker
apt-get update
apt-get install -y docker.io
systemctl start docker
systemctl enable docker

# Download prometheus.yml from GitHub
curl -o /etc/prometheus/prometheus.yml https://raw.githubusercontent.com/<your-username>/<your-repository>/main/prometheus.yml

# Pull Docker images
docker pull prom/prometheus
docker pull grafana/grafana

# Run Prometheus with the downloaded configuration file
docker run -d --name prometheus \
  -p 9090:9090 \
  -v /etc/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml \
  prom/prometheus

# Run Grafana
docker run -d --name grafana \
  -p 3000:3000 \
  grafana/grafana
