#!/bin/bash

# Ensure the script is run as root or with sudo
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root or use sudo."
    exit 1
fi

# Add Grafana repository
echo "Adding Grafana repository..."
cat <<EOF > /etc/apt/sources.list.d/grafana.list
deb https://packages.grafana.com/oss/deb stable main
EOF

# Add the GPG key for the repository
echo "Adding Grafana GPG key..."
wget -q -O - https://packages.grafana.com/gpg.key | apt-key add -

# Update package index
echo "Updating package index..."
apt update

# Install Grafana
echo "Installing Grafana..."
apt install grafana -y

# Enable and start the Grafana service
echo "Enabling and starting Grafana service..."
systemctl enable grafana-server
systemctl start grafana-server

echo "Grafana installation completed successfully."
