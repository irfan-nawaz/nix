{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # Core Kubernetes
    kubectl
    kubernetes-helm
    kustomize
    kubectx
    stern
    # k9s installed via home/programs/k9s.nix (HM owns its settings + skin).

    # Local Kubernetes
    kind
    k3d

    # Cluster debugging
    kube-score

    # Containers & OCI tooling
    skopeo
    dive
    hadolint
    ctop

    # GitOps
    argocd
    fluxcd
  ];
}
