# karabiner: the OS-level keyboard remapper. The nix-darwin service
# (hosts/common/darwin.nix) installs the binary + daemons; this HM module
# owns the JSON config it reads on startup.
#
# Why fully-declarative JSON instead of the GUI?
#   Karabiner's GUI writes the same file we manage here. Two writers =
#   drift. Nix wins; GUI edits get clobbered on next switch. The whole
#   point of this rewrite is that the rules survive reinstalls.
#
# Rules wired below:
#   1. Caps Lock dual-role:
#        held + key  -> ⌃⌥⇧⌘ + key   (Hyper -- replaces Raycast's tap)
#        tapped alone -> Escape       (home-row Escape for vim/nvim)
#   2. Hyper + hjkl  -> arrow keys     (vim-style nav in every app)
#   3. Hyper + u/i   -> page up / down (scroll without leaving home row)
#   4. Hyper + y/o   -> home / end     (jump-to-line-edge)
#   5. Hyper + ⌫    -> forward delete (mac's missing fwd-delete key)
#   6. Both shifts together -> Caps Lock (recover the rare actual caps need)
#
# Aerospace lives one layer above: it sees Hyper-W as `cmd-ctrl-alt-shift-w`
# and enters wm-mode. Inside wm-mode, plain hjkl is bound by aerospace --
# do NOT hold caps while in wm-mode, or you'll emit hyper-h (= arrow left)
# and aerospace's plain-h binding won't fire.
{ lib, ... }:
let

  # Hyper-layer helper: emits `to` whenever the user presses `from` while
  # holding the full hyper modifier set. Side-agnostic (left/right shift
  # etc. both count) so a manual ⌃⌥⇧⌘ chord also works, not just caps.
  hyperKey = from: to: {
    type = "basic";
    from = {
      key_code = from;
      modifiers.mandatory = [
        "command"
        "control"
        "option"
        "shift"
      ];
    };
    to = [ { key_code = to; } ];
  };

  capsToHyper = {
    description = "Caps Lock -> Hyper when held, Escape when tapped";
    manipulators = [
      {
        type = "basic";
        from = {
          key_code = "caps_lock";
          modifiers.optional = [ "any" ];
        };
        to = [
          {
            key_code = "left_shift";
            modifiers = [
              "left_command"
              "left_control"
              "left_option"
            ];
          }
        ];
        to_if_alone = [
          {
            key_code = "escape";
            halt = true;
          }
        ];
      }
    ];
  };

  hyperNavigation = {
    description = "Hyper + hjkl -> arrows, u/i -> page up/down, y/o -> home/end";
    manipulators = [
      (hyperKey "h" "left_arrow")
      (hyperKey "j" "down_arrow")
      (hyperKey "k" "up_arrow")
      (hyperKey "l" "right_arrow")
      (hyperKey "u" "page_up")
      (hyperKey "i" "page_down")
      (hyperKey "y" "home")
      (hyperKey "o" "end")
    ];
  };

  hyperForwardDelete = {
    description = "Hyper + delete_or_backspace -> forward delete";
    manipulators = [ (hyperKey "delete_or_backspace" "delete_forward") ];
  };

  bothShiftsToCapsLock = {
    description = "Press both shifts together to toggle Caps Lock";
    manipulators = [
      {
        type = "basic";
        from = {
          key_code = "left_shift";
          modifiers.mandatory = [ "right_shift" ];
        };
        to = [ { key_code = "caps_lock"; } ];
      }
      {
        type = "basic";
        from = {
          key_code = "right_shift";
          modifiers.mandatory = [ "left_shift" ];
        };
        to = [ { key_code = "caps_lock"; } ];
      }
    ];
  };

  karabinerJson = {
    global = {
      check_for_updates_on_startup = false;
      show_in_menu_bar = true;
      show_profile_name_in_menu_bar = false;
    };
    profiles = [
      {
        name = "Default";
        selected = true;
        complex_modifications.rules = [
          capsToHyper
          hyperNavigation
          hyperForwardDelete
          bothShiftsToCapsLock
        ];
        virtual_hid_keyboard.keyboard_type_v2 = "ansi";
      }
    ];
  };
in
{
  xdg.configFile."karabiner/karabiner.json".text = builtins.toJSON karabinerJson;

  # Karabiner-Elements 15.x auto-saves timestamped backups under
  # ~/.config/karabiner/automatic_backups/ on every config write. Since
  # karabiner.json is owned declaratively here, those backups are useless
  # to us and accumulate unboundedly. Prune anything older than 30 days
  # on activation -- cheap find call, no-op when the dir is empty.
  home.activation.karabinerBackupGC = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    backup_dir="$HOME/.config/karabiner/automatic_backups"
    if [ -d "$backup_dir" ]; then
      find "$backup_dir" -type f -mtime +30 -delete 2>/dev/null || true
    fi
  '';
}
