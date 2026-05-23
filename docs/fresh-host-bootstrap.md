# Fresh-host bootstrap

End-to-end walkthrough for taking a brand-new Mac to a fully switched
system. Run the steps in order; do not skip ahead.

## 0. Prerequisites

- Apple Silicon or Intel Mac
- Admin user account
- ~30 minutes
- Network access to `github.com` and `cache.nixos.org`
- Access to the existing sops age key (`keys.txt`) from another
  device, OR willingness to provision a new key (see step 5)

## 1. Install Xcode Command Line Tools

```
xcode-select --install
```

Wait for the GUI prompt to finish. Verify:

```
xcode-select -p
# → /Library/Developer/CommandLineTools
```

## 2. Install Rosetta 2 (Apple Silicon only)

Required because `nix-homebrew` sets up the Intel Homebrew prefix at
`/usr/local` for x86 casks.

```
softwareupdate --install-rosetta --agree-to-license
```

Skip on Intel.

## 3. Install Determinate Nix

```
curl -fsSL https://install.determinate.systems/nix | sh -s -- install
```

Pick "Determinate Nix" when prompted. Open a fresh shell, then:

```
nix --version
# → nix (Determinate Nix 3.x.x) 2.x.x
```

## 4. Clone the repo

```
mkdir -p ~/nix && cd ~/nix
git clone git@github.com:irfan-nawaz/nix.git .
```

If you have no SSH keys yet (typical on a brand-new Mac), clone over
HTTPS and switch the remote to SSH after step 8:

```
git clone https://github.com/irfan-nawaz/nix.git .
```

## 5. Provision the sops age key

The system activation needs `~/.config/sops/age/keys.txt` to decrypt
SSH keys from `secrets/secrets.yaml`. Two paths:

### 5a. Copy from an existing device (preferred)

On the source machine:

```
cat ~/.config/sops/age/keys.txt
```

On the new machine, paste the content into the matching path:

```
mkdir -p ~/.config/sops/age
chmod 700 ~/.config/sops/age
pbpaste > ~/.config/sops/age/keys.txt   # paste happens here
chmod 600 ~/.config/sops/age/keys.txt
```

Verify the file starts with `# created:` and contains an
`AGE-SECRET-KEY-1...` line:

```
head -3 ~/.config/sops/age/keys.txt
```

### 5b. Provision a new key (recovery scenario only)

Use only if you have lost the old key AND have a recovery recipient
configured (see `docs/secret-rotation.md`).

```
nix shell nixpkgs#age -c age-keygen -o ~/.config/sops/age/keys.txt
chmod 600 ~/.config/sops/age/keys.txt
grep '^# public key:' ~/.config/sops/age/keys.txt
```

Add the printed `age1...` line to `secrets/.sops.yaml` under the
`age:` recipients block, then on the recovery device run:

```
nix shell nixpkgs#sops -c sops updatekeys secrets/secrets.yaml
```

Commit and push the updated `.sops.yaml` and re-encrypted
`secrets/secrets.yaml`, then `git pull` on the new machine.

### 5c. Verify decryption works

```
nix shell nixpkgs#sops -c sops -d secrets/secrets.yaml >/dev/null && echo ok
```

You should see `ok`. If you see `failed to get the data key`, the key
in step 5 doesn't match any recipient in `.sops.yaml` — recheck.

## 6. First switch -- bootstrap via `nix run`

On a fresh host `darwin-rebuild` does not exist yet. It is installed
into `/run/current-system/sw/bin` by the system profile during the
first successful switch -- chicken-and-egg. Use `nix run` to invoke
nix-darwin directly:

```
cd ~/nix
sudo nix run nix-darwin -- switch --flake .#<hostname>
```

Where `<hostname>` is one of:

- `shaikmdirfannawaz`
- `irfan-personal`

The `sudo` is required -- nix-darwin's activation writes to `/etc`,
`/run`, and launchd, and aborts with `system activation must be run
as root` otherwise.

