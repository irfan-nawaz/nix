# aichat: multi-provider LLM chat in the terminal. Settings serialise
# to ~/.config/aichat/config.yaml. API keys MUST stay out of the nix
# store -- export OPENAI_API_KEY / ANTHROPIC_API_KEY from a sops-nix
# secret instead of pinning them here.
_: {
  programs.aichat.settings = {
    model = "claude:claude-sonnet-4-5";
    temperature = 0.7;
    save = true;
    save_session = true;
    keybindings = "emacs";
    editor = "nvim";
    wrap = "auto";
    highlight = true;
    light_theme = false;
  };
}
