# clock-rs: TUI clock. Run `clock-rs` to display.
{
  programs.clock-rs.settings = {
    general = {
      color = "magenta";
      interval = 250;
      blink = true;
      bold = true;
    };
    position = {
      horizontal = "center";
      vertical = "center";
    };
    date = {
      fmt = "%A, %B %d %Y";
      use_12h = false;
      utc = false;
      hide_seconds = false;
    };
  };
}
