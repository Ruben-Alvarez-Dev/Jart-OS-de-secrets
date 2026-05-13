#!/bin/bash
# Jart-OS de secrets — Installer
set -e

VAULT_DIR="$HOME/.hermes"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Installing Jart-OS de secrets ==="

# Create vault directory
mkdir -p "$VAULT_DIR"
chmod 700 "$VAULT_DIR"

# Copy scripts
cp -r "$SCRIPT_DIR/scripts/"* "$VAULT_DIR/"
chmod 700 "$VAULT_DIR"/*.sh

# Create empty .env.enc if none exists
if [ ! -f "$VAULT_DIR/.env.enc" ]; then
    touch "$VAULT_DIR/.env.enc"
    echo "⚠️  No existing vault found. Run: Jart-OS-de-secrets-edit"
fi

# Add aliases to .zshrc
if ! grep -q "Jart-OS" ~/.zshrc 2>/dev/null; then
    cat >> ~/.zshrc << ALIASES

# Jart-OS de secrets
alias Jart-OS-de-secrets="source $HOME/.hermes/Jart-OS-de-secrets.sh"
alias Jart-OS-de-secrets-edit="$HOME/.hermes/Jart-OS-de-secrets-edit"
alias Jart-OS-de-secrets-sync="$HOME/.hermes/Jart-OS-de-secrets-sync"
ALIASES
    echo "✅ Aliases added to ~/.zshrc"
fi

echo ""
echo "=== Installation complete ==="
echo "  Vault: $VAULT_DIR"
echo "  Usage: Jart-OS-de-secrets-edit   (add keys)"
echo "         source Jart-OS-de-secrets         (load into env)"
