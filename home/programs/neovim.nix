# Bare programs.neovim.enable for now -- no plugins, no init.lua here.
# When nvim becomes the primary editor, either expand this module with
# programs.neovim.{plugins, extraConfig, ...} or migrate to nixvim.
{
  programs.neovim = {
    enable = true;
    defaultEditor = true; # sets $EDITOR and $VISUAL; removes manual EDITOR in common/default.nix
  };
}
