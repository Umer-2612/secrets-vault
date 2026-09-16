#!/usr/bin/env bash
# Decrypts vault.env.age (one passphrase prompt) and splits it into one
# plaintext .env file per service under ~/.config/interview-platform/env/.
# Safe to re-run whenever the vault is updated (git pull first).
set -euo pipefail
cd "$(dirname "$0")"

command -v age >/dev/null || { echo "age is required: brew install age"; exit 1; }

OUT_DIR="$HOME/.config/interview-platform/env"
mkdir -p "$OUT_DIR"

TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT

echo "==> Decrypting vault.env.age (enter the shared passphrase when asked)..."
age -d -o "$TMP" vault.env.age

echo "==> Splitting into per-service files..."
rm -f "$OUT_DIR"/*.env
awk -v outdir="$OUT_DIR" '
  /^### / { close(f); f = outdir "/" $2 ".env"; next }
  f { print > f }
' "$TMP"

echo
echo "Done. Decrypted into $OUT_DIR:"
ls "$OUT_DIR"
