# aichat: multi-provider LLM chat in the terminal. Settings serialise
# to ~/.config/aichat/config.yaml. API keys MUST stay out of the nix
# store -- export OPENAI_API_KEY / ANTHROPIC_API_KEY from a sops-nix
# secret instead of pinning them here.
_: {
  programs.aichat.settings = {
    model = "claude:claude-sonnet-4-6";
    temperature = 0.7;
    save = true;
    save_session = true;
    keybindings = "emacs";
    editor = "nvim";
    wrap = "auto";
    highlight = true;
    light_theme = false;
    # Local ollama endpoint — enables `aichat -m ollama:personal` and `aichat -m ollama:dolphin3:8b`.
    # Run `ollama serve` first; models must be pulled via `ollama pull <name>`.
    clients = [
      {
        type = "openai-compatible";
        name = "ollama";
        api_base = "http://localhost:11434/v1";
        models = [
          {
            name = "personal";
            max_input_tokens = 131072;
          }
          {
            name = "dolphin3:8b";
            max_input_tokens = 131072;
          }
          # dolphin3:70b added in home/users/irfan-personal.nix — needs 40 GB RAM
        ];
      }
    ];
  };
}
