#!/bin/bash

echo "=== ACCESSING JENKINS VIA PRIVATE IP ==="

# Get private IP addresses
echo "Getting network information..."
PRIVATE_IPS=$(hostname -I)
IFS=' ' read -ra IP_ARRAY <<< "$PRIVATE_IPS"

# Get Jenkins port
JENKINS_PORT=$(sudo grep -oP 'HTTP_PORT=\K[0-9]+' /etc/default/jenkins 2>/dev/null || echo "8080")

echo -e "\n1. Network Configuration:"
for i in "${!IP_ARRAY[@]}"; do
    echo "   IP $((i+1)): ${IP_ARRAY[i]}"
done

echo -e "\n2. Jenkins Port: $JENKINS_PORT"

# Configure Jenkins to listen on all interfaces
echo -e "\n3. Configuring Jenkins to listen on all interfaces..."
sudo sed -i 's/JENKINS_ARGS=".*"/JENKINS_ARGS="--webroot=\/var\/cache\/jenkins\/war --httpListenAddress=0.0.0.0"/g' /etc/default/jenkins 2>/dev/null || echo "Config file not found or already configured"

# Restart Jenkins to apply changes
echo -e "\n4. Restarting Jenkins service..."
sudo systemctl restart jenkins
sleep 3

# Check firewall status
echo -e "\n5. Checking firewall:"
if command -v ufw > /dev/null; then
    sudo ufw status | grep "$JENKINS_PORT" || echo "Port $JENKINS_PORT might be blocked by firewall"
fi

# Test access from private IPs
echo -e "\n6. Testing access:"
for ip in "${IP_ARRAY[@]}"; do
    if [[ $ip != "127.0.0.1" ]]; then
        echo "   Testing http://$ip:$JENKINS_PORT ..."
        if curl -s --connect-timeout 5 http://$ip:$JENKINS_PORT > /dev/null; then
            echo "   ✓ Accessible via: http://$ip:$JENKINS_PORT"
        else
            echo "   ✗ Not accessible via: http://$ip:$JENKINS_PORT"
        fi
    fi
done

echo -e "\n=== PRIVATE IP ACCESS URLs ==="
for ip in "${IP_ARRAY[@]}"; do
    if [[ $ip != "127.0.0.1" ]]; then
        echo "   http://$ip:$JENKINS_PORT"
    fi
done

echo -e "\nInstructions:"
echo "1. Use any of the above URLs from other devices on the same network"
echo "2. Make sure firewall allows incoming connections on port $JENKINS_PORT"
