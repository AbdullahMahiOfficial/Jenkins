#!/bin/bash

# --- 1. Update package list and install Java ---
echo "Updating system packages..."
sudo apt-get update -y

echo "Installing OpenJDK 17 (Java)..."
sudo apt install openjdk-17-jdk -y

echo "Verifying Java installation:"
java -version

# --- 2. Add the Jenkins Repository Key and Source ---
echo "Adding Jenkins repository key..."
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo "Adding Jenkins repository to APT sources..."
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

# --- 3. Install Jenkins ---
echo "Updating package list with new Jenkins repository..."
sudo apt-get update -y

echo "Installing Jenkins..."
sudo apt install jenkins -y

# --- 4. Manage Jenkins Service ---
echo "Starting and enabling Jenkins service..."
sudo systemctl start jenkins
sudo systemctl enable jenkins

echo "Checking Jenkins service status:"
sudo systemctl status jenkins

# --- 5. Configure Firewall ---
echo "Configuring Uncomplicated Firewall (UFW) to allow port 8080..."
sudo ufw allow 8080
sudo ufw reload

echo "--- INSTALLATION COMPLETE ---"
echo "You can now access Jenkins at http://YOUR_SERVER_IP_OR_DOMAIN:8080"
echo "To retrieve the initial administrative password, run: sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
