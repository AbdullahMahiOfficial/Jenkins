#!/bin/bash

echo "--- STARTING JENKINS SERVICE (PART 2: SERVICE & FIREWALL) ---"

# --- 4. Manage Jenkins Service ---
echo "Reloading system daemon and attempting to start Jenkins service..."
sudo systemctl daemon-reload
sudo systemctl start jenkins
sudo systemctl enable jenkins

# Wait a moment for the service to actually spin up and stabilize
echo "Waiting 15 seconds for Jenkins service to initialize..."
sleep 15 

echo "Checking Jenkins service status:"
sudo systemctl status jenkins

# --- 5. Configure Firewall ---
echo "Configuring Uncomplicated Firewall (UFW) to allow port 8080..."
sudo ufw allow 8080
sudo ufw reload

echo "--- ✅ JENKINS SETUP COMPLETE ✅ ---"
echo "You can now access Jenkins at http://YOUR_SERVER_IP_OR_DOMAIN:8080"
echo ""
echo "To retrieve the initial administrative password, run:"
echo "sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
