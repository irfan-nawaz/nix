# btop settings via HM module. The theme name corresponds to a file
# shipped in btop's themes/ dir; tokyo-night is included upstream.
{
  programs.btop.settings = {
    color_theme = "tokyo-night";
    theme_background = false;
    truecolor = true;
    vim_keys = true;
    rounded_corners = true;
    graph_symbol = "braille";
    shown_boxes = "cpu mem net proc";
    update_ms = 1500;
    proc_sorting = "cpu lazy";
    proc_tree = false;
    proc_per_core = false;
    proc_mem_bytes = true;
  };
}
