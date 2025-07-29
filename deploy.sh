#!/bin/bash

set -e  # Exit on any error

# Step 1: Pull the latest changes from the main repo and submodules
echo "Pulling latest changes from the main repository and submodules..."
git pull origin main
git submodule update --init --recursive
git submodule foreach git pull origin main

# Step 2: Update the homepage in package.json
echo "Updating homepage in package.json..."
jq '.homepage = "/reqbin/"' interactsh-web/package.json > tmp.json && mv tmp.json interactsh-web/package.json
rm tmp.json

# Step 3: Deploy using docker-compose
echo "Deploying using docker-compose..."
docker-compose up -d

echo "Deployment complete."

