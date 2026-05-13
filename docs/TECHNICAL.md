# Technical Documentation

## Architecture

```
YubiKey (HMAC-SHA1 slot 2, no touch)
  │  ykchalresp -2 "jart-os-master-2026"
  ▼
.master-key.yubi ──openssl──► MASTER_KEY
  │
  │  (fallback)
  ▼
.master-key.totp ──openssl──► MASTER_KEY
                              │
                      openssl -d .env.enc
                              │
                              ▼
                      export KEY=VALUE
```

## Authentication Methods

### Primary: YubiKey (automatic)
- YubiKey's slot 2 configured for HMAC-SHA1 challenge-response
- No physical touch required
- Deterministic: same challenge always returns same response

### Fallback: TOTP + Password
- TOTP seed configured in Microsoft/Google Authenticator
- Backup password chosen by user during setup
- Both required to decrypt .master-key.totp

## File Reference

| File | Encryption | Content |
|------|-----------|---------|
| `.env.enc` | AES-256-CBC | Environment variables (KEY=VALUE) |
| `.master-key.yubi` | AES-256-CBC | MASTER_KEY encrypted with YubiKey HMAC |
| `.master-key.totp` | AES-256-CBC | MASTER_KEY encrypted with backup password |

## Service Integration

This tool integrates with Jart-OS via launchd (macOS) or systemd (Linux):

- Hermes: `~Library/LaunchAgents/ai.hermes.gateway.plist` runs `Jart-OS-de-secrets.sh hermes`
- Jart-URA: can be launched with `source Jart-OS-de-secrets.sh jart-ura`
