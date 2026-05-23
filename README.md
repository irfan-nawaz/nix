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
3. Walk through [`docs/fresh-host-bootstrap.md`](docs/fresh-host-bootstrap.md)
   for the end-to-end first-time setup (Determinate Nix, sops age key,
   `nix run nix-darwin -- switch` for the chicken-and-egg first
   switch, post-switch verification).
4. (Optional) Drop `docs/nix.custom.conf.example` into `/etc/nix/nix.custom.conf`
   to enable extra substituters under Determinate.
5. Build first, switch when build passes:

   ```bash
   just build shaikmdirfannawaz    # scripts/darwin/build-system
   just switch shaikmdirfannawaz   # scripts/darwin/switch (build + activate)
   ```

   `scripts/darwin/switch` works on a fresh host -- it builds the
   system closure first, then sudo-invokes the just-built
   `darwin-rebuild` from the build result (so it does not depend on
   `darwin-rebuild` already being on `PATH`).

## Daily workflow

```bash
just fmt        # treefmt -- nixfmt + statix + deadnix
just check      # nix flake check (per-host system + formatting)
just update     # nix flake update
just gc         # garbage-collect store paths older than 14 days
```

Inside the repo, `direnv allow` activates `devShells.default` which ships
`sops`, `age`, `just`, `nh`, and the formatters.

## Personal CLI stacks

Music, email, calendar, contacts, RSS, password manager, TOTP — all CLI.
See [`docs/cli-stacks.md`](docs/cli-stacks.md) for a beginner walkthrough
of every stack installed by `modules/packages/{personal,comms}.nix`.

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
