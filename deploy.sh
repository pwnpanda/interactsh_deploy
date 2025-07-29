#!/bin/bash

set -e  # Exit on any error

echo "🚀 Installing Go first, then asdf using go install on Ubuntu with zsh..."

# Update package list
echo "📦 Updating package list..."
sudo apt update

# Install dependencies
echo "🔧 Installing dependencies..."
sudo apt install -y curl wget jq git

# Install Go directly from official source
echo "🐹 Installing Go..."

# Get the latest Go version
echo "🔍 Fetching latest Go version..."
LATEST_GO_VERSION=$(curl -s https://go.dev/VERSION?m=text | head -n1)
echo "Latest Go version: $LATEST_GO_VERSION"

# Download and install Go
GO_TARBALL="${LATEST_GO_VERSION}.linux-amd64.tar.gz"
GO_URL="https://go.dev/dl/${GO_TARBALL}"

echo "📥 Downloading Go from $GO_URL..."
wget -O "/tmp/${GO_TARBALL}" "$GO_URL"

# Remove existing Go installation if present
if [ -d "/usr/local/go" ]; then
    echo "🗑️  Removing existing Go installation..."
    sudo rm -rf /usr/local/go
fi

# Extract Go
echo "📂 Extracting Go..."
sudo tar -C /usr/local -xzf "/tmp/${GO_TARBALL}"

# Clean up downloaded tarball
rm "/tmp/${GO_TARBALL}"

# Configure zsh for Go
echo "⚙️  Configuring zsh for Go..."
ZSHRC="$HOME/.zsh_alias"

# Create .zshrc if it doesn't exist
touch "$ZSHRC"

# Add Go to PATH if not already present
if ! grep -q "/usr/local/go/bin" "$ZSHRC"; then
    echo "" >> "$ZSHRC"
    echo "# Go installation" >> "$ZSHRC"
    echo 'export PATH=$PATH:/usr/local/go/bin' >> "$ZSHRC"
    echo 'export PATH=$PATH:$(go env GOPATH)/bin' >> "$ZSHRC"
fi

# Source the updated .zshrc for current session
export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:$(go env GOPATH)/bin

# Verify Go installation
echo "✅ Verifying Go installation..."
go version

# Install asdf using go install
echo "📥 Installing asdf using go install..."
go install github.com/asdf-vm/asdf/cmd/asdf@latest

# Add asdf to zsh configuration
echo "⚙️  Configuring zsh for asdf..."

# Add asdf to PATH and initialization if not already present
if ! grep -q "asdf" "$ZSHRC" || ! grep -q "GOPATH" "$ZSHRC"; then
    echo "" >> "$ZSHRC"
    echo "# asdf version manager (installed via go)" >> "$ZSHRC"
    echo 'export PATH=$PATH:$(go env GOPATH)/bin' >> "$ZSHRC"
    echo "# Initialize asdf if available" >> "$ZSHRC"
    echo 'if command -v asdf >/dev/null 2>&1; then' >> "$ZSHRC"
    echo '    eval "$(asdf completion zsh)"' >> "$ZSHRC"
    echo 'fi' >> "$ZSHRC"
fi

# Verify asdf installation
echo "✅ Verifying asdf installation..."
if command -v asdf >/dev/null 2>&1; then
    asdf version
else
    echo "⚠️  asdf command not found in PATH. You may need to restart your terminal."
fi

# Install Node.js using asdf
echo "🟢 Installing Node.js using asdf..."
if command -v asdf >/dev/null 2>&1; then
    # Add Node.js plugin
    echo "🔌 Adding Node.js plugin to asdf..."
    asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git

    # Install latest LTS Node.js version
    echo "📥 Installing latest LTS Node.js..."
    LATEST_NODE=$(asdf latest nodejs)
    echo "Installing Node.js version: $LATEST_NODE"
    asdf install nodejs "$LATEST_NODE"
    asdf global nodejs "$LATEST_NODE"
    
    echo "✅ Node.js installation complete!"
else
    echo "⚠️  Cannot install Node.js - asdf not available. Please restart terminal first."
fi


# Display completion message
echo ""
echo "🎉 Installation complete!"
echo "📋 Installed:"
echo "   Go: $(go version)"
if command -v asdf >/dev/null 2>&1; then
    echo "   asdf: $(asdf version)"
else
    echo "   asdf: Installed (restart terminal to use)"
fi
echo ""
echo "🔄 Please restart your terminal or run: source ~/.zshrc"
