{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # Cloud provider CLIs
    awscli2
    aws-vault # stores creds in macOS Keychain, vends short-lived STS tokens per role

    # Kubernetes cloud auth
    eksctl

    # Serverless
    aws-sam-cli
  ];
}
