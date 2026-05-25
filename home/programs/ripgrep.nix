# ripgrep: smart-case + hide noise dirs by default. Custom types let
# you do `rg --type nix foo` etc.
{
  programs.ripgrep.arguments = [
    "--smart-case"
    "--hidden"
    "--glob=!.git/*"
    "--glob=!node_modules/*"
    "--glob=!.direnv/*"
    "--glob=!result"
    "--glob=!result-*"
    "--max-columns=180"
    "--max-columns-preview"
    "--colors=line:fg:yellow"
    "--colors=line:style:bold"
    "--colors=path:fg:green"
    "--colors=path:style:bold"
    "--colors=match:fg:black"
    "--colors=match:bg:yellow"
    "--type-add=nix:*.nix"
    "--type-add=lock:*.lock"
  ];
}
