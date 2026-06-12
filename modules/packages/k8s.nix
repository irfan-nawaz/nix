{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # Core Kubernetes
    kubectl
    kubecolor # color-codes kubectl output by resource status (green/red/yellow)
    kubectl-neat # `kubectl get -o yaml | kubectl neat` strips managed-field noise
    # helm wrapped with diff plugin: `helm diff upgrade` shows k8s delta before apply
    (wrapHelm kubernetes-helm { plugins = [ kubernetes-helmPlugins.helm-diff ]; })
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
