{
  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    tmux.enableShellIntegration = true;
    defaultOptions = [ "--no-mouse" ];

    # Use fd as the file source: .gitignore-aware, fast, no noise dirs.
    defaultCommand = "fd --type f --hidden --follow --exclude .git";
    fileWidgetCommand = "fd --type f --hidden --follow --exclude .git";

    # Ctrl+T shows bat syntax-highlighted preview on the right.
    fileWidgetOptions = [
      "--preview 'bat --color=always --style=numbers --line-range=:300 {}'"
      "--preview-window=right:55%:wrap"
    ];

    # Alt+C picks directories; eza tree preview.
    changeDirWidgetCommand = "fd --type d --hidden --follow --exclude .git";
    changeDirWidgetOptions = [
      "--preview 'eza --tree --level=2 --icons --color=always {}'"
      "--preview-window=right:40%"
    ];
  };
}
