{
  programs.lazygit.settings = {
    gui = {
      theme = {
        lightTheme = false;
        activeBorderColor = [
          "#bb9af7"
          "bold"
        ];
        inactiveBorderColor = [ "#3b4261" ];
        selectedLineBgColor = [ "#283457" ];
      };
      showFileTree = true;
      showCommandLog = false;
      showRandomTip = false;
      showBottomLine = true;
      nerdFontsVersion = "3";
    };
    git = {
      paging = {
        colorArg = "always";
        pager = "delta --dark --paging=never";
      };
      autoFetch = true;
      autoRefresh = true;
      fetchAll = true;
    };
    update.method = "never";
    confirmOnQuit = false;
    disableStartupPopups = true;
  };
}
