{ username, lib, ... }:
{
  imports = [ ./profile.nix ];

  home.username = username;
  home.homeDirectory = "/Users/${username}";

  # M4, 48 GB RAM — give colima more headroom for k8s/dev experiments.
  services.colima.profiles.default.settings = {
    cpu = 8;
    memory = 16;
    disk = 150;
  };

  # 70b model aliases and aichat client — personal machine only (needs ~40 GB RAM).
  # Work laptop stays on dolphin3:8b which fits in any modern machine.
  programs.zsh.shellAliases.lm70 = "ollama run dolphin3:70b";

  programs.aichat.settings.clients = lib.mkForce [
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
        {
          name = "dolphin3:70b";
          max_input_tokens = 131072;
        }
      ];
    }
  ];
}
