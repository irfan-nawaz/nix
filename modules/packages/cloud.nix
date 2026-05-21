{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # Cloud provider CLIs
    awscli2

    # Kubernetes cloud auth
    eksctl

    # Serverless
    aws-sam-cli
  ];
}
