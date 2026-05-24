{ config, lib, ... }:
let
  cfg = config.mySystem.home.tui;
in
{
  options.mySystem.home.tui.enable = lib.mkEnableOption "TUI and shell utility programs";

  config = lib.mkIf cfg.enable {
    programs.aliae.enable = true;
    programs.aria2.enable = true;
    programs.atuin.enable = true;
    programs.broot.enable = true;
    programs.btop.enable = true;
    programs.carapace.enable = true;
    programs.chawan.enable = true;
    programs.clock-rs.enable = true;
    programs.difftastic.enable = true;
    programs.fastfetch.enable = true;
    programs.fd.enable = true;
    programs.gcc.enable = true;
    programs.git-cliff.enable = true;
    programs.hstr.enable = true;
    programs.hwatch.enable = true;
    programs.intelli-shell.enable = true;
    programs.jq.enable = true;
    programs.jqp.enable = true;
    programs.jrnl.enable = true;
    programs.lazydocker.enable = true;
    programs.lazygit.enable = true;
    programs.less.enable = true;
    programs.man.enable = true;
    programs.mc.enable = true;
    programs.mpv.enable = true;
    programs.navi.enable = true;
    programs.noti.enable = true;
    programs.parallel.enable = true;
    programs.pay-respects.enable = true;
    programs.pet.enable = true;
    programs.radio-active.enable = true;
    programs.rclone.enable = true;
    programs.readline.enable = true;
    programs.ripgrep.enable = true;
    programs.ripgrep-all.enable = true;
    programs.rmpc.enable = true;
    programs.script-directory.enable = true;
    programs.superfile.enable = true;
    programs.tealdeer.enable = true;
    programs.television.enable = true;
    programs.tmate.enable = true;
    programs.tmux.enable = true;
    programs.translate-shell.enable = true;
    programs.ttyper.enable = true;
    programs.visidata.enable = true;
    programs.xplr.enable = true;
    programs.yazi.enable = true;
    programs.yt-dlp.enable = true;
    programs.zk.enable = true;
    programs.zoxide.enable = true;
  };
}
