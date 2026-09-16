# secrets-vault

One encrypted file holding every environment variable every service in the Interview Platform
project needs. Decrypted once per machine into a shared local folder that every repo reads from.

## How it works

- `vault.env.age` is the only thing committed here: every service's variables, encrypted with
  [age](https://github.com/FiloSottile/age) using a single shared passphrase.
- `setup.sh` decrypts it (one passphrase prompt) and splits it into one plain file per service,
  written to `~/.config/interview-platform/env/<service>.env`.
- Each service repo has a `.envrc` ([direnv](https://direnv.net)) that loads its file from that
  folder automatically the moment you `cd` into it. No `.env` file inside any project, no
  manual copying, nothing committed anywhere except this one encrypted file.

## Getting the passphrase

Ask the project owner directly (in person, a call, or a messaging app you both already trust),
not over email or a public channel. This passphrase decrypts every secret this project has.

## Setting up a new machine

```bash
brew install age direnv
echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc   # once, if you haven't already
# open a new terminal, or: source ~/.zshrc

git clone git@github.com:Umer-2612/secrets-vault.git
cd secrets-vault
./setup.sh
```

Enter the passphrase when asked. That's it, every service repo you already have cloned (or
clone from now on) will pick up its variables automatically via its own `.envrc`.

## Updating a secret

1. Pull the latest vault: `git pull`
2. Decrypt it: `age -d -o vault.env vault.env.age`
3. Edit `vault.env`, change whatever needs changing
4. Re-encrypt: `age -p -o vault.env.age vault.env` (choose the same shared passphrase again)
5. **Delete the plaintext file**: `rm vault.env`
6. Commit and push: `git add vault.env.age && git commit -m "..." && git push`
7. Tell everyone to `git pull && ./setup.sh` in this repo to pick up the change

`vault.env` is gitignored, but that only protects against committing it by accident, always
delete it yourself once you're done editing.

## Adding a new variable or service

Edit `vault.env.template` in a PR so everyone can see what changed, in plaintext, since the
template never holds real values, only variable names. Then follow "Updating a secret" above
to actually add the real value to the encrypted vault.

Section headers (`### service-name`) in the vault determine which file `setup.sh` writes each
block of variables into. A new section name means a new file at
`~/.config/interview-platform/env/service-name.env`.
