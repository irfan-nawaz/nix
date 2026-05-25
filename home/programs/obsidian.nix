# obsidian: PKM with local-first markdown vaults. HM module exposes
# `vaults` (declarative vault list + plugin pinning), but the user data
# inside a vault is personal -- managed via Git or Obsidian Sync, not
# declared here.
#
# TODO: when you settle on a vault layout, uncomment + point at the
# real paths (e.g. ~/Documents/Vaults/main).
_: {
  # programs.obsidian = {
  #   defaultSettings = {
  #     core.pluginConfig = {
  #       "templates"        = true;
  #       "daily-notes"      = true;
  #       "page-preview"     = true;
  #       "graph"            = true;
  #     };
  #   };
  #   vaults = {
  #     main = {
  #       enable = true;
  #       target = "Documents/Vaults/main";
  #       settings.appearance.theme = "obsidian";
  #     };
  #   };
  # };
}
