{ config, pkgs, lib, hostname, ... }:
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
    obsidian
    meetingbar
    # opencode
    # claude-code
    # antigravity
    postman
    notion-app
    code-cursor
    # vscode
    ghostty-bin
    # orbstack
  ];

  programs.home-manager.enable = true;

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

  # programs.fish = {
    # enable = true;
    # interactiveShellInit = ''
      # starship init fish | source
    # '';
  # };

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

  programs.fd.enable = true;
  programs.jq.enable = true;
  programs.jqp.enable = true;
  programs.bat.enable = true;
  programs.fzf.enable = true;
  programs.eza.enable = true;
  programs.ripgrep.enable = true;
  programs.btop.enable = true;
  programs.fastfetch.enable = true;
  programs.aerospace.enable = true;
  programs.dbeaver.enable = true;
  programs.freetube.enable = true;
  programs.brave.enable = true;
  programs.difftastic.enable = true;
  programs.atuin.enable = true;
  programs.aliae.enable = true;
  programs.broot.enable = true;
  programs.clock-rs.enable = true;
  programs.hstr.enable = true;
  programs.hwatch.enable = true;
  programs.infat.enable = true;
  programs.intelli-shell.enable = true;
  programs.joplin-desktop.enable = true;
  programs.less.enable = true;
  programs.man.enable = true;
  programs.mc.enable = true;
  programs.navi.enable = true;
  programs.numbat.enable = true;
  programs.pet.enable = true;
  programs.sioyek.enable = true;
  programs.sketchybar.enable = true;
  programs.superfile.enable = true;
  programs.tealdeer.enable = true;
  programs.television.enable = true;
  # programs.trippy.enable = true;
  programs.ttyper.enable = true;
  programs.yt-dlp.enable = true;
  programs.zoxide.enable = true;
  programs.lazygit.enable = true;
  programs.lazydocker.enable = true;
  programs.mpv.enable = true;
  programs.aria2.enable = true;
  programs.tmux.enable = true;
  programs.aichat.enable = true;
  programs.fabric-ai.enable = true;
  # programs.fresh-editor.enable = true;
  programs.noti.enable = true;
  programs.pay-respects.enable = true;
  programs.radio-active.enable = true;
  programs.rclone.enable = true;
  programs.readline.enable = true;
  programs.ripgrep-all.enable = true;
  programs.rmpc.enable = true;
  # programs.sesh.enable = true;
  # programs.aerc.enable = true;
  # programs.amber.enable = true;
  programs.carapace.enable = true;
  programs.chawan.enable = true;
  programs.gcc.enable = true;
  programs.git-cliff.enable = true;
  programs.jrnl.enable = true;
  programs.macchina.enable = true;
  programs.neovim.enable = true;
  programs.obsidian.enable = true;
  programs.parallel.enable = true;
  programs.script-directory.enable = true;
  #programs.streamlink.enable = true;
  programs.tmate.enable = true;
  programs.translate-shell.enable = true;
  programs.tirith.enable = true;
  programs.visidata.enable = true;
  programs.vscode.enable = true;
  programs.xplr.enable = true;
  programs.yazi.enable = true;
  # programs.zathura.enable = true;
  programs.zk.enable = true;
  programs.claude-code.enable = true;
  # programs.cursor.enable = true;
  programs.opencode.enable = true;



  #services
  services.colima = {
   enable = true;
  
   profiles.default = {
     isService = true;
     isActive = true;
     setDockerHost = false;

     settings = {
       cpu = 4;
       memory = 8;
       disk = 100;

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

# image viewer
# torrent
# browser
# music
# email
# clock
# calculator
