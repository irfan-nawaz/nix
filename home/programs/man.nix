# man: enable the page-cache rebuild so `apropos`, `whatis`, and fzf
# completions over manpages all work without an explicit `mandb` run.
#
# generateCaches needs a real man implementation (man-db) -- the macOS
# `/usr/bin/man` ships BSD man which can't build the apropos index.
{ pkgs, ... }:
{
  programs.man = {
    package = pkgs.man-db;
    generateCaches = true;
  };
}
