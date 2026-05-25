# awscli: AWS CLI v2. Credentials NEVER belong in the nix store --
# use SSO (`aws sso login`), IMDS, or a sops-nix-managed
# ~/.aws/credentials file.
#
# Package coordination: modules/packages/cloud.nix already installs
# pkgs.awscli2, so set programs.awscli.package to the same derivation
# to avoid HM pulling a second copy onto PATH.
{ pkgs, ... }:
{
  programs.awscli = {
    enable = true;
    package = pkgs.awscli2;
    settings = {
      default = {
        region = "us-east-1";
        output = "yaml";
        cli_pager = "";
      };
    };
    # credentials = {
    #   default = {
    #     credential_process = "sh -c 'cat /run/secrets/aws_default'";
    #   };
    # };
  };
}
