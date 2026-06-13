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
    kubeconform # validates K8s manifests against JSON schemas (replaces deprecated kubeval)

    # Helm ecosystem
    helmfile # declarative multi-chart Helm management; `helmfile sync` applies releases atomically
    krew # kubectl plugin manager; `kubectl krew install <plugin>` adds plugins ad-hoc

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
