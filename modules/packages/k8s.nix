{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # Core Kubernetes
    kubectl
    kubernetes-helm
    kustomize
    k9s
    kubectx
    stern

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
