{
  config,
  lib,
  pkgs-unstable,
  ...
}:
let
  cfg = config.mySystem.home.ai;
in
{
  options.mySystem.home.ai.enable = lib.mkEnableOption "AI / LLM CLI tooling";

  config = lib.mkIf cfg.enable {
    programs.aichat.enable = true;
    programs.aichat.package = pkgs-unstable.aichat;
    programs.claude-code.enable = true;
    programs.claude-code.package = pkgs-unstable.claude-code;
    programs.fabric-ai.enable = true;
    programs.fabric-ai.package = pkgs-unstable.fabric-ai;
    programs.opencode.enable = true;
    programs.opencode.package = pkgs-unstable.opencode;
  };
}
