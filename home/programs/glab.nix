# glab: GitLab CLI. Config stays **fully imperative** -- do NOT manage
# ~/.config/glab-cli/config.yml from nix.
#
# Why: glab stores live OAuth refresh + access tokens inside the same
# config file (under the `hosts:` block) that holds user preferences.
# Writing that file from the nix store clobbers the tokens and logs you
# out of every host. This is exactly why HM upstream removed
# `programs.glab` (issue #8066) -- the module couldn't reconcile its
# declarative view with glab's stateful hosts block.
#
# Setup (run once per host):
#   glab auth login --hostname gitlab.com
#   glab auth login --hostname git.geekyants.com
#   # self-hosted only: also register an OAuth app and run
#   glab config set client_id <oauth-app-client-id> -h <host>
#
# Preferences (editor, aliases, glamour_style, etc.) are set with
# `glab config set <key> <value>` -- see docs/forge-cli-multi-account.md.
#
# glab itself is installed from modules/packages/dev.nix.
_: { }
