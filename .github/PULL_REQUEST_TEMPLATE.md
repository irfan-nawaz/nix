## Summary

<!-- 1-3 bullets describing what changes and why. -->

## Checklist

- [ ] `nix fmt` clean
- [ ] `nix flake check --show-trace` passes locally
- [ ] `nix build .#darwinConfigurations.<host>.system` passes for each affected host
- [ ] No unencrypted secrets in the diff
- [ ] Docs updated if adding hosts/users/modules
