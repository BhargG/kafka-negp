#!/bin/bash

# Create a temporary directory for Prometheus installation
mkdir -p /tmp/prometheus
cd /tmp/prometheus

# Download and extract Prometheus tarball
wget https://github.com/prometheus/prometheus/releases/download/v2.33.3/prometheus-2.33.3.linux-amd64.tar.gz
tar -xzvf prometheus-2.33.3.linux-amd64.tar.gz
cd prometheus-2.33.3.linux-amd64

# Create a dedicated user for Prometheus if it doesn't already exist
if ! id "prometheus" &>/dev/null; then
    sudo useradd -r -s /bin/false prometheus
fi

# Copy binaries and set permissions
sudo cp prometheus /usr/local/bin/
sudo cp promtool /usr/local/bin/
sudo chown prometheus:prometheus /usr/local/bin/prometheus
sudo chown prometheus:prometheus /usr/local/bin/promtool

# Create configuration and data directories with correct permissions
sudo mkdir -p /etc/prometheus
sudo mkdir -p /var/lib/prometheus
sudo chown prometheus:prometheus /etc/prometheus
sudo chown prometheus:prometheus /var/lib/prometheus

# Copy consoles and libraries
sudo cp -r consoles /etc/prometheus
sudo cp -r console_libraries /etc/prometheus
sudo chown -R prometheus:prometheus /etc/prometheus/consoles
sudo chown -R prometheus:prometheus /etc/prometheus/console_libraries

# Create the Prometheus systemd service file
sudo bash -c 'cat <<EOF > /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \\
    --config.file /etc/prometheus/prometheus.yml \\
    --storage.tsdb.path /var/lib/prometheus/ \\
    --web.console.templates=/etc/prometheus/consoles \\
    --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
EOF'

# Create the Prometheus configuration file
sudo bash -c 'cat <<EOF > /etc/prometheus/prometheus.yml
global:
  scrape_interval: 10s
scrape_configs:
  - job_name: "prometheus_master"
    scrape_interval: 5s
    static_configs:
      - targets: ["localhost:9100"]
EOF'

# Set correct ownership for the configuration file
sudo chown prometheus:prometheus /etc/prometheus/prometheus.yml

# Reload systemd daemon and enable Prometheus service
sudo systemctl daemon-reload
sudo systemctl enable prometheus
sudo systemctl start prometheus

echo "Prometheus installation and service setup completed successfully."
