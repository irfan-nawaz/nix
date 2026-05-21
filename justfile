default := "shaikmdirfannawaz"

# Build a host's system closure without activating it.
build host=default:
    nix build .#darwinConfigurations.{{host}}.system --print-build-logs

# Activate a host (requires sudo).
switch host=default:
    sudo darwin-rebuild switch --flake .#{{host}}

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
