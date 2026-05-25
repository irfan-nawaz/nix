# SSH client config matched to the 4 forge identities in git.nix.
# Each match block pins identityFile so the right key is offered
# regardless of agent state; identitiesOnly=yes upstream avoids the
# "too many auth attempts" lockout when the agent holds many keys.
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    matchBlocks = {
      "*" = {
        addKeysToAgent = "yes";
        identitiesOnly = true;
        serverAliveInterval = 60;
        serverAliveCountMax = 3;
      };
      # GitHub: SSH over port 443 because some networks block 22.
      "github.com" = {
        hostname = "ssh.github.com";
        port = 443;
        user = "git";
        identityFile = "~/.ssh/id_ed25519_github_geekyants";
      };
      "github-personal" = {
        hostname = "ssh.github.com";
        port = 443;
        user = "git";
        identityFile = "~/.ssh/id_ed25519_github_personal";
      };
      "git.geekyants.com" = {
        hostname = "git.geekyants.com";
        user = "git";
        identityFile = "~/.ssh/id_ed25519_gitlab_geekyants";
      };
      "gitlab.com" = {
        hostname = "gitlab.com";
        user = "git";
        identityFile = "~/.ssh/id_ed25519_gitlab_tzero";
      };
    };
  };
}
