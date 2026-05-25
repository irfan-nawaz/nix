# fastfetch: trim to modules that are actually informative on macOS;
# drop wallpaper/icon/cursor noise. Uses upstream JSONC schema.
{
  programs.fastfetch.settings = {
    "$schema" = "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json";
    logo = {
      type = "small";
      padding.right = 2;
    };
    display = {
      separator = "  ";
      color = "magenta";
    };
    modules = [
      "title"
      "separator"
      "os"
      "host"
      "kernel"
      "uptime"
      "packages"
      "shell"
      "terminal"
      "cpu"
      "gpu"
      "memory"
      "disk"
      "localip"
      "battery"
      "break"
      "colors"
    ];
  };
}
