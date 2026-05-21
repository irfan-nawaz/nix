{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    terraform
    terragrunt
    pulumi
    terraform-docs
    terraform-ls
    tflint
  ];
}
