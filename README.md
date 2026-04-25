# Nix macOS Platform

A reproducible macOS setup built with `nix-darwin`, `home-manager`, `nix-homebrew`, `nix-direnv`, and `sops-nix`.

## Quick start

1. Install Nix with flakes enabled.
2. Clone this repo to `~/nix`.
3. Bootstrap secrets (see `docs/bootstrap-secrets.md`).
4. Build first:

   ```bash
   darwin-rebuild build --flake .#irfan-personal
   ```

5. Switch when build passes:

   ```bash
   darwin-rebuild switch --flake .#irfan-personal
   darwin-rebuild switch --flake ~/nix#irfan-personal
   ```

## Common commands

- `nix flake check`
- `darwin-rebuild build --flake .#irfan-personal`
- `darwin-rebuild switch --flake .#irfan-personal`

## Scaffold new projects

- `nix flake new -t .#devshell my-project`
- `nix flake new -t .#node my-node-project`
- `nix flake new -t .#python my-python-project`
