# less: smart-case, raw control chars (color through), persistent
# history. PAGER is already set to less in home/common/default.nix.
{
  home.sessionVariables = {
    LESS = "-R -i -F -X --mouse";
    LESSHISTFILE = "$XDG_STATE_HOME/less/history";
  };
}
