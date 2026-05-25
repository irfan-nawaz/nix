# rclone: cloud-storage rsync. Remotes need API tokens / OAuth, so
# the HM `remotes` block is left as a stub. Use one of:
#   $ rclone config             # interactive, writes ~/.config/rclone/rclone.conf
#   $ sops <(rclone config show) # then load the encrypted blob via sops-nix
_: {
  # programs.rclone.remotes = {
  #   "gdrive_personal" = {
  #     type = "drive";
  #     scope = "drive";
  #     token = "PLACEHOLDER";   # use sops-nix-provided file instead
  #   };
  #   "s3_backup" = {
  #     type = "s3";
  #     provider = "AWS";
  #     region = "us-east-1";
  #   };
  # };
}
