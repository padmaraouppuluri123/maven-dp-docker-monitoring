#!/bin/bash

apt-get update
apt-get install -y docker.io
systemctl start docker
systemctl enable docker

# Pull Docker images
docker pull prom/prometheus
docker pull grafana/grafana

# Run Prometheus
docker run -d --name prometheus \
  -p 9090:9090 \
  -v /prometheus.yml:/etc/prometheus/prometheus.yml \
  prom/prometheus

# Run Grafana
docker run -d --name grafana \
  -p 3000:3000 \
  grafana/grafana
