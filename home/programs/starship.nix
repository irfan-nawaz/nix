{ lib, ... }:
{
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    # HM-generated settings are left empty; the actual prompt config
    # lives in starship/starship.toml so it can be copy-pasted from
    # https://starship.rs without translation.
    settings = lib.mkDefault { };
  };

  xdg.configFile."starship.toml".source = ./starship/starship.toml;
}
