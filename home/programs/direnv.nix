{ pkgs, ... }:
{
  programs.direnv = {
    enable = true;
    # direnv's test suite occasionally trips on darwin sandboxing;
    # the binary itself is fine, so skip tests.
    package = pkgs.direnv.overrideAttrs (_: {
      doCheck = false;
    });
    nix-direnv.enable = true;
    silent = true;
  };
}
