# Cursor (code-cursor) managed via the HM vscode module.
# HM writes settings to ~/Library/Application Support/Code/User/settings.json;
# Cursor reads from its own path, so we write the same settings there directly.
# HM installs extensions to ~/.vscode/extensions/; Cursor reads from
# ~/.cursor/extensions/ -- we symlink the latter to the former so both share
# one extension store. The activation script handles the one-time migration of
# any extensions Cursor wrote before the symlink existed.
{ pkgs, lib, ... }:
let
  editorSettings = {
    "editor.fontFamily" = "JetBrainsMono Nerd Font, Menlo, Monaco, monospace";
    "editor.fontSize" = 14;
    "editor.fontLigatures" = true;
    "editor.lineHeight" = 1.6;
    "editor.formatOnSave" = true;
    "editor.tabSize" = 2;
    "editor.renderWhitespace" = "boundary";
    "editor.minimap.enabled" = false;
    "editor.smoothScrolling" = true;
    "editor.cursorBlinking" = "smooth";
    "editor.cursorSmoothCaretAnimation" = "on";
    "files.trimTrailingWhitespace" = true;
    "files.insertFinalNewline" = true;
    "workbench.colorTheme" = "Catppuccin Mocha";
    "workbench.iconTheme" = "catppuccin-mocha";
    "workbench.startupEditor" = "none";
    "terminal.integrated.fontFamily" = "JetBrainsMono Nerd Font";
    "terminal.integrated.fontSize" = 13;

    # Error Lens — show diagnostics inline
    "errorLens.enabledDiagnosticLevels" = [ "error" "warning" "info" ];

    # GitLens — keep ambient decorations subtle
    "gitlens.currentLine.enabled" = true;
    "gitlens.hovers.currentLine.over" = "line";

    # Nix IDE — use nixpkgs-fmt for formatting
    "nix.enableLanguageServer" = true;
    "nix.serverPath" = "nil";
    "nix.formatterPath" = "nixpkgs-fmt";

    # Prettier — default formatter for supported languages
    "[javascript]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
    "[typescript]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
    "[json]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
    "[jsonc]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
    "[markdown]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
    "[yaml]"."editor.defaultFormatter" = "esbenp.prettier-vscode";

    # Terraform
    "[terraform]"."editor.defaultFormatter" = "hashicorp.terraform";
    "[terraform-vars]"."editor.defaultFormatter" = "hashicorp.terraform";
    "terraform.experimentalFeatures.validateOnSave" = true;
  };
in
{
  programs.vscode = {
    enable = true;
    package = pkgs.code-cursor;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      # Theme
      catppuccin.catppuccin-vsc
      catppuccin.catppuccin-vsc-icons

      # Git
      eamodio.gitlens

      # Diagnostics
      usernamehw.errorlens

      # Formatting & linting
      esbenp.prettier-vscode
      dbaeumer.vscode-eslint

      # Language support
      jnoortheen.nix-ide
      redhat.vscode-yaml
      hashicorp.terraform
      tamasfe.even-better-toml

      # Quality of life
      streetsidesoftware.code-spell-checker
    ];
    profiles.default.userSettings = editorSettings;
  };

  # Write Cursor's settings.json as a regular managed file (not a nix store
  # symlink) so Cursor can write back to it when settings change via the UI.
  home.file."Library/Application Support/Cursor/User/settings.json" = {
    text = builtins.toJSON editorSettings;
    force = true;
  };

  # Cursor.app reads extensions from ~/.cursor/extensions/extensions.json.
  # HM installs extensions to ~/.vscode/extensions/ and writes a manifest to
  # .extensions-immutable.json (used by the CLI wrapper). The .app bypasses
  # the wrapper entirely so extensions.json stays []. Fix: symlink Cursor's
  # dir to the shared store, then copy the immutable manifest into
  # extensions.json so the .app picks up all HM-managed extensions.
  home.activation.linkCursorExtensions = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    CURSOR_EXT="$HOME/.cursor/extensions"
    VSCODE_EXT="$HOME/.vscode/extensions"
    mkdir -p "$VSCODE_EXT"
    if [ -d "$CURSOR_EXT" ] && [ ! -L "$CURSOR_EXT" ]; then
      cp -rn "$CURSOR_EXT"/. "$VSCODE_EXT"/ 2>/dev/null || true
      rm -rf "$CURSOR_EXT"
    fi
    ln -sfn "$VSCODE_EXT" "$CURSOR_EXT"
    # Populate mutable extensions.json from HM's immutable manifest so
    # Cursor.app discovers all extensions without going through the CLI wrapper.
    IMMUTABLE="$VSCODE_EXT/.extensions-immutable.json"
    if [ -f "$IMMUTABLE" ]; then
      cp -f "$IMMUTABLE" "$VSCODE_EXT/extensions.json"
    fi
  '';
}
