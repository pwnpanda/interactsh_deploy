#!/bin/bash

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install a package if it's not already installed
install_if_missing() {
    local package_name=$1
    if ! command_exists "$package_name"; then
        echo "$package_name is not installed. Installing..."
        sudo apt-get update
        sudo apt-get install -y "$package_name"
    else
        echo "$package_name is already installed."
    fi
}

# Install Go if not present
if ! command_exists "go"; then
    echo "Go is not installed. Installing..."
    sudo apt-get update
    sudo apt-get install -y golang
else
    echo "Go is already installed."
fi

# Install asdf using Go
if ! command_exists "asdf"; then
    echo "asdf is not installed. Installing using Go..."
    go install github.com/asdf-vm/asdf.git@latest
    export PATH="$HOME/.asdf/shims:$PATH"
else
    echo "asdf is already installed."
fi

# Install Node.js using asdf
if ! command_exists "node"; then
    echo "Node.js is not installed. Installing using asdf..."
    asdf plugin-add nodejs https://github.com/asdf-vm/asdf-nodejs.git
    asdf install nodejs latest
    asdf global nodejs latest
else
    echo "Node.js is already installed."
fi

# Check for other required commands and install if missing
echo "Checking for other required commands..."

REQUIRED_COMMANDS=("jq" "git")

for cmd in "${REQUIRED_COMMANDS[@]}"; do
    install_if_missing "$cmd"
done


# Step 1: Pull the latest changes from the main repo and submodules
echo "Pulling latest changes from the main repository and submodules..."
git pull origin master
git submodule update --init --recursive
git submodule foreach git pull origin master

# Step 2: Update the homepage in package.json
echo "Updating homepage in package.json..."
jq '.homepage = "/reqbin/"' interact-sh/package.json > tmp.json && mv tmp.json interact-sh/package.json
rm tmp.json

# Step 3: Install required dependencies
echo "Installing required dependencies..."
npm install

# Step 4: Deploy using docker-compose
echo "Deploying using docker-compose..."
docker-compose up -d

echo "Deployment complete."