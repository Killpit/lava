#!/bin/bash

set -e
set -o pipefail

# Define environment variables for directories
TMP_DIR="${TMP_DIR:-$(mktemp -d)}"
SECURE_KEY_LOCATION="${SECURE_KEY_LOCATION:-/path/to/secure/location}"

# Clean up temporary directory on exit
trap 'rm -rf "$TMP_DIR"' EXIT > /dev/null 2>&1

# Download the Solana installation script URL from GitHub Secrets or as an argument
SOLANA_INSTALL_SCRIPT_URL="${SOLANA_INSTALL_SCRIPT_URL:-$1}"  
if [[ -z "$SOLANA_INSTALL_SCRIPT_URL" ]]; then
    echo "Error: SOLANA_INSTALL_SCRIPT_URL is not set."
    exit 1
fi

# Download the Solana installation script to the temporary directory
curl -sSfL "$SOLANA_INSTALL_SCRIPT_URL" -o "$TMP_DIR/install_sol.sh" > /dev/null 2>&1

# Run the Solana installation script from the temporary directory
bash "$TMP_DIR/install_sol.sh" > /dev/null 2>&1

# Add Solana executable to PATH for the current session
export PATH="$HOME/.local/share/solana/install/active_release/bin:$PATH"

# Ensure the secure location for storing the keypair
mkdir -p "$SECURE_KEY_LOCATION" > /dev/null 2>&1
chmod 700 "$SECURE_KEY_LOCATION" > /dev/null 2>&1

# Generate a new keypair and store it in the secure location
solana-keygen new --outfile "$SECURE_KEY_LOCATION/solana_keypair.json" >/dev/null 2>&1

# Ensure the keypair file has appropriate permissions
chmod 600 "$SECURE_KEY_LOCATION/solana_keypair.json" >/dev/null 2>&1

# Output a generic message indicating the keypair was generated
echo "Keypair generated and stored securely."

#Install Anchor CLI
cargo install --git https://github.com/coral-xyz/anchor avm --locked --force

# Execute apt-get commands, and if any of them fail, proceed with the next command
sudo apt-get update && sudo apt-get upgrade && sudo apt-get install -y pkg-config build-essential libudev-dev libssl-dev || true

# Check Anchor and Anchor Version Manager (AVM) Versions
avm --version
anchor --version

# Install Soda
cargo install soda-cli