# readline: GNU Readline (~/.inputrc). Mostly affects bash, gdb, psql,
# python -i, etc. -- zsh has its own line editor (zle). These defaults
# make case-insensitive completion + colored listings the norm.
_: {
  programs.readline = {
    extraConfig = ''
      set editing-mode emacs
      set completion-ignore-case on
      set completion-map-case on
      set show-all-if-ambiguous on
      set show-all-if-unmodified on
      set colored-stats on
      set colored-completion-prefix on
      set mark-symlinked-directories on
      set visible-stats on
      set bell-style none
    '';
  };
}
