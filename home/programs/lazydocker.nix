{
  programs.lazydocker.settings = {
    gui = {
      theme = {
        activeBorderColor = [
          "#bb9af7"
          "bold"
        ];
        inactiveBorderColor = [ "#3b4261" ];
        selectedLineBgColor = [ "#283457" ];
      };
      sidePanelWidth = 0.3333;
      showBottomLine = false;
    };
    update.method = "never";
    confirmOnQuit = false;
    stats.graphs = [
      {
        caption = "CPU (%)";
        statPath = ".CPUPercentage";
      }
      {
        caption = "Memory (%)";
        statPath = ".MemoryPercentage";
      }
    ];
  };
}
