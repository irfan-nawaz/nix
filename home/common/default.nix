{ config, pkgs, lib, ... }:
{
  home.stateVersion = "25.05";

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
    opencode
    claude-code
    # antigravity
    postman
    notion-app
    vscode
    ghostty-bin
    # orbstack
  ];

  programs.home-manager.enable = true;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
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
  programs.opencode.enable = true;
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