You will likely see a warning during the run:

```
warning: $HOME ('/Users/<you>') is not owned by you, falling back to
the one defined in the 'passwd' file ('/var/root')
```

This is harmless. Nix notices that euid is root but `$HOME` still
points at your user, and falls back to root's home for its own state
directory. The switch itself proceeds normally.

The first run downloads 1-2 GB of substitutes and takes 5-15 minutes.
Expected phases:

- `Building configuration` -- evaluation
- `setting up the build users` -- one-time on first install
- `setting up homebrew` -- nix-homebrew bootstraps `/opt/homebrew` and
  creates declarative tap symlinks under `Library/Taps/homebrew/`
- `running activation script` -- sops drops secret symlinks,
  post-activation script chowns `~/.ssh`
- `Homebrew bundle...` -- declarative `brew bundle` reconciliation

Expected brew-bundle output:

```
Using homebrew/bundle
Using homebrew/cask
Using homebrew/core
Using mas
`brew bundle` complete!
```

No `Untapping` lines should appear. If one does, your checkout is
missing the `homebrew.taps = [...]` declaration in
`hosts/common/darwin.nix`; pull `main`.

## 7. Post-switch verification

```
# darwin-rebuild now exists on PATH
which darwin-rebuild
# → /run/current-system/sw/bin/darwin-rebuild

# ~/.ssh is user-owned, mode 0700
ls -ld ~/.ssh
# → drwx------  <user>  staff   .../.ssh

# Secret symlinks exist and are user-owned
ls -l ~/.ssh
# → lrwxr-xr-x  <user>  staff  id_ed25519_github_geekyants -> /run/secrets/...
# → lrwxr-xr-x  <user>  staff  id_ed25519_github_personal  -> /run/secrets/...
# → lrwxr-xr-x  <user>  staff  id_ed25519_gitlab_geekyants -> /run/secrets/...
# → lrwxr-xr-x  <user>  staff  id_ed25519_gitlab_tzero     -> /run/secrets/...

# SSH agent picks the right key for each host
ssh -T git@github.com          # uses github_geekyants
ssh -T git@github-personal     # uses github_personal
```

Each `ssh -T` should print `Hi <username>! You've successfully
authenticated...` (or the equivalent GitLab welcome).

## 8. Daily workflow from here on

You no longer need `nix run`:

```
darwin-rebuild switch --flake .#<hostname>   # apply changes
just check                                    # pre-flight check
just fmt                                      # treefmt
just gc                                       # garbage collect
```

If you cloned over HTTPS in step 4, switch to SSH now:

```
git remote set-url origin git@github.com:irfan-nawaz/nix.git
```

## 9. Common first-boot snags

- **`sudo darwin-rebuild: command not found`** -- you skipped step 6's
  `nix run` form. Go back and run that; `darwin-rebuild` lands on
  PATH after the first successful switch.

- **`system activation must be run as root`** -- you dropped the
  `sudo` on step 6. Re-run with `sudo`.

- **`$HOME ('/Users/...') is not owned by you`** -- expected when
  running under `sudo`; harmless. See step 6 for the explanation.

- **`sops: failed to get the data key`** --
  `~/.config/sops/age/keys.txt` is missing, wrong mode, or doesn't
  match any recipient in `.sops.yaml`. Redo step 5 and 5c.

- **`brew bundle` says "Untapping homebrew/cask" + Permission denied** --
  your checkout is missing the `homebrew.taps = [...]` declaration in
  `hosts/common/darwin.nix`. Pull `main`.

- **`~/.ssh` is root-owned after switch** -- the post-activation chown
  in `hosts/common/darwin.nix` should have fixed it. Re-run the switch.
  Manual one-shot if needed:
  `sudo chown $USER:staff ~/.ssh && sudo chmod 700 ~/.ssh`.

See `docs/troubleshooting.md` for non-bootstrap issues.
