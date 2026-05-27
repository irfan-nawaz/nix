# zk: plain-text Zettelkasten over a notebook directory.
#
# We deliberately do NOT use `zk init`: it has a multi-step interactive
# wizard (WikiLinks pref, tag syntax multi-select, ...) that hangs HM
# activation. A zk "notebook" is just a directory with a `.zk/`
# subdirectory; mkdir is fully declarative and idempotent. zk creates
# `.zk/notebook.db` itself on first use and falls back to internal
# defaults when `.zk/config.toml` is absent.
{ lib, ... }:
{
  home.activation.zkNotebook = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD mkdir -p "$HOME/Documents/zk/.zk/templates"
    if [ ! -f "$HOME/Documents/zk/.zk/templates/default.md" ]; then
      $DRY_RUN_CMD cp "$HOME/.zk/templates/default.md" "$HOME/Documents/zk/.zk/templates/default.md"
    fi
  '';

  programs.zk.settings = {
    notebook.dir = "~/Documents/zk";
    note = {
      language = "en";
      default-title = "Untitled";
      filename = "{{id}}-{{slug title}}";
      extension = "md";
      template = "default.md";
      id-charset = "alphanum";
      id-length = 4;
      id-case = "lower";
    };
    extra.author = "Irfan";
    tool = {
      editor = "nvim";
      fzf-preview = "bat -p --color always {-1}";
    };
  };
}
