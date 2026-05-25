# hstr: ranked shell-history search. Atuin owns Ctrl-R in this setup
# (see atuin.nix -- tmux-popup + workspace filter make it the better
# fit for our sesh-heavy workflow), so hstr's zsh integration is off.
# The binary stays available; invoke `hstr` directly if you want it.
{
  programs.hstr.enableZshIntegration = false;
  home.sessionVariables = {
    HSTR_CONFIG = "hicolor,raw-history-view,case-sensitive,keep-page";
  };
}
