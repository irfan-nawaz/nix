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
    opentofu # open-source Terraform fork (HashiCorp went BSL Aug 2023); binary: `tofu`
    infracost # shows cloud cost delta of Terraform/OpenTofu changes before apply
  ];
}
