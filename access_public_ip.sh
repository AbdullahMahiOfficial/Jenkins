#!/bin/bash

echo "=== CONFIGURING PUBLIC IP/DOMAIN ACCESS ==="

# Get public IP
echo "1. Detecting public IP..."
PUBLIC_IP=$(curl -s http://checkip.amazonaws.com || curl -s http://ipecho.net/plain || echo "Unable to determine")
echo "   Public IP: $PUBLIC_IP"

# Get private IPs
PRIVATE_IPS=$(hostname -I)
JENKINS_PORT=$(sudo grep -oP 'HTTP_PORT=\K[0-9]+' /etc/default/jenkins 2>/dev/null || echo "8080")

echo -e "\n2. Current Network Configuration:"
echo "   Private IPs: $PRIVATE_IPS"
echo "   Jenkins Port: $JENKINS_PORT"

# Configure Jenkins for public access
echo -e "\n3. Configuring Jenkins for public access..."
sudo sed -i 's/JENKINS_ARGS=".*"/JENKINS_ARGS="--webroot=\/var\/cache\/jenkins\/war --httpListenAddress=0.0.0.0"/g' /etc/default/jenkins 2>/dev/null || echo "Using default configuration"

# Configure firewall
echo -e "\n4. Configuring firewall..."
if command -v ufw > /dev/null; then
    echo "   Configuring UFW..."
    sudo ufw allow $JENKINS_PORT/tcp
    sudo ufw status | grep $JENKINS_PORT
else
    echo "   UFW not installed, consider installing: sudo apt install ufw"
fi

# Restart Jenkins
echo -e "\n5. Restarting Jenkins..."
sudo systemctl restart jenkins
sleep 3

echo -e "\n=== PUBLIC ACCESS CONFIGURATION ==="
echo "✓ Jenkins configured to listen on all interfaces (0.0.0.0)"
echo "✓ Firewall configured to allow port $JENKINS_PORT"

echo -e "\n=== ACCESS URLs ==="
echo "Public IP Access:"
echo "   http://$PUBLIC_IP:$JENKINS_PORT"

echo -e "\nPrivate IP Access:"
IFS=' ' read -ra IP_ARRAY <<< "$PRIVATE_IPS"
for ip in "${IP_ARRAY[@]}"; do
    if [[ $ip != "127.0.0.1" ]]; then
        echo "   http://$ip:$JENKINS_PORT"
    fi
done

echo -e "\nLocalhost Access:"
echo "   http://localhost:$JENKINS_PORT"

echo -e "\n=== DOMAIN CONFIGURATION (Optional) ==="
echo "If you have a domain, point it to: $PUBLIC_IP"
echo "Then access via: http://your-domain.com:$JENKINS_PORT"

echo -e "\n=== SECURITY RECOMMENDATIONS ==="
echo "1. Configure Jenkins security in: Manage Jenkins > Configure Global Security"
echo "2. Set up reverse proxy with Nginx/Apache"
echo "3. Enable HTTPS with SSL certificate"
echo "4. Use strong authentication"
