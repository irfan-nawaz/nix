# chawan: TUI web browser. Default startpage points at the local
# bookmarks file; edit ~/.config/chawan/bookmarks.html to populate.
_: {
  programs.chawan.settings = {
    start = {
      startup-script = "";
      headless = false;
      visual-home = "about:blank";
    };
    search.default = "https://duckduckgo.com/?q=%s";
    page = {
      target-charset = "utf-8";
      display-charset = "utf-8";
    };
  };
}
