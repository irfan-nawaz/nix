# presenterm: markdown slide presenter in the terminal. No HM module on
# this channel -- drop the YAML config directly into XDG.
_: {
  xdg.configFile."presenterm/config.yaml".text = ''
    defaults:
      theme: dark
    typst:
      ppi: 300
    mermaid:
      scale: 2
    options:
      implicit_slide_ends: true
      end_slide_shorthand: true
      strict_front_matter_parsing: false
    bindings:
      next: ["l", "<right>", "<page_down>", "<space>"]
      previous: ["h", "<left>", "<page_up>"]
      first_slide: ["gg"]
      last_slide: ["G"]
      execute_code: ["<c-e>"]
      reload: ["<c-r>"]
      exit: ["q", "<esc>"]
  '';
}
