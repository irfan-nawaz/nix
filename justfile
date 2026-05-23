default := "shaikmdirfannawaz"

# Build a host's system closure without activating it.
build host=default:
    scripts/darwin/build-system {{host}}

# Activate a host (requires sudo). Works on fresh hosts -- builds
# first, then sudo-invokes the freshly-built darwin-rebuild binary.
switch host=default:
    scripts/darwin/switch {{host}}

# Lighter dry-run via nh (no sudo).
nh-build host=default:
    nh darwin build --flake .#{{host}}

# Run all flake checks (per-host system + treefmt formatting).
check:
    nix flake check --show-trace

# Format the entire tree with treefmt (nixfmt + statix + deadnix).
fmt:
    nix fmt

# Update every input.
update:
    nix flake update

# Garbage-collect store paths older than 14 days.
gc:
    nix-collect-garbage --delete-older-than 14d
