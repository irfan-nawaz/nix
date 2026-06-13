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

    # TOTP generator for seeds not stored in 1Password.
    oath-toolkit

    # Scanners
    trivy
    syft # generates SBOMs; pair with grype for CVE scanning
    grype # CVE vulnerability scanner; `syft . | grype` gives full report for any dir
    semgrep
    gitleaks
    mkcert
    cosign
    oras
  ];
}
