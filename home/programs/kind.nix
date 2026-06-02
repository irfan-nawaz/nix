# kind: Kubernetes in Docker. No HM module — drop cluster config into XDG.
# Usage: kind create cluster --config ~/.config/kind/cluster.yaml
_: {
  xdg.configFile."kind/cluster.yaml".text = ''
    kind: Cluster
    apiVersion: kind.x-k8s.io/v1alpha4
    nodes:
      - role: control-plane
        extraPortMappings:
          - containerPort: 30080
            hostPort: 30080
            protocol: TCP
      - role: worker
      - role: worker
  '';
}
