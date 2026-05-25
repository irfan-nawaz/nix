# difftastic: syntax-aware diff. Available as the `difft` binary for
# ad-hoc use (`difft a.txt b.txt`).
#
# Git's diff driver stays on diff-so-fancy (configured in
# diff-so-fancy.nix) — HM enforces only one of difftastic/diff-so-fancy
# wires itself into git. Flip the block below + drop the matching one
# in diff-so-fancy.nix if you want to switch defaults.
_: {
  # programs.git.difftastic = {
  #   enable = true;
  #   background = "dark";
  #   display = "side-by-side";
  # };
}
