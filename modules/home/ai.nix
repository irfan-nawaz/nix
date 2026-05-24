{ config, lib, ... }:
let
  cfg = config.mySystem.home.ai;
in
{
  options.mySystem.home.ai.enable = lib.mkEnableOption "AI / LLM CLI tooling";

  config = lib.mkIf cfg.enable {
    programs.aichat.enable = true;
    programs.claude-code.enable = true;
    programs.fabric-ai.enable = true;
    programs.opencode.enable = true;
  };
}
