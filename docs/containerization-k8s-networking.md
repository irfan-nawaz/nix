# Containerization, Kubernetes, IaC & Networking stack

Reference for the full cloud-native tooling layer installed on both hosts via
`hosts/common/darwin.nix`. All modules are unconditional — every tool listed
here is present on every machine after `darwin-rebuild switch`.

---

## Table of contents

1. [Stack overview (layers)](#1-stack-overview-layers)
2. [Layer 1 — Container runtime: Colima](#2-layer-1--container-runtime-colima)
3. [Layer 2 — Docker tooling](#3-layer-2--docker-tooling)
4. [Layer 3 — Local Kubernetes](#4-layer-3--local-kubernetes)
5. [Layer 4 — Kubernetes operations](#5-layer-4--kubernetes-operations)
6. [Layer 5 — Cloud / remote clusters](#6-layer-5--cloud--remote-clusters)
7. [Layer 6 — Networking diagnostics](#7-layer-6--networking-diagnostics)
8. [Data flow diagram](#8-data-flow-diagram)
9. [Gap analysis](#9-gap-analysis)
10. [Domain readiness summary](#10-domain-readiness-summary)

---

## 1. Stack overview (layers)

```
Layer 6  Networking diagnostics   nmap · wireshark · mtr · bandwhich · tailscale ...
Layer 5  Cloud / remote clusters  awscli2 · eksctl · terraform · pulumi · argocd
Layer 4  Kubernetes operations    kubectl · kubectx · helm · kustomize · stern · k9s
Layer 3  Local Kubernetes         kind (configured) · k3d (ad-hoc)
Layer 2  Docker tooling           lazydocker · ctop · dive · skopeo · hadolint
Layer 1  Container runtime        Colima (Apple VZ · virtiofs · Docker daemon)
```

Nix source files:

| Module file | What it installs |
|---|---|
| `home/programs/colima.nix` | Colima launchd service + VM settings |
| `home/programs/k9s.nix` | k9s binary (HM-managed; settings stubbed) |
| `home/programs/kind.nix` | kind cluster config at `~/.config/kind/cluster.yaml` |
| `home/programs/lazydocker.nix` | lazydocker TUI with Catppuccin theme |
| `modules/packages/k8s.nix` | kubectl, helm, kubectx, stern, kind, k3d, skopeo, dive, hadolint, ctop, argocd, fluxcd, kube-score |
| `modules/packages/cloud.nix` | awscli2, eksctl, aws-sam-cli |
| `modules/packages/iac.nix` | terraform, terragrunt, pulumi, terraform-docs, terraform-ls, tflint |
| `modules/packages/network.nix` | Full diagnostics toolkit (see Layer 6) |

---

## 2. Layer 1 — Container runtime: Colima

`home/programs/colima.nix` — replaces Docker Desktop.

| Setting | Value | What it means |
|---|---|---|
| `vmType = "vz"` | Apple Virtualization Framework | Native ARM; better performance than QEMU |
| `mountType = "virtiofs"` | virtiofs | Fast host↔VM file sharing (vs 9p/sshfs) |
| `mountInotify = true` | enabled | `inotify` events work inside containers — file watchers don't miss changes |
| `network.address = true` | enabled | VM gets a routable IP, not just loopback |
| `forwardAgent = true` | enabled | SSH agent forwarded into VM (git over SSH from containers) |
| `setDockerHost = false` | disabled | `DOCKER_HOST` is **not** auto-exported; see gap #2 below |
| CPU / RAM / Disk | 4 / 8 GB / 100 GB | Defaults; override per host via `lib.mkDefault` |
| `runtime = "docker"` | Docker | Docker daemon inside the VM (not containerd) |

**Start/stop:**

```bash
colima start            # starts VM + docker daemon
colima stop             # stops VM
colima status           # show running profile(s)
colima list             # all profiles
```

---

## 3. Layer 2 — Docker tooling

| Tool | Source | Role |
|---|---|---|
| `lazydocker` | `home/programs/lazydocker.nix` | TUI for containers, images, volumes; Catppuccin-themed |
| `ctop` | `modules/packages/k8s.nix` | Live CPU/mem per container (like `htop` for Docker) |
| `dive` | `modules/packages/k8s.nix` | Inspect Docker image layers; find bloat |
| `skopeo` | `modules/packages/k8s.nix` | Inspect/copy OCI images without pulling them |
| `hadolint` | `modules/packages/k8s.nix` | Dockerfile linter |

---

## 4. Layer 3 — Local Kubernetes

### kind (configured)

Config at `~/.config/kind/cluster.yaml` (owned by `home/programs/kind.nix`):

```yaml
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
```

1 control-plane + 2 workers. Port 30080 mapped to host for NodePort access.

```bash
kind create cluster --config ~/.config/kind/cluster.yaml
kind delete cluster
kind get clusters
```

### k3d (ad-hoc)

Lighter K3s-in-Docker. No config file — used ad-hoc for quick throwaway clusters.

```bash
k3d cluster create dev
k3d cluster delete dev
```

---

## 5. Layer 4 — Kubernetes operations

All installed via `modules/packages/k8s.nix`:

| Tool | Role |
|---|---|
| `kubectl` | Core API client |
| `kubectx` | Fast context switching (`kubectx prod`, `kubens kube-system`) |
| `kubernetes-helm` | Package manager; install/upgrade chart releases |
| `kustomize` | Overlay-based config management |
| `stern` | Multi-pod log tailing; follows across pod restarts |
| `kube-score` | Static analysis — flags misconfigs before `kubectl apply` |
| `k9s` | TUI dashboard; reads from standard `KUBECONFIG` path |

**GitOps CLIs** (installed, not yet configured server-side):

| Tool | Role |
|---|---|
| `argocd` | Argo CD CLI — manage apps, sync, rollback |
| `fluxcd` | Flux CLI — bootstrap, reconcile, diff |

---

## 6. Layer 5 — Cloud / remote clusters

### AWS (`modules/packages/cloud.nix`)

| Tool | Role |
|---|---|
| `awscli2` | AWS API client |
| `eksctl` | Create/manage EKS clusters; writes kubeconfig on connect |
| `aws-sam-cli` | Serverless (Lambda) build + deploy |

**Connect to an EKS cluster:**

```bash
eksctl utils write-kubeconfig --cluster <name> --region <region>
kubectl config get-contexts          # verify context added
kubectx <cluster-context>            # switch to it
```

The `kube_ctx` sketchybar pill lights up when the active context is not `colima*`.

### IaC (`modules/packages/iac.nix`)

| Tool | Role |
|---|---|
| `terraform` | Infrastructure provisioning |
| `terragrunt` | DRY wrapper for Terraform (remote state, dependency graph) |
| `pulumi` | SDK-based IaC (TypeScript/Python/Go) |
| `terraform-docs` | Auto-generate module documentation |
| `terraform-ls` | Language server (autocomplete in VSCode/Cursor) |
| `tflint` | Linter — catches provider errors and misconfigs before apply |

---

## 7. Layer 6 — Networking diagnostics

All in `modules/packages/network.nix`:

| Category | Tools |
|---|---|
| Packet capture | `tcpdump`, `wireshark`, `termshark` |
| Port / host scanning | `nmap`, `zenmap`, `masscan`, `rustscan` |
| Path analysis | `mtr`, `trippy` |
| Bandwidth monitoring | `bandwhich`, `bmon`, `iftop`, `nload` |
| Misc diagnostics | `iperf3`, `whois`, `netcat`, `arp-scan`, `mdns-scanner`, `dstp` |
| HTTP clients | `httpie`, `xh` |
| Tunnels | `tailscale`, `cloudflared`, `ngrok` |
| Traffic visualization | `sniffnet`, `cariddi` |
| API testing | `atac` |

**Tailscale** is installed but has no Nix-managed config (`services.tailscale` not declared). Activate manually if needed for connecting to private clusters without a full VPN config.

---

## 8. Data flow diagram

```
Your shell
    │
    ├── docker CLI ──► DOCKER_HOST socket ──► Colima VM (Apple VZ)
    │                                              └── Docker daemon
    │                                                    ├── containers (docker run/compose)
    │                                                    └── kind nodes (k8s-in-docker)
    │
    ├── kubectl / k9s / helm / stern
    │       └── KUBECONFIG (~/.kube/config)
    │               ├── kind-kind (local, created by `kind create cluster`)
    │               ├── colima (local k8s if colima k8s mode enabled)
    │               └── <eks-cluster> (remote, written by `eksctl`)
    │
    └── terraform / terragrunt / pulumi
            └── AWS API (via ~/.aws/credentials or env vars)
                    └── EKS clusters → feeds back into KUBECONFIG
```

---

## 9. Gap analysis

### Gap 1 — Docker CLI not explicitly in any package list

`pkgs.docker` does not appear in `k8s.nix`, `base.nix`, or any other module.
The colima HM module may pull it in as a dependency — but if it doesn't, `docker
build`, `docker ps`, and `docker compose` fail silently with "command not found".

**Verify:** `which docker` after rebuild. If missing, add `pkgs.docker` or
`pkgs.docker-client` to `modules/packages/k8s.nix`.

### Gap 2 — `DOCKER_HOST` not set declaratively

`setDockerHost = false` in `colima.nix` means the colima socket path is not
exported to the shell. Every `docker` invocation needs:

```bash
export DOCKER_HOST="unix://${HOME}/.colima/default/docker.sock"
```

If this is not in `home/programs/zsh/` env or aliases, you hit "Cannot connect
to Docker daemon" every session until `colima start` sets it. Fix: either flip
`setDockerHost = true`, or add the export declaratively to `zsh/env.nix`.

### Gap 3 — No AWS credential management

`awscli2` + `eksctl` read from `~/.aws/credentials` or env vars. There is no
`aws-vault`, `aws-sso-util`, or similar tool for multi-account switching or
short-lived credential vending. For a single AWS account this is fine. For
multiple accounts / roles (dev/staging/prod or multiple clients), credential
management becomes a daily friction point.

**Tool to consider:** `aws-vault` (stores credentials in macOS Keychain, vends
temporary STS tokens per role) — add to `modules/packages/cloud.nix`.

### Gap 4 — No IaC security scanning

`tflint` catches provider-level errors and misconfigs. It does not catch security
issues: open security groups, public S3 buckets, unencrypted EBS volumes, missing
IMDSv2 enforcement. The `modules/packages/security.nix` module covers host
security, not infrastructure code security.

**Tool to consider:** `checkov` or `tfsec` — add to `modules/packages/iac.nix`.
Integrates with `pre-commit` or CI to block insecure infra before apply.

### Gap 5 — Tailscale installed but inert

`tailscale` binary is in `network.nix` but no `services.tailscale` is declared
and no daemon is running. Either activate it (useful for routing dev machine
traffic to private EKS VPC endpoints without full VPN config) or remove it to
reduce noise.

---

## 10. Domain readiness summary

| Domain | Readiness | Blocker |
|---|---|---|
| Containerization | **90 %** | Docker CLI presence unverified; `DOCKER_HOST` not declaratively set |
| Kubernetes (local) | **95 %** | Fully configured; k9s settings stubbed until live cluster |
| Kubernetes (remote / EKS) | **85 %** | CLI ready; no credential management for multi-account |
| IaC | **85 %** | Write → lint → apply loop covered; no security scanning layer |
| GitOps | **60 %** | CLIs present; no server-side ArgoCD/Flux setup (expected for dev machine) |
| Cloud / AWS | **80 %** | Single-account workflows solid; multi-account needs `aws-vault` |
| Networking diagnostics | **100 %** | Comprehensive; arguably over-provisioned |

For day-to-day work — build images, run containers, deploy to k8s, manage AWS
infrastructure, debug networking — the stack is complete. The two items worth
addressing immediately are **Gap 1** (verify docker CLI is actually installed)
and **Gap 2** (set `DOCKER_HOST` declaratively), as both can silently break
standard workflows after a fresh rebuild.
