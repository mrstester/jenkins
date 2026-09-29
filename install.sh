#!/bin/bash

set -e

echo "======================================"
echo "       Jenkins Installation"
echo "======================================"

# Check root
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script with sudo:"
    echo "curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/jenkins-installer/main/install.sh | sudo bash"
    exit 1
fi

echo ""
echo "==> Updating package lists..."
apt-get update

echo ""
echo "==> Installing prerequisites..."
apt-get install -y fontconfig openjdk-21-jre wget

echo ""
echo "==> Adding Jenkins repository..."

install -d -m 0755 /etc/apt/keyrings

wget -q -O /etc/apt/keyrings/jenkins-keyring.asc \
    https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key

echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" \
    > /etc/apt/sources.list.d/jenkins.list

echo ""
echo "==> Updating repositories..."
apt-get update

echo ""
echo "==> Installing Jenkins..."
apt-get install -y jenkins

echo ""
echo "==> Configuring Jenkins workspace..."

mkdir -p /var/lib/jenkins/workspace

chown -R jenkins:jenkins /var/lib/jenkins/workspace
chmod -R 775 /var/lib/jenkins/workspace

echo ""
echo "==> Adding Jenkins to Docker group..."

if getent group docker > /dev/null 2>&1; then
    usermod -aG docker jenkins
else
    echo "WARNING: Docker group does not exist."
    echo "Install Docker first if Jenkins needs Docker access."
fi

echo ""
echo "==> Enabling Jenkins service..."
systemctl enable jenkins

echo ""
echo "==> Starting Jenkins..."
systemctl restart jenkins

echo ""
echo "======================================"
echo "     Jenkins installation complete!"
echo "======================================"
echo ""
echo "Jenkins URL:"
echo "http://$(hostname -I | awk '{print $1}'):8080"
echo ""
echo "Initial Jenkins admin password:"
echo ""

if [ -f /var/lib/jenkins/secrets/initialAdminPassword ]; then
    cat /var/lib/jenkins/secrets/initialAdminPassword
else
    echo "Password file not available yet."
    echo "Run:"
    echo "sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
fi

echo ""
echo "======================================"
