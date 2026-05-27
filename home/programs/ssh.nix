# SSH client config matched to the 4 forge identities in git.nix.
# Each match block pins identityFile so the right key is offered
# regardless of agent state; identitiesOnly=yes avoids the
# "too many auth attempts" lockout when the agent holds many keys.
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    settings = {
      "*" = {
        AddKeysToAgent = "yes";
        IdentitiesOnly = true;
        ServerAliveInterval = 60;
        ServerAliveCountMax = 3;
      };
      # GitHub: SSH over port 443 because some networks block 22.
      "github.com" = {
        HostName = "ssh.github.com";
        Port = 443;
        User = "git";
        IdentityFile = "~/.ssh/id_ed25519_github_geekyants";
      };
      "github-personal" = {
        HostName = "ssh.github.com";
        Port = 443;
        User = "git";
        IdentityFile = "~/.ssh/id_ed25519_github_personal";
      };
      "git.geekyants.com" = {
        HostName = "git.geekyants.com";
        User = "git";
        IdentityFile = "~/.ssh/id_ed25519_gitlab_geekyants";
      };
      "gitlab.com" = {
        HostName = "gitlab.com";
        User = "git";
        IdentityFile = "~/.ssh/id_ed25519_gitlab_tzero";
      };
    };
  };
}
