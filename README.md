# Nix macOS Platform

A reproducible macOS setup built with `nix-darwin`, `home-manager`,
`nix-homebrew`, `nix-direnv`, and `sops-nix`.

## Hosts

| host                | user                |
| ------------------- | ------------------- |
| `shaikmdirfannawaz` | `shaikmdirfannawaz` |
| `irfan-personal`    | `irfan-personal`    |

## Quick start

1. Install Determinate Nix (or upstream Nix with flakes enabled).
2. Clone this repo to `~/nix`.
3. Bootstrap secrets -- see `docs/bootstrap-secrets.md`.
4. (Optional) Drop `docs/nix.custom.conf.example` into `/etc/nix/nix.custom.conf`
   to enable extra substituters under Determinate.
5. Build first, switch when build passes:

   ```bash
   just build shaikmdirfannawaz    # or: nix build .#darwinConfigurations.shaikmdirfannawaz.system
   just switch shaikmdirfannawaz   # or: sudo darwin-rebuild switch --flake .#shaikmdirfannawaz
   ```

## Daily workflow

```bash
just fmt        # treefmt -- nixfmt + statix + deadnix
just check      # nix flake check (per-host system + formatting)
just update     # nix flake update
just gc         # garbage-collect store paths older than 14 days
```

Inside the repo, `direnv allow` activates `devShells.default` which ships
`sops`, `age`, `just`, `nh`, and the formatters.

## Layout

```
flake.nix                    -- inputs, darwinConfigurations, formatter, devShell
lib/
  default.nix                -- exports mkDarwin
  mkdarwin.nix               -- darwinSystem factory
hosts/
  common/darwin.nix          -- shared system config (sops, fonts, GC agent, ...)
  darwin/<hostname>/         -- per-host hostname only
modules/packages/            -- categorised environment.systemPackages
home/
  common/default.nix         -- shared home-manager (zsh, direnv, starship, ...)
  users/profile.nix          -- shared user profile (git, ssh matchBlocks, ...)
  users/<username>.nix       -- thin shim that imports profile.nix
secrets/                     -- sops-encrypted material
docs/                        -- bootstrap, troubleshooting, rotation
```

## Scaffold new projects

```bash
nix flake new -t .#devshell my-project
nix flake new -t .#node my-node-project
nix flake new -t .#python my-python-project
```

## Contributing

See `CONTRIBUTING.md`.
