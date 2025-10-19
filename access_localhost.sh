#!/bin/bash

echo "=== ACCESSING JENKINS VIA LOCALHOST ==="

# Get Jenkins status
echo "Checking Jenkins status..."
sudo systemctl status jenkins --no-pager -l | head -10

# Get the initial admin password
echo -e "\n1. Getting initial admin password:"
if [ -f /var/lib/jenkins/secrets/initialAdminPassword ]; then
    INITIAL_PASSWORD=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)
    echo "Initial Admin Password: $INITIAL_PASSWORD"
else
    echo "Initial password file not found. Jenkins might be already configured."
fi

# Check Jenkins port
echo -e "\n2. Checking Jenkins port:"
JENKINS_PORT=$(sudo grep -oP 'HTTP_PORT=\K[0-9]+' /etc/default/jenkins 2>/dev/null || echo "8080")
echo "Jenkins is running on port: $JENKINS_PORT"

# Check if Jenkins is accessible locally
echo -e "\n3. Testing local access:"
if curl -s http://localhost:$JENKINS_PORT > /dev/null; then
    echo "✓ Jenkins is accessible locally"
    echo -e "\n4. ACCESS URLs:"
    echo "   Main URL: http://localhost:$JENKINS_PORT"
    echo "   Alternative: http://127.0.0.1:$JENKINS_PORT"
else
    echo "✗ Jenkins is not accessible locally"
    echo "Check if service is running: sudo systemctl status jenkins"
fi

# Display network interfaces for private IP
echo -e "\n5. Private IP addresses:"
hostname -I

echo -e "\n=== LOCAL ACCESS INSTRUCTIONS ==="
echo "1. Open browser on this VM"
echo "2. Navigate to: http://localhost:$JENKINS_PORT"
echo "3. Use the initial admin password above"
echo "4. Complete the setup wizard"
