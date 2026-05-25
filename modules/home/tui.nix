{ config, lib, ... }:
let
  cfg = config.mySystem.home.tui;
  mkSubgroup =
    description:
    lib.mkOption {
      type = lib.types.bool;
      default = cfg.enable;
      defaultText = lib.literalExpression "config.mySystem.home.tui.enable";
      description = "${description}. Defaults to mySystem.home.tui.enable.";
      example = false;
    };
in
{
  options.mySystem.home.tui = {
    enable = lib.mkEnableOption "TUI and shell utility programs (master switch)";

    shell.enable = mkSubgroup "Interactive shell augmentations (atuin, zoxide, carapace, ...)";
    files.enable = mkSubgroup "File navigation and search (yazi, broot, fd, ripgrep, ...)";
    viewers.enable = mkSubgroup "Content and system inspection (btop, jq, less, visidata, ...)";
    dev.enable = mkSubgroup "Development workflow (lazygit, tmux, gcc, ...)";
    productivity.enable = mkSubgroup "Workflow helpers (navi, tealdeer, television, ...)";
    media.enable = mkSubgroup "Audio and video (mpv, yt-dlp, rmpc, radio-active)";
    personal.enable = mkSubgroup "Opinionated personal picks (jrnl, zk, ttyper, ...)";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.shell.enable {
      programs.aliae.enable = true;
      programs.atuin.enable = true;
      programs.carapace.enable = true;
      programs.hstr.enable = true;
      programs.intelli-shell.enable = true;
      programs.pay-respects.enable = true;
      programs.readline.enable = true;
      programs.zoxide.enable = true;
    })

    (lib.mkIf cfg.files.enable {
      programs.broot.enable = true;
      programs.fd.enable = true;
      programs.mc.enable = true;
      programs.ripgrep.enable = true;
      programs.ripgrep-all.enable = true;
      programs.superfile.enable = true;
      programs.xplr.enable = true;
      programs.yazi.enable = true;
    })

    (lib.mkIf cfg.viewers.enable {
      programs.btop.enable = true;
      programs.difftastic.enable = true;
      programs.fastfetch.enable = true;
      programs.hwatch.enable = true;
      programs.jq.enable = true;
      programs.jqp.enable = true;
      programs.less.enable = true;
      programs.man.enable = true;
      programs.visidata.enable = true;
    })

    (lib.mkIf cfg.dev.enable {
      programs.gcc.enable = true;
      programs.git-cliff.enable = true;
      programs.lazydocker.enable = true;
      programs.lazygit.enable = true;
      programs.tmate.enable = true;
      programs.tmux.enable = true;
    })

    (lib.mkIf cfg.productivity.enable {
      programs.aria2.enable = true;
      programs.navi.enable = true;
      programs.noti.enable = true;
      programs.parallel.enable = true;
      programs.pet.enable = true;
      programs.rclone.enable = true;
      programs.script-directory.enable = true;
      programs.tealdeer.enable = true;
      programs.television.enable = true;
    })

    (lib.mkIf cfg.media.enable {
      programs.mpv.enable = true;
      programs.radio-active.enable = true;
      programs.rmpc.enable = true;
      programs.yt-dlp.enable = true;
    })

    (lib.mkIf cfg.personal.enable {
      programs.chawan.enable = true;
      programs.clock-rs.enable = true;
      programs.jrnl.enable = true;
      programs.translate-shell.enable = true;
      programs.ttyper.enable = true;
      programs.zk.enable = true;
    })
  ];
}
