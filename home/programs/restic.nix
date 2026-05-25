# restic: encrypted snapshot backup. Repo can be local, S3, B2, SFTP, etc.
# HM ships a launchd-backed service that runs `restic backup` on schedule.
#
# TODO: pick a repo URL + put RESTIC_PASSWORD in a secret file, then
# enable. First-time setup:
#   $ restic -r <repoUrl> init
_: {
  # services.restic.backups.daily = {
  #   enable = false;
  #   initialize = true;
  #   repository = "/Volumes/Backup/restic";    # or "s3:s3.amazonaws.com/PLACEHOLDER"
  #   passwordFile = "/run/secrets/restic_password";
  #   paths = [
  #     "/Users/shaikmdirfannawaz/Documents"
  #     "/Users/shaikmdirfannawaz/Pictures"
  #     "/Users/shaikmdirfannawaz/nix"
  #   ];
  #   exclude = [
  #     "**/.direnv"
  #     "**/node_modules"
  #     "**/target"
  #     "**/result"
  #   ];
  #   timerConfig = { OnCalendar = "daily"; Persistent = true; };
  #   pruneOpts = [
  #     "--keep-daily 7"
  #     "--keep-weekly 4"
  #     "--keep-monthly 12"
  #   ];
  # };
}
