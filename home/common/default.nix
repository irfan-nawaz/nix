{
  config,
  pkgs,
  lib,
  hostname,
  ...
}:
{
  home.stateVersion = "26.05";

  xdg = {
    enable = true;
    cacheHome = "${config.home.homeDirectory}/.cache";
    configHome = "${config.home.homeDirectory}/.config";
    dataHome = "${config.home.homeDirectory}/.local/share";
    stateHome = "${config.home.homeDirectory}/.local/state";
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    PAGER = "less";
  };

  home.packages = with pkgs; [
    slack
    docker
    docker-compose
    tableplus
    raycast
    meetingbar
    postman
    notion-app
    code-cursor
    ghostty-bin
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      # -------------------------------------------------
      # Navigation
      # -------------------------------------------------

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

      # -------------------------------------------------
      # Modern replacements
      # -------------------------------------------------

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

      # -------------------------------------------------
      # Git
      # -------------------------------------------------

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

      # -------------------------------------------------
      # Docker / Colima
      # -------------------------------------------------

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

      # -------------------------------------------------
      # Kubernetes
      # -------------------------------------------------

      k = "kubectl";

      kgp = "kubectl get pods";
      kgs = "kubectl get svc";
      kgd = "kubectl get deployments";
      kgn = "kubectl get nodes";

      kaf = "kubectl apply -f";
      kdf = "kubectl delete -f";

      kl = "kubectl logs -f";
      ke = "kubectl exec -it";

      kctx = "kubectx";
      kns = "kubens";

      k9 = "k9s";

      sternf = "stern .";

      # -------------------------------------------------
      # Terraform / IaC
      # -------------------------------------------------

      tf = "terraform";
      tg = "terragrunt";

      tfi = "terraform init";
      tfp = "terraform plan";
      tfa = "terraform apply";
      tfd = "terraform destroy";

      tffmt = "terraform fmt -recursive";

      # -------------------------------------------------
      # Nix
      # -------------------------------------------------

      ns = "nix shell";
      nd = "nix develop";

      nf = "nix flake";
      nfu = "nix flake update";

      nds = "sudo darwin-rebuild switch --flake ~/nix#${hostname}";
      ndb = "darwin-rebuild build --flake ~/nix#${hostname}";

      hms = "home-manager switch";
      hmb = "home-manager build";

      nix-clean = "nix-collect-garbage -d";

      # -------------------------------------------------
      # Networking / Observability
      # -------------------------------------------------

      ports = "lsof -i -P -n";

      pingg = "gping";

      sniff = "sudo tcpdump -i any";

      bw = "bandwhich";
      nettop = "btop";

      speed = "iperf3";

      scan = "nmap -sV";

      rustscan-fast = "rustscan -a";

      who = "whois";

      tlscheck = "openssl s_client -connect";

      semscan = "semgrep scan";

      trivyfs = "trivy fs .";

      # -------------------------------------------------
      # HTTP / APIs
      # -------------------------------------------------

      http = "xh";
      api = "atac";

      # pretty json
      json = "jq";
      jqp = "jqp";

      # -------------------------------------------------
      # Productivity
      # -------------------------------------------------

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

      # -------------------------------------------------
      # Search / files
      # -------------------------------------------------

      fzf-preview = "fzf --preview 'bat --style=numbers --color=always {}'";

      rgf = "rg --files | fzf";

      # -------------------------------------------------
      # Media
      # -------------------------------------------------

      ytdl = "yt-dlp";
      mp = "mpv";

      # -------------------------------------------------
      # AI
      # -------------------------------------------------

      ai = "aichat";
      fabric = "fabric";
      op = "opencode";
      cc = "claude-code";

      # -------------------------------------------------
      # Benchmarks / profiling
      # -------------------------------------------------

      bench = "hyperfine";

      # -------------------------------------------------
      # JSON / YAML
      # -------------------------------------------------

      yaml2json = "yq -o=json";
      json2yaml = "yq -P";

      # -------------------------------------------------
      # Misc
      # -------------------------------------------------

      reload = "source ~/.zshrc";
    };
    initContent = ''
      eval "$(starship init zsh)"
    '';
  };

  programs.git = {
    enable = true;
    settings = {
      init.defaultBranch = "main";
      # pull.rebase = false;
      push.autoSetupRemote = true;
    };
  };

  programs.direnv = {
    enable = true;
    package = pkgs.direnv.overrideAttrs (_: {
      doCheck = false;
    });
    nix-direnv.enable = true;
    silent = true;
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = lib.mkDefault { };
  };

  programs.neovim.enable = true;

  services.colima = {
    enable = true;

    profiles.default = {
      isService = true;
      isActive = true;
      setDockerHost = false;

      settings = {
        cpu = lib.mkDefault 4;
        memory = lib.mkDefault 8;
        disk = lib.mkDefault 100;

        vmType = "vz";
        mountType = "virtiofs";
        mountInotify = true;

        network.address = true;
        forwardAgent = true;

        runtime = "docker";
      };
    };
  };
}
