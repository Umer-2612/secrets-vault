#!/usr/bin/env bash
# Decrypts the vault, opens it in $EDITOR, re-encrypts on save, and always
# deletes the plaintext copy, even if you Ctrl-C partway through.
set -euo pipefail
cd "$(dirname "$0")"

command -v age >/dev/null || { echo "age is required: brew install age"; exit 1; }

PLAINTEXT="vault.env"
trap 'rm -f "$PLAINTEXT"' EXIT

echo "==> Decrypting (enter the current passphrase)..."
age -d -o "$PLAINTEXT" vault.env.age

"${EDITOR:-vi}" "$PLAINTEXT"

echo "==> Re-encrypting (choose the passphrase to use going forward, same one if you're not rotating it)..."
age -p -o vault.env.age "$PLAINTEXT"

echo
echo "Done. vault.env.age updated, plaintext removed."
echo "Now: git add vault.env.age && git commit -m '...' && git push"
echo "Then tell collaborators to: cd ~/.secrets-vault && git pull && ./setup.sh"
