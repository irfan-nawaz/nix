# jq: JSON processor. HM module only exposes `enable` + `colors`.
# Override the default palette to something readable on dark terminals.
_: {
  programs.jq.colors = {
    null = "1;30";
    false = "0;31";
    true = "0;32";
    numbers = "0;36";
    strings = "0;33";
    arrays = "1;35";
    objects = "1;34";
    objectKeys = "34;1";
  };
}
