# Cursor (code-cursor) managed via the HM vscode module — same settings
# format, different package. HM writes to the correct
# ~/Library/Application Support/Cursor/User/settings.json path.
{ pkgs, ... }:
{
  programs.vscode = {
    enable = true;
    package = pkgs.code-cursor;
    profiles.default.userSettings = {
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
      "workbench.colorTheme" = "Tokyo Night";
      "workbench.startupEditor" = "none";
      "terminal.integrated.fontFamily" = "JetBrainsMono Nerd Font";
      "terminal.integrated.fontSize" = 13;
    };
  };
}
