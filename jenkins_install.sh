#!/bin/bash

echo "--- STARTING JENKINS INSTALLATION (PART 1: SETUP & JAVA FIX) ---"

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

# --- 4. Configuration Fix (Addressing exit-code 1/FAILURE) ---
echo "--- PROACTIVELY CONFIGURING JENKINS FOR JAVA 17 ---"

# Attempt to find the full path to the OpenJDK 17 executable
JAVA_PATH=$(update-alternatives --query java | awk '/^Value:/ {print $2}' | grep "java-17-openjdk")

if [ -f "/etc/default/jenkins" ] && [ ! -z "$JAVA_PATH" ]; then
    echo "Setting JENKINS_JAVA_CMD to Java 17 path: $JAVA_PATH"
    # Use sed to replace the default JAVA command definition with the full Java 17 path
    # This prevents many startup failures related to Jenkins not finding the correct Java.
    sudo sed -i "s|^#JAVA_CMD=.*|JAVA_CMD=\"$JAVA_PATH\"|" /etc/default/jenkins
else
    echo "Warning: Could not automatically detect or set Java 17 path in /etc/default/jenkins."
    echo "If service fails, you may need to manually edit /etc/default/jenkins."
fi

echo "--- JENKINS INSTALLATION COMPLETE. READY FOR PART 2. ---"
