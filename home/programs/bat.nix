{
  programs.bat = {
    enable = true;
    config.theme = "Nord";
  };

  # Man pages rendered through bat: syntax-highlighted, searchable,
  # colour-coded sections. col -bx strips backspace-based bold/underline
  # sequences that troff emits before bat receives the text.
  home.sessionVariables.MANPAGER = "sh -c 'col -bx | bat -l man -p'";
}
