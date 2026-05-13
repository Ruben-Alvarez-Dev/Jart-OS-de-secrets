#!/bin/bash
# Jart-OS de secrets — Load secrets into environment
#
# Authentication order:
#   1. YubiKey plugged in → automatic decrypt (no touch)
#   2. No YubiKey → TOTP (Microsoft Authenticator) + backup password
#
# Usage:
#   source Jart-OS-de-secrets.sh              → load variables
#   source Jart-OS-de-secrets.sh hermes       → load and launch Hermes
#   source Jart-OS-de-secrets.sh jart-ura     → load and launch Jart-URA

set -e
set -a

VAULT_DIR="${HOME}/.hermes"
SECRETS_FILE="${VAULT_DIR}/.env.enc"
MASTER_KEY=""

# --- METHOD 1: YubiKey (automatic, no touch) ---
if command -v ykchalresp >/dev/null 2>&1 && ykchalresp -2 "ping" >/dev/null 2>&1; then
    echo "🔑 YubiKey detected"
    YUBI_KEY=$(ykchalresp -2 "jart-os-master-2026" 2>&1)
    MASTER_KEY=$(openssl enc -aes-256-cbc -d -in "${VAULT_DIR}/.master-key.yubi" -pbkdf2 -pass pass:"${YUBI_KEY}" 2>/dev/null)
    if [ -n "$MASTER_KEY" ]; then
        echo "✅ Decrypted with YubiKey"
    else
        echo "⚠️  YubiKey error, trying alternative method..."
    fi
fi

# --- METHOD 2: TOTP + backup password (fallback) ---
if [ -z "$MASTER_KEY" ]; then
    echo ""
    echo "📱 YubiKey not available — TOTP + backup password"
    echo ""
    read -r -p "   Microsoft Authenticator code: " TOTP_CODE
    read -r -s -p "   Backup password: " BACKUP_PASS
    echo ""

    if [ -f "${VAULT_DIR}/.master-key.totp" ]; then
        MASTER_KEY=$(openssl enc -aes-256-cbc -d -in "${VAULT_DIR}/.master-key.totp" -pbkdf2 -pass pass:"${BACKUP_PASS}" 2>/dev/null)
    fi

    if [ -z "$MASTER_KEY" ]; then
        echo "❌ Incorrect password"
        return 1 2>/dev/null || exit 1
    fi
    echo "✅ Decrypted with TOTP + password"
fi

# Load environment variables
if [ -f "$SECRETS_FILE" ]; then
    while IFS="=" read -r key value; do
        [ -z "$key" ] && continue
        [[ "$key" == \#* ]] && continue
        export "${key}=${value}"
    done < <(openssl enc -aes-256-cbc -d -in "${SECRETS_FILE}" -pbkdf2 -pass pass:"${MASTER_KEY}" 2>/dev/null)
    echo "✅ Variables loaded"
fi

# --- Launch service if specified ---
case "${1:-}" in
    hermes)
        echo "🚀 Starting Hermes..."
        if [ -f "${HOME}/.hermes/config.template.yaml" ]; then
            envsubst < "${HOME}/.hermes/config.template.yaml" > "${HOME}/.hermes/config.yaml"
            chmod 600 "${HOME}/.hermes/config.yaml"
        fi
        HERMES_PYTHON="${HOME}/.hermes/hermes-agent/venv/bin/python3"
        [ ! -f "$HERMES_PYTHON" ] && HERMES_PYTHON="python3"
        exec "$HERMES_PYTHON" -m hermes_cli.main gateway run --replace
        ;;
    jart-ura)
        echo "🚀 Starting Jart-URA..."
        JURA_DIR="${HOME}/Jart-OS-local-server/infra/TIERS/TIER-0-METAL/10000-inference/10001-inference-jart-ura"
        if [ -d "$JURA_DIR" ]; then
            cd "$JURA_DIR" && exec node server.js
        else
            echo "❌ Jart-URA not found"
            exit 1
        fi
        ;;
esac
