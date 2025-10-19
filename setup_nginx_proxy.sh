#!/bin/bash

echo "=== SETTING UP NGINX REVERSE PROXY FOR JENKINS ==="

# Install Nginx
echo "1. Installing Nginx..."
sudo apt update
sudo apt install -y nginx

# Get Jenkins port
JENKINS_PORT=$(sudo grep -oP 'HTTP_PORT=\K[0-9]+' /etc/default/jenkins 2>/dev/null || echo "8080")

# Create Nginx configuration
echo "2. Creating Nginx configuration..."
sudo cat > /etc/nginx/sites-available/jenkins << EOF
upstream jenkins {
    server 127.0.0.1:$JENKINS_PORT;
}

server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://jenkins;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_redirect http:// https://;
    }

    # Required for Jenkins websocket
    location ~ '/\.well-known/acme-challenge' {
        allow all;
    }
}
EOF

# Enable the site
echo "3. Enabling Jenkins site..."
sudo ln -sf /etc/nginx/sites-available/jenkins /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# Test and reload Nginx
echo "4. Testing Nginx configuration..."
sudo nginx -t
echo "Reloading Nginx..."
sudo systemctl reload nginx

# Configure firewall for HTTP
echo "5. Configuring firewall..."
if command -v ufw > /dev/null; then
    sudo ufw allow 'Nginx Full'
    sudo ufw status
fi

# Get public IP
PUBLIC_IP=$(curl -s http://checkip.amazonaws.com || echo "your-public-ip")

echo -e "\n=== NGINX REVERSE PROXY SETUP COMPLETE ==="
echo "✓ Jenkins now accessible via standard HTTP port (80)"
echo "✓ No need to specify port in URL"

echo -e "\n=== ACCESS URLs ==="
echo "Public Access: http://$PUBLIC_IP"
echo "Private IP Access: http://$(hostname -I | awk '{print $1}')"
echo "Localhost: http://localhost"

echo -e "\nNext steps:"
echo "1. Consider setting up SSL with Let's Encrypt"
echo "2. Configure domain name to point to $PUBLIC_IP"
echo "3. Access Jenkins via browser without port number"
