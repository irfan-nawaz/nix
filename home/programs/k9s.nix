# k9s: TUI for Kubernetes. Reads kubeconfigs from the standard
# KUBECONFIG path. Skin + hotkeys live under ~/.config/k9s.
#
# Settings/skin stubs stay commented out until there's a cluster reachable
# to verify them against -- programs.k9s.enable alone installs the binary.
_: {
  programs.k9s.enable = true;

  # programs.k9s.settings.k9s = {
  #   refreshRate    = 2;
  #   maxConnRetry   = 5;
  #   enableMouse    = true;
  #   headless       = false;
  #   logger = {
  #     tail        = 200;
  #     buffer      = 500;
  #     sinceSeconds = 300;
  #   };
  # };
  # programs.k9s.skins.tokyonight = {
  #   k9s.body = {
  #     fgColor   = "#c0caf5";
  #     bgColor   = "#1a1b26";
  #     logoColor = "#7aa2f7";
  #   };
  # };
}
