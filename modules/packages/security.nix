{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # Secrets management
    sops
    age
    ssh-to-age
    pass

    # Secrets / identity providers
    _1password-cli
    doppler

    # Scanners
    trivy
    syft
    semgrep
    gitleaks
    mkcert
    cosign
    oras
  ];
}
