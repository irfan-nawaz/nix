# hammerspoon: macOS Lua scripting engine. The app is installed via
# homebrew cask (hosts/common/darwin.nix) so its bundle path stays
# stable across rebuilds -- macOS keys Accessibility / Notifications
# grants by bundle path, and a Nix-store path that changes every rebuild
# would force re-approval each time.
#
# This module owns ~/.hammerspoon/init.lua declaratively. No Spoons
# vendored. The leader pattern is hand-rolled with two hs.hotkey.modal
# instances (top-level + apps submode) -- one demo submode that doubles
# as the template for additional categories (system, web, tools, ...).
# Each new category = one more modal block in the same shape.
#
# Layer 1 (chord -> action) in the Karabiner -> Hammerspoon -> Aerospace
# -> tmux/sesh stack. See docs/productivity-stack.md for the canonical
# layer model -- updates to the diagram belong there.
#
# Reserved keys that Hammerspoon MUST NOT bind (Karabiner swallows them
# at the HID layer before Hammerspoon ever sees them):
#   h j k l u i y o   -- already translated to arrows / page / home / end
#   ⌫                -- already translated to forward delete
# Also: aerospace owns hyper+w. Don't bind 'w' as a leader-level key
# either, since hyper+w is consumed before Hammerspoon's bind fires.
#
# Permissions to grant once (first Hammerspoon launch after install):
#   System Settings > Privacy & Security > Accessibility -> Hammerspoon
#   System Settings > Privacy & Security > Notifications -> Hammerspoon
_: {
  home.file.".hammerspoon/init.lua".text = ''
    -- ─── Base settings ───────────────────────────────────────────────
    hs.window.animationDuration = 0   -- instant window ops, no easing
    hs.console.darkMode(true)         -- console matches the system theme
    hs.menuIcon(false)                -- keep menu bar clean; reach HS via leader or Spotlight

    local hyper = { "cmd", "ctrl", "alt", "shift" }

    -- ─── HUD helpers ─────────────────────────────────────────────────
    -- One alert at a time, tracked by UUID so we can swap it cleanly
    -- when transitioning between modal levels (leader -> submode).
    -- hs.alert.closeAll would clobber unrelated alerts, so we close
    -- only the HUD we own.
    local hudId = nil

    local function showHud(rows)
      if hudId then hs.alert.closeSpecific(hudId) end
      hudId = hs.alert.show(table.concat(rows, "\n"), {
        strokeColor  = { white = 1,    alpha = 0.2 },
        strokeWidth  = 1,
        fillColor    = { white = 0.05, alpha = 0.92 },
        textColor    = { hex = "#cdd6f4" },         -- Catppuccin Mocha text
        textFont     = "JetBrainsMono Nerd Font",
        textSize     = 14,
        radius       = 8,
        atScreenEdge = 2,                            -- 0=center 1=top 2=bottom
        padding      = 16,
      }, hs.screen.mainScreen(), 99)                 -- 99s = effectively persistent
    end

    local function hideHud()
      if hudId then hs.alert.closeSpecific(hudId); hudId = nil end
    end

    -- ─── APPS submode ────────────────────────────────────────────────
    -- Single source of truth for app bindings: an ORDERED list so the
    -- HUD renders in a predictable sequence. Adding an app = one row.
    -- `app` is the exact macOS application name (case-sensitive).
    local appBindings = {
      { key = "b", app = "Brave Browser", label = "brave"    },
      { key = "t", app = "Ghostty",       label = "ghostty"  },
      { key = "s", app = "Slack",         label = "slack"    },
      { key = "v", app = "Cursor",        label = "cursor"   },
      { key = "n", app = "Obsidian",      label = "obsidian" },
      { key = "f", app = "Finder",        label = "finder"   },
      { key = "m", app = "MeetingBar",    label = "meeting"  },
    }

    local appsMode = hs.hotkey.modal.new()

    for _, b in ipairs(appBindings) do
      appsMode:bind({}, b.key, function()
        appsMode:exit()
        hs.application.launchOrFocus(b.app)
      end)
    end
    appsMode:bind({}, "escape", function() appsMode:exit() end)

    function appsMode:entered()
      local rows = { "LEADER › APPS" }
      for _, b in ipairs(appBindings) do
        table.insert(rows, string.format("  %s  %s", b.key, b.label))
      end
      table.insert(rows, "")
      table.insert(rows, "  esc  back")
      showHud(rows)
    end
    function appsMode:exited() hideHud() end

    -- ─── LEADER (top level) ──────────────────────────────────────────
    -- caps+space (= ⌃⌥⇧⌘+space after Karabiner) enters the leader.
    -- Unbound keys inside a modal are silently ignored -- you stay in
    -- the level until you fire something or press escape (matches
    -- vim-leader behavior).
    local leader = hs.hotkey.modal.new(hyper, "space")

    -- Submode entry: exit leader, enter child. The HUD swap is handled
    -- by the entered/exited callbacks on each modal.
    leader:bind({}, "a", function() leader:exit(); appsMode:enter() end)

    -- Meta keys at the leader level. `r` reloads Hammerspoon manually
    -- (pathwatcher does it automatically on file change but having an
    -- explicit key is handy mid-edit).
    leader:bind({}, "r", function() leader:exit(); hs.reload() end)
    leader:bind({}, "escape", function() leader:exit() end)

    function leader:entered()
      showHud({
        "LEADER",
        "  a  apps  +",
        "  r  reload-hs",
        "",
        "  esc  cancel",
      })
    end
    function leader:exited() hideHud() end

    -- ─── Auto-reload on Lua change ───────────────────────────────────
    -- darwin-rebuild swaps the init.lua symlink target atomically; the
    -- watcher catches that and reloads. No manual ⌃⌥⌘R needed.
    hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", function(files)
      for _, file in pairs(files) do
        if file:sub(-4) == ".lua" then
          hs.reload()
          return
        end
      end
    end):start()

    -- ─── Load confirmation ───────────────────────────────────────────
    -- Brief HUD so you know the config actually loaded after a reload.
    hs.alert.show("Hammerspoon reloaded", 1)
  '';
}
