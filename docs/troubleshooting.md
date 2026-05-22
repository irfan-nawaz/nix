# Troubleshooting

## Bootstrapping a fresh host

On a host that has never been switched, `darwin-rebuild` does not exist
yet -- the system profile that installs it into
`/run/current-system/sw/bin` is only created by the first successful
switch. Run the first switch via `nix run`:

```
nix run nix-darwin -- switch --flake .#<hostname>
```

After this completes once, plain
`darwin-rebuild switch --flake .#<hostname>` works from any new shell.

On Apple Silicon, if you see a warning about Rosetta not being installed
during the brew-bundle phase, run `softwareupdate --install-rosetta`
once before re-switching.

## `darwin-rebuild` fails with "this Nix is not managed by nix-darwin"

Determinate Nix is the daemon here. `nix.enable = false` is intentional in
`hosts/common/darwin.nix`. The `nix.gc`, `nix.optimise`, `nix.settings`
options are inert -- configure substituters and trusted-users in
`/etc/nix/nix.custom.conf` instead (see `docs/nix.custom.conf.example`).

## `sops: failed to get the data key` during activation

Symptom: a host build succeeds but `darwin-rebuild switch` aborts with sops
errors.

Causes:

- `~/.config/sops/age/keys.txt` is missing or unreadable by the active user.
- The age recipient in `.sops.yaml` does not match the local private key.
- The encrypted file was updated on another device with a different recipient
  set and not re-encrypted.

Fix: `sops -d secrets/secrets.yaml >/dev/null` on the affected host. If that
fails, follow `docs/secret-rotation.md`.

## `nix-homebrew: brew install failed`

`nix-homebrew` runs brew under the nix-darwin user. If the host's existing
`/opt/homebrew` was set up under a different user, ownership conflicts surface
on first activation. The `autoMigrate = true` setting in `lib/mkdarwin.nix`
handles common cases; for stubborn ones, delete `/opt/homebrew` and rebuild.

## CI: "darwinConfigurations.<host> does not exist"

Both hosts must be registered in `flake.nix`. If you add a new host, also:

- create `hosts/darwin/<hostname>/default.nix`
- create `home/users/<username>.nix` importing `./profile.nix`
- add a `darwinConfigurations.<host>` block to `flake.nix`
- add a build step to `.github/workflows/ci.yml`

## Activation hangs on launchd agent

The weekly GC agent (`launchd.user.agents.nix-gc`) runs under the user. If
`/run/current-system/sw/bin/nix-collect-garbage` is missing on Determinate
(possible after a major upgrade), edit the command path in
`hosts/common/darwin.nix` to point at `/usr/local/bin/nix` or similar.

## Treefmt fails in CI with "would reformat"

Treefmt is strict: any unformatted Nix file fails CI. Run `nix fmt` locally
before pushing. If treefmt and a manual `nixfmt` disagree on a file, the
shipped binary version is what counts -- treefmt pins it through the flake.

## "Path 'X' in the repository is not tracked by Git"

The flake reads files via git, not the filesystem. New files must be `git add`-ed
(even uncommitted) before the flake can see them.

## `home-manager.users.<u> does not exist`

`lib/mkdarwin.nix` imports `home/users/${username}.nix`. The username arg in
`flake.nix` must match a file name in `home/users/`. Otherwise the import
fails before any module evaluation.

## Slow rebuilds

- Wire Determinate Nix to the nix-community Cachix substituter
  (`docs/nix.custom.conf.example`).
- Use `nh darwin switch -- --flake .#host` for nicer progress output.
- Profile with `nix path-info -rsSh .#darwinConfigurations.<host>.system | sort -hk2 | tail -30`.
