{ inputs }:
{
  mkDarwin = import ./mkdarwin.nix { inherit inputs; };
}
