#!/bin/bash

echo "=== JENKINS ACCESS STATUS CHECK ==="

# Service status
echo "1. Service Status:"
sudo systemctl is-active jenkins

# Get all IPs and port
JENKINS_PORT=$(sudo grep -oP 'HTTP_PORT=\K[0-9]+' /etc/default/jenkins 2>/dev/null || echo "8080")
PRIVATE_IPS=$(hostname -I)
PUBLIC_IP=$(curl -s http://checkip.amazonaws.com 2>/dev/null || echo "Not available")

echo -e "\n2. Network Information:"
echo "   Jenkins Port: $JENKINS_PORT"
echo "   Private IPs: $PRIVATE_IPS"
echo "   Public IP: $PUBLIC_IP"

# Test all access methods
echo -e "\n3. Testing Access Methods:"

# Localhost
echo -n "   Localhost: "
curl -s http://localhost:$JENKINS_PORT > /dev/null && echo "✓ Accessible" || echo "✗ Not accessible"

# Private IPs
IFS=' ' read -ra IP_ARRAY <<< "$PRIVATE_IPS"
for ip in "${IP_ARRAY[@]}"; do
    if [[ $ip != "127.0.0.1" ]]; then
        echo -n "   Private IP $ip: "
        curl -s --connect-timeout 3 http://$ip:$JENKINS_PORT > /dev/null && echo "✓ Accessible" || echo "✗ Not accessible"
    fi
done

# Public IP (if available)
if [[ $PUBLIC_IP != "Not available" ]]; then
    echo -n "   Public IP: "
    curl -s --connect-timeout 5 http://$PUBLIC_IP:$JENKINS_PORT > /dev/null && echo "✓ Accessible" || echo "✗ Not accessible"
fi

echo -e "\n4. Firewall Status:"
if command -v ufw > /dev/null; then
    sudo ufw status | grep $JENKINS_PORT
else
    echo "   UFW not installed"
fi

echo -e "\n=== QUICK ACCESS COMMANDS ==="
echo "Local:    http://localhost:$JENKINS_PORT"
echo "Network:  http://$(hostname -I | awk '{print $1}'):$JENKINS_PORT"
if [[ $PUBLIC_IP != "Not available" ]]; then
    echo "Internet: http://$PUBLIC_IP:$JENKINS_PORT"
fi
