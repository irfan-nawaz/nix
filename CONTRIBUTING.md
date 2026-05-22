# Contributing

This repo is a personal nix-darwin config. PRs are welcome for fixes that
preserve the existing host topology.

## Required local checks

Before pushing:

```bash
nix fmt                                                      # treefmt: nixfmt + statix + deadnix
nix flake check --show-trace                                 # builds both hosts + formatting check
nix build .#darwinConfigurations.shaikmdirfannawaz.system    # cold-cache build verification
nix build .#darwinConfigurations.irfan-personal.system
```

Or use the `just` wrappers (`just fmt`, `just check`, `just build <host>`).

## Conventions

- One PR = one phase or one logical change. Don't bundle refactors with
  feature additions.
- Commit subject in lower-case imperative ("phase 4: add treefmt").
- Keep `hosts/common/darwin.nix` lean: new packages go into the right
  `modules/packages/<category>.nix`. Add a new module rather than overloading
  an existing one.
- `home/users/profile.nix` is the shared profile. Per-user files
  (`home/users/<u>.nix`) should stay below 15 LOC.
- Never commit unencrypted secrets. New secret keys go through
  `docs/fresh-host-bootstrap.md` + `docs/secret-rotation.md`.

## Adding a new host

1. `hosts/darwin/<hostname>/default.nix` -- start with just
   `networking.hostName = "..."`.
2. `home/users/<username>.nix` -- import `./profile.nix`, set
   `home.username` / `home.homeDirectory`.
3. `flake.nix` -- register `darwinConfigurations.<hostname>`.
4. `.github/workflows/ci.yml` -- add a build step.

## Adding a new user

Symmetric to adding a host, but the username and hostname can share or
diverge -- `mkDarwin` parametrises both independently.
