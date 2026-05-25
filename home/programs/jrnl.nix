# jrnl: single default journal at ~/Documents/journal/. Multiple
# journals can be added later under `journals.<name>`.
{
  programs.jrnl.settings = {
    editor = "nvim";
    encrypt = false;
    template = false;
    default_hour = 9;
    default_minute = 0;
    timeformat = "%Y-%m-%d %H:%M";
    highlight = true;
    linewrap = 79;
    journals.default.journal = "~/Documents/journal/default.txt";
  };
}
