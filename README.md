<div align="center">
  <h1>🔐 Jart-OS de secrets</h1>
  <p><strong>YubiKey + TOTP encrypted secrets vault for the Jart-OS ecosystem</strong></p>
  <p>
    <img src="https://img.shields.io/badge/macOS-✓-brightgreen" alt="macOS">
    <img src="https://img.shields.io/badge/Linux-✓-brightgreen" alt="Linux">
    <img src="https://img.shields.io/badge/license-MIT-blue" alt="MIT">
  </p>
</div>

---

## Overview

**Jart-OS de secrets** is a secrets manager for multi-machine environments.
It protects API keys, tokens, and credentials using AES-256 encryption,
YubiKey authentication, and TOTP fallback (Google / Microsoft Authenticator).

Designed for the [Jart-OS](https://github.com/Ruben-Alvarez-Dev/Jart-OS) ecosystem.
Runs on macOS, Linux, and any system with OpenSSL.

## Installation

```bash
git clone https://github.com/Ruben-Alvarez-Dev/Jart-OS-de-secrets.git
cd Jart-OS-de-secrets
bash install.sh
```

### Requirements

| Tool | macOS | Linux |
|------|-------|-------|
| OpenSSL | ✅ Built-in | ✅ Built-in |
| ykchalresp | `brew install yubikey-personalization` | `apt install yubikey-personalization` |
| envsubst | ✅ Built-in | `apt install gettext` |
| YubiKey | Any model with free slot | Any model with free slot |

### YubiKey Setup (one-time)

```bash
# Configure slot 2 for HMAC-SHA1 (no touch required)
ykpersonalize -2 -ochal-resp -ochal-hmac -a $(openssl rand -hex 20)

# Verify
ykchalresp -2 "ping"
```

## Usage

### Load secrets

```bash
# With YubiKey plugged in (automatic)
source Jart-OS-de-secrets.sh

# Without YubiKey (TOTP + backup password)
source Jart-OS-de-secrets.sh
# → Prompts for TOTP code + backup password
```

### Manage vault

```bash
# Add or change keys
Jart-OS-de-secrets-edit        # Opens nano, edit, save, re-encrypts

# Launch services with secrets
source Jart-OS-de-secrets.sh hermes      # Load and launch Hermes
source Jart-OS-de-secrets.sh Jart-URA    # Load and launch Jart-URA

# Sync encrypted backup
Jart-OS-de-secrets-sync
```

## Architecture

```
YubiKey (HMAC-SHA1)
  │  ykchalresp "jart-os-master-2026"
  ▼
.master-key.yubi ──→ MASTER_KEY ──→ .env.enc (AES-256)
  │
  └── Fallback: .master-key.totp (TOTP + password)
```

## Vault Structure (`~/.hermes/`)

```
~/.hermes/
├── .env.enc                  → Encrypted variables
├── .master-key.yubi          → MASTER_KEY wrapped with YubiKey
├── .master-key.totp          → MASTER_KEY wrapped with TOTP
├── config.template.yaml      → Config template
├── config.yaml               → Expanded config (auto-generated)
├── Jart-OS-de-secrets.sh        → Load script
├── Jart-OS-de-secrets-edit      → Vault editor
└── Jart-OS-de-secrets-sync        → Sync tool
```

## Security Model

| Threat | Protection |
|--------|-----------|
| Agent reads `.env.enc` | AES-256 encrypted, cannot decrypt |
| Unauthorized remote access | Physical YubiKey required |
| Lost YubiKey | TOTP (Authenticator) + backup password |
| Plaintext keys on disk | Never, not even in swap |
| Network exfiltration | Keys exist in memory only |

## Commands

| Command | Description |
|---------|-------------|
| `source Jart-OS-de-secrets.sh` | Load secrets into environment |
| `Jart-OS-de-secrets-edit` | Edit vault (decrypt → nano → re-encrypt) |
| `Jart-OS-de-secrets-sync` | Sync ~/.env → encrypted vault |

## Dependencies

- `openssl` — AES-256 encryption
- `ykchalresp` — YubiKey communication
- `envsubst` — variable expansion in templates

## License

MIT
