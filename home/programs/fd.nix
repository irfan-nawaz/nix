# fd: friendlier `find`. Default to showing dotfiles and skipping the
# usual project noise so `fd <pat>` does what you mean inside a repo.
_: {
  programs.fd = {
    hidden = true;
    ignores = [
      ".git/"
      "node_modules/"
      ".direnv/"
      "result"
      "target/"
      ".venv/"
    ];
  };
}
