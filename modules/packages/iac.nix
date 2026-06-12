{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    terraform
    terragrunt
    pulumi
    terraform-docs
    terraform-ls
    tflint
    checkov # IaC security scanner: open SGs, public S3, missing encryption, etc.
  ];
}
