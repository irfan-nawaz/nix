# Fresh-host bootstrap

Take a brand-new Mac to a fully switched system. Run in order.

Hostnames in this repo: `shaikmdirfannawaz`, `irfan-personal`.
Replace `<host>` below with one of them.

## 1. Xcode CLT

```
xcode-select --install
```

## 2. Rosetta 2 (Apple Silicon only)

```
softwareupdate --install-rosetta --agree-to-license
```

## 3. Determinate Nix

```
curl -fsSL https://install.determinate.systems/nix | sh -s -- install
```

Open a fresh shell.

## 4. Clone the repo

```
mkdir -p ~/nix && cd ~/nix
git clone https://github.com/irfan-nawaz/nix.git .
```

(HTTPS for now -- swap to SSH after step 7.)

## 5. sops age key

Copy `keys.txt` from an existing device into
`~/.config/sops/age/keys.txt`:

```
mkdir -p ~/.config/sops/age && chmod 700 ~/.config/sops/age
pbpaste > ~/.config/sops/age/keys.txt          # paste keys.txt contents
chmod 600 ~/.config/sops/age/keys.txt
```

Verify it can decrypt:

```
nix shell nixpkgs#sops -c sops -d secrets/secrets.yaml >/dev/null && echo ok
```

No existing key? See `docs/secret-rotation.md` for the
new-recipient flow.

## 6. First switch

```
cd ~/nix
scripts/darwin/switch <host>
```

Builds first (no sudo), then prompts for your password once and
activates. Takes 5--15 minutes the first time. A warning about
`$HOME ... not owned by you` during activation is harmless.

## 7. Verify

```
which darwin-rebuild        # /run/current-system/sw/bin/darwin-rebuild
ls -ld ~/.ssh               # drwx------  <you>  staff
ssh -T git@github.com       # "Hi ..." from GitHub
git remote set-url origin git@github.com:irfan-nawaz/nix.git
```

Done. From now on:

```
just switch <host>          # build + activate
just build  <host>          # build only
just check                  # nix flake check
just fmt                    # treefmt
```

## If something breaks

| Symptom | Fix |
|---|---|
| `sudo darwin-rebuild: command not found` | Use `scripts/darwin/switch <host>` -- `darwin-rebuild` isn't on PATH until after the first successful switch. |
| `system activation must be run as root` | You bypassed the script. Use `scripts/darwin/switch <host>`. |
| `sops: failed to get the data key` | `~/.config/sops/age/keys.txt` missing or wrong key. Redo step 5. |
| `brew bundle ... Untapping homebrew/cask` permission denied | Branch missing `homebrew.taps`. Pull `main`. |
| `~/.ssh` owned by root | Re-run step 6. One-shot: `sudo chown $USER:staff ~/.ssh && sudo chmod 700 ~/.ssh`. |

See `docs/troubleshooting.md` for non-bootstrap issues.
