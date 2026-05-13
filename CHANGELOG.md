# Changelog

## [1.0.0] - 2026-05-13

### Added
- AES-256 encryption via OpenSSL
- YubiKey authentication (HMAC-SHA1, slot 2, no touch)
- TOTP fallback (Microsoft/Google Authenticator) + backup password
- `jart-os-secrets.sh` — load secrets into environment
- `jart-os-edit-secrets` — vault editor (decrypt → nano → re-encrypt)
- `jart-os-sync-vault` — sync tool
- `install.sh` — cross-platform installer (macOS/Linux)
- Full documentation
