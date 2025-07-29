#!/bin/bash

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check for required commands
echo "Checking for required commands..."

REQUIRED_COMMANDS=("jq" "npm" "node" "git" "docker-compose")

for cmd in "${REQUIRED_COMMANDS[@]}"; do
    if command_exists "$cmd"; then
        echo "$cmd is installed."
    else
        echo "Error: $cmd is not installed. Please install it before running this script."
        exit 1
    fi
done
# Step 1: Pull the latest changes from the main repo and submodules
echo "Pulling latest changes from the main repository and submodules..."
git pull origin master
git submodule update --init --recursive
git submodule foreach git pull origin master

# Step 2: Update the homepage in package.json
echo "Updating homepage in package.json..."
jq '.homepage = "/reqbin/"' package.json > tmp.json && mv tmp.json package.json

# Step 3: Install required dependencies
echo "Installing required dependencies..."
npm install

# Step 4: Deploy using docker-compose
echo "Deploying using docker-compose..."
docker-compose up -d

echo "Deployment complete."