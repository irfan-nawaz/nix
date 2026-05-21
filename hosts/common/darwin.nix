{ config, pkgs, lib, username, ... }:
{

  nixpkgs.config.allowUnfree = true;

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = false;
      cleanup = "zap";
      upgrade = false;
    };
    brews = [ "mas" ];
    casks = [ ];
    masApps = { };
  };

  system = {
    primaryUser = username;
    stateVersion = 6;
    defaults = {
     dock = {
      autohide = true;
     };
     finder = {
      AppleShowAllExtensions = true;
     };
     NSGlobalDomain = {
      ApplePressAndHoldEnabled = false;
     };
   };
  };

  users.users.${username} = {
    home = "/Users/${username}";
    # shell = pkgs.fish;
    shell = pkgs.zsh;
  };

  sops = {
    defaultSopsFile = ./../../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "/Users/${username}/.config/sops/age/keys.txt";
    validateSopsFiles = true;
    secrets = {
      github_geekyants_ssh_key = {
        path = "/Users/${username}/.ssh/id_ed25519_github_geekyants";
        mode = "0600";
        owner = username;
      };
      github_personal_ssh_key = {
        path = "/Users/${username}/.ssh/id_ed25519_github_personal";
        mode = "0600";
        owner = username;
      };
      gitlab_geekyants_ssh_key = {
        path = "/Users/${username}/.ssh/id_ed25519_gitlab_geekyants";
        mode = "0600";
        owner = username;
      };
      gitlab_tzero_ssh_key = {
        path = "/Users/${username}/.ssh/id_ed25519_gitlab_tzero";
        mode = "0600";
        owner = username;
      };
    };
  };

  nix = {
    enable = false;
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "root" "@admin" username ];
      warn-dirty = false;
    };
    # Disabled below by commenting because Nix is managed by Determinate Nix (nix.enable = false),
    # so NixOS options like `nix.gc` and `nix.optimise` will result in error as they reqire nix and we are using Determinate Nix.
    # optimise.automatic = true;
    gc = {
      # automatic = true;
      # interval = { Weekday = 0; Hour = 3; Minute = 15; };
      # options = "--delete-older-than 14d";
    };
  };

  # programs.fish.enable = true;
  # programs.zsh.enable = true;



  environment.systemPackages = with pkgs; [

    # dashboards
    macmon # System performance - Sudoless performance monitoring for Apple Silicon processors - T.W.
    zenith # System performance - dashboard with zoom-able charts, network, and disk usage (top alternate) - T.W.
    # btop # System performance - simple and fast being managed by home manager 
    # glances # System performance
    wtfutil # Personal information dashboard for your terminal - T.W.

    # Core system utilities
    vim # This is to replace the natively installed vim which has some restrictions. - T.W.
    curl # Cli for for transferring files with URL syntax over various protocols (FTP, HTTPS, IMAP). - T.W.
    wget # Cli for retrieving files using HTTP, HTTPS, and FTP.  - T.W.
    gnupg # GNU Privacy Guard, a GPL OpenPGP implementation.
    gawk # GNU implementation of the Awk programming language
    gnused # Sed (stream editor) is a non-interactive command-line text editor.
    sd # Modern sed alternative.
    procs # Modern replacement for ps written in Rust
    gnutar # GNU impementation of tar archiver
    unzip # Extraction utility for archives compressed in .zip format
    p7zip # Yet another archiver for 7z, TAR, GZIP
    lsof # Command to list open files
    coreutils # GNU Core Utilities (group of commands like ls, rm, mv etc...)
    hyperfine # Command-line benchmarking tool

    # file managers
    # xplr
    # superfile
    # yazi
    # ranger
    # fzf # this is minimal and quick and being alredy managed via home manager

    # tree / navigation tools
    tree # Command to produce a depth indented directory listing.
    tre-command # Command to produce a depth indented directory listing.
    broot # Command to produce a depth indented directory listing.


    # Disk usage
    gdu # TUI
    dust # CLI for quick glance

    # CLI Personal Knowledge Management (CLI-PKM)
    # zk
    nb

    # Networking / diagnostics
    inetutils # Collection of common network programs.
    netcat # Command-line tool known as the "Swiss Army Knife" of networking used to read/write data across TCP or UDP connections.
    mtr # Real-time network analysis combining traceroute and ping into one.
    nmap # Command-line tool for network discovery, to find open ports, identify active devices, and detect operating systems.
    zenmap # Tgui for nmap
    tcpdump # Command-line tool to capture, inspect, and troubleshoot network traffic in real-time.
    wireshark # GUI app for network monitoring and network protocol analysis.
    termshark # The command-line version of Wireshark
    iperf3 # Command-line tool to measure maximum network throughput (bandwidth) between two devices on a network.
    whois # Command-line tool for domain registration lookup to find who registered a domain, when it was registered, and when it expires.
    bandwhich # Command-line utility used for monitoring network bandwidth utilization in real-time by process, connection, or remote IP address.
    bmon # Command-line utility to monitor network bandwidth in real-time, how much data is being received (RX) and transmitted (TX) across your network interfaces.
    sniffnet # GUI analyze your internet traffic in real-time ans visualize data flows, identify which applications are using bandwidth.
    iftop # Command-line monitor network bandwidth usage on a specific interface in real-time
    mdns-scanner # scan a network and create a list of IPs and associated hostnames, including mDNS hostnames and other aliases
    arp-scan # Command-line utility used to discover live devices (hosts) on your local network (LAN) 
    masscan # Masscan is a high-speed, asynchronous TCP port scanner designed to scan the entire internet or large networks
    # aircrack-ng
    # bettercap
    trippy # Network diagnostic tool, that combines the functionality of traceroute and ping into a single, interactive terminal user interface.
    dstp # command-line tool (CLI) for macOS used to run networking tests—such as DNS resolution, ping, and HTTPS/TLS checks—against a website or IP address.
    nload # command-line tool used to monitor network traffic and bandwidth usage in real-time.
    cariddi # Command-line utility to quickly scan websites for hidden endpoints, sensitive information, API keys, and potential vulnerabiliti.
    rustscan # ultra-fast, modern port scanner used for (network scanning) to identify open ports in seconds.
    httpie # Command line HTTP client whose goal is to make CLI human-friendly
    xh # Friendly and fast tool for sending HTTP requests
    ngrok # Allows you to expose a web server running on your local machine to the internet

    # Tunnels / Proxies
    cloudflared
    tailscale

    # core productivity utilities
    peaclock # Clock, timer, and stopwatch for the terminal
    carl # Calander
    hours # Command-line time tracking tool
    timewarrior # Command-line time tracker
    tasktimer # A dead simple TUI task timer
    tz # timezone
    basilk # TUI to manage your tasks with minimal kanban logic
    taskbook # CLI tool to organize tasks & notes to boards
    taskwarrior3 # Flexible command-line tool to manage TODO lists
    taskwarrior-tui # Terminal user interface for taskwarrior
    dijo # CLI digital habit tracker

    # system observability and logging
    lnav # Commandline logfile navigator

    # Secrets & security
    sops
    age # Modern encryption tool with small explicit keys
    ssh-to-age
    pass # Stores, retrieves, generates, and synchronizes passwords securely

    # Downloads & transfer
    # aria2
    rsync
    rclone

    # remote access
    openssh
    mosh

    # Build tools & automation
    entr
    just
    gnumake
    watchexec
    go-task

    # binary inspection / debugging / tracing (macOS)
    # otool # availabe natively (pre-installed) on macOS
    # dtruss # availabe natively (pre-installed) on macOS
    # sysdiagnose # availabe natively (pre-installed) on macOS
    # fs_usage  # availabe natively (pre-installed) on macOS

    # Infrastructure as Code (IaC)
    terraform
    terragrunt
    pulumi
    # opentofu
    # packer

    # supporting tools for IaC
    terraform-docs
    terraform-ls
    tflint
    # checkov
    # tfsec

    # Kubernetes & Container Orchestration
    # Core Kubernetes
    kubectl
    kubernetes-helm
    kustomize
    k9s
    kubectx
    # kubeswitch availabe in nix progreams and is an alterative to kubectx research and decide which one to use 
    stern
    # kubelogin
    # lens
    # kustomize-sops
    # helmfile

    # Local Kubernetes
    kind
    k3d
    # minikube

    #Debugging
    # Cluster Debugging
    kube-score
    # kubescape
    # popeye
    # kube-bench

    # Containers & OCI Tooling
    skopeo
    # buildah
    # nerdctl

    # Better Developer UX
    dive
    hadolint
    ctop

    # Image Registry / Security ---------------------------------------------------------------> check configs from here.
    trivy
    syft
    semgrep
    gitleaks
    mkcert
    cosign
    oras
    #grype

    # GitOps
    argocd
    fluxcd

    # Cloud Provider CLIs
    awscli2
    # google-cloud-sdk
    # azure-cli

    # Kubernetes Cloud Auth
    eksctl
    # aws-iam-authenticator
    # google-cloud-sdk-gce
    # azure-kubelogin

    # Serverless
    aws-sam-cli
    # firebase-tools

    # Secrets & Identity Management
    _1password-cli
    doppler
    # vault
    # infisical

    #Databases
    # pgcli
    usql
    sqlite


    # dev-heavy laptop
    ffmpeg
    smassh
    sampler

    # Optional / situational
    chafa       # terminal image viewer (only if you use it here)
    figurine    # aesthetic CLI

    # music
    # cider-2

    # Core productivity / dev utilities
    tldr
    delta
    pik
    caffeine
    flameshot
    nixfmt

    # terminal / UI / interactive layer
    television
    cmatrix
    choose
    skim
    gum
    dialog

    # search / data exploration / viewing
    fx
    csvlens
    glow
    harlequin
    rainfrog
    sq
    slumber

    # documentation / writing / slides / knowledge
    slides
    runme
    presenterm
    tui-journal
    #obsidian or notion cli aternative

    # download / sync / transfer
    #download manager
    #bittorrent client
    magic-wormhole

    # text processing / dev inspection
    silicon
    onefetch

    # terminal history / system / system info
    #terminal histroy
    cpufetch
    ghfetch

    # API / request tools (postman-like)
    atac

    # AI tools
    yai
    pi-coding-agent

    # terminal recording / sharing
    asciinema
    t-rec

    #bookmarks
    bmm

    #postman like
    atac

    #terminal record
    asciinema
    t-rec

    #journal
    tui-journal

  
    # discordo
    # nchat
    # gpg-tui
    # wtf

  ];

  networking.computerName = lib.mkDefault "${username}-mac";

  security.pam.services.sudo_local.touchIdAuth = true;

}
