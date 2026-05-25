# broot: enable shell function (`br`), add useful verbs, keep theme
# minimal so the file tree dominates.
{
  programs.broot = {
    enableZshIntegration = true;
    settings = {
      default_flags = "gh";
      modal = false;
      verbs = [
        {
          invocation = "edit";
          key = "F2";
          shortcut = "e";
          execution = "$EDITOR {file}";
          leave_broot = false;
        }
        {
          invocation = "git_diff";
          key = "ctrl-g";
          execution = "git difftool -y {file}";
          leave_broot = false;
        }
        {
          invocation = "open";
          key = "ctrl-o";
          execution = "open {file}";
          leave_broot = false;
        }
      ];
    };
  };
}
