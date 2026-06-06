# rmpc: modern (Rust) MPD client with album-art rendering. No HM module
# yet — config is RON-format at ~/.config/rmpc/config.ron.
#
# TODO: drop ./rmpc/config.ron and uncomment xdg.configFile below.
# Reference: https://mierak.github.io/rmpc/configuration/
_: {
  # xdg.configFile."rmpc/config.ron".source = ./rmpc/config.ron;
  #
  # Skeleton (RON):
  #   #![enable(implicit_some)]
  #   #![enable(unwrap_newtypes)]
  #   (
  #     address: "127.0.0.1:6600",
  #     password: None,
  #     theme: "default",
  #     volume_step: 5,
  #   )
}
