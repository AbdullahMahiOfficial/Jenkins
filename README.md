✅ Usage Instructions:
#Make scripts executable:
chmod +x *.sh
#Check current access:
./check_access.sh
#For local access only:
./access_localhost.sh
#For network access:
./access_private_ip.sh
#For public internet access:
./access_public_ip.sh
#For production setup with domain:
./setup_nginx_proxy.sh

✅Quick Access URLs After Setup:
#Method 1 - Localhost:
http://localhost:8080
#Method 2 - Private IP:
http://[private-ip]:8080
#Method 3 - Public IP:
http://[public-ip]:8080
#Method 4 - With Nginx:
http://[public-ip]  # No port needed

✅Allow port 8080 (or your selected port number) in the Azure inbound security rules.
