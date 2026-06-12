# Shell aliases grouped by purpose. Each `let` binding is one category
# attrset; the final expression unions them into a single shellAliases
# attrset. Keeping the categories visible here doubles as documentation:
# the named bindings *are* the index.
#
# Hostname is threaded in for the rebuild/testbuild family of aliases
# (`nds`, `ndb`) that target `~/nix#<host>` and therefore differ per
# machine even though everyone wants them.
{ hostname }:
let
  navigation = {
    ".." = "cd ..";
    "..." = "cd ../..";
    "...." = "cd ../../..";

    c = "clear";

    # zoxide
    z = "__zoxide_z";
    zi = "__zoxide_zi";

    # yazi / xplr
    x = "xplr";
    y = "yazi";
  };

  # modernReplacements overrides POSIX-named tools with modern alternatives.
  # `find = fd` and `grep = rg` are deliberate productivity wins (smart-case,
  # .gitignore-aware, parallel) but DO bite when running scripts pasted from
  # the internet that expect POSIX find/grep flag semantics. If a one-liner
  # fails with "unknown flag" or unexpected results, run it via
  #   command find ...   /   command grep ...
  # to bypass the alias for that single invocation.
  modernReplacements = {
    ls = "eza --icons";
    ll = "eza -lh --icons --git";
    la = "eza -lah --icons --git";
    lt = "eza --tree --level=2 --icons";

    cat = "bat";
    ps = "procs";
    top = "btop";
    du = "dust";
    df = "duf";
    find = "fd";
    grep = "rg";
    diff = "difft";

    # safer defaults
    cp = "cp -iv";
    mv = "mv -iv";
    rm = "rm -iv";
  };

  git = {
    g = "git";

    ga = "git add";
    gaa = "git add --all";

    gc = "git commit";
    gcm = "git commit -m";

    gp = "git push";
    gpl = "git pull";

    gf = "git fetch";
    gfa = "git fetch --all --prune";

    gs = "git status -sb";

    gd = "git diff";
    gdc = "git diff --cached";

    gl = "git log --oneline --graph --decorate";
    gll = "git log --graph --pretty=format:'%C(yellow)%h%Creset %Cgreen(%cr)%Creset %C(bold blue)<%an>%Creset %s'";

    gb = "git branch";
    gco = "git checkout";
    gcb = "git checkout -b";

    grh = "git reset --hard";
    gclean = "git clean -fd";

    lg = "lazygit";

    # git security / audits
    leaks = "gitleaks detect";
  };

  docker = {
    d = "docker";
    dc = "docker compose";

    dps = "docker ps";
    dimg = "docker images";

    dex = "docker exec -it";
    dlog = "docker logs -f";

    dcu = "docker compose up";
    dcud = "docker compose up -d";
    dcd = "docker compose down";

    dprune = "docker system prune -af";

    lzd = "lazydocker";

    colima-start = "colima start";
    colima-stop = "colima stop";
    colima-restart = "colima restart";
    colima-status = "colima status";
  };

  k8s = {
    # kubecolor wraps kubectl with status-aware colours (green/red/yellow).
    # All kubectl invocations go through it so output is consistently coloured.
    k = "kubecolor";
    kubectl = "kubecolor";

    kgp = "kubecolor get pods";
    kgs = "kubecolor get svc";
    kgd = "kubecolor get deployments";
    kgn = "kubecolor get nodes";

    kaf = "kubectl apply -f";
    kdf = "kubectl delete -f";

    kl = "kubectl logs -f";
    ke = "kubectl exec -it";

    # kubectl-neat: strip managedFields noise from -o yaml output.
    ky = "kubectl get -o yaml | kubectl neat";

    kctx = "kubectx";
    kns = "kubens";

    k9 = "k9s";

    sternf = "stern .";

    kind-up = "kind create cluster --config ~/.config/kind/cluster.yaml";
    kind-down = "kind delete cluster";
  };

  iac = {
    tf = "terraform";
    tg = "terragrunt";

    tfi = "terraform init";
    tfp = "terraform plan";
    tfa = "terraform apply";
    tfd = "terraform destroy";

    tffmt = "terraform fmt -recursive";

    # checkov: scan current directory for IaC security issues.
    ck = "checkov -d .";

    # aws-vault: exec into a role's STS session. Usage: ave <profile> <cmd>
    ave = "aws-vault exec";
    avl = "aws-vault list";
  };

  nix = {
    ns = "nix shell";
    nd = "nix develop";

    nf = "nix flake";
    nfu = "nix flake update";

    nds = "sudo darwin-rebuild switch --flake ~/nix#${hostname}";
    ndb = "darwin-rebuild build --flake ~/nix#${hostname}";

    hms = "home-manager switch";
    hmb = "home-manager build";

    nix-clean = "nix-collect-garbage -d";
  };

  networking = {
    ports = "lsof -i -P -n";

    pingg = "gping";

    sniff = "sudo tcpdump -i any";

    bw = "bandwhich";

    speed = "iperf3";

    scan = "nmap -sV";

    rustscan-fast = "rustscan -a";

    who = "whois";

    tlscheck = "openssl s_client -connect";

    semscan = "semgrep scan";

    trivyfs = "trivy fs .";
  };

  http = {
    http = "xh";
    api = "atac";

    # pretty json
    json = "jq";
    jqp = "jqp";
  };

  productivity = {
    v = "nvim";
    svim = "sudo nvim";

    tm = "tmux";
    ta = "tmux attach -t";
    tls = "tmux ls";

    ff = "fastfetch";
    nfetch = "fastfetch";

    clock = "LC_ALL=C peaclock";
    calendar = "carl";

    tldr = "tldr";

    weather = "curl wttr.in";
  };

  search = {
    fzf-preview = "fzf --preview 'bat --style=numbers --color=always {}'";
    rgf = "rg --files | fzf";
  };

  media = {
    ytdl = "yt-dlp";
    mp = "mpv";
  };

  ai = {
    ai = "aichat";
    fabric = "fabric";
    op = "opencode";
    cc = "claude";
  };

  bench = {
    bench = "hyperfine";
  };

  data = {
    yaml2json = "yq -o=json";
    json2yaml = "yq -P";
  };

  misc = {
    # `exec zsh` instead of `source ~/.zshrc`: re-sourcing a HM-generated
    # zshrc double-loads compinit + autosuggestion/syntax-highlight
    # widgets + atuin/fzf/intelli-shell bindings. `exec` replaces the
    # process cleanly with a fresh shell -- no widget duplication.
    reload = "exec zsh";
  };
in
navigation
// modernReplacements
// git
// docker
// k8s
// iac
// nix
// networking
// http
// productivity
// search
// media
// ai
// bench
// data
// misc
