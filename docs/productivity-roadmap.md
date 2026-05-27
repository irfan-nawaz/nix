# Productivity Stack — Roadmap

Companion to [`productivity-stack.md`](./productivity-stack.md). That doc
explains how today's stack works; this one captures everything **discussed
but not yet shipped**, with enough detail to pick up cold weeks later and
implement without re-deriving the design.

Three sections:
1. [What was just shipped](#1-what-was-just-shipped) — short reference
2. [Pending features](#2-pending-features) — ready-to-implement designs
3. [Decisions banked](#3-decisions-banked) — paths we deliberately rejected,
   so we don't re-litigate later

---

## 1. What was just shipped

| Change | File | One-line summary |
|---|---|---|
| Sketchybar clock fix | `home/programs/sketchybar.nix` | Script must call `sketchybar --set` itself — stdout is not auto-captured as label |
| Sketchybar timew elapsed fix | `home/programs/sketchybar.nix` | timew now emits ISO-extended local time (`2026-05-26T23:44:45`), not ISO-basic UTC; parser updated; `tag.N` → `tags.N` (deprecated DOM) |
| Sketchybar front-app indicator | `home/programs/sketchybar.nix` | New `front_app` item on the left; subscribes to native `front_app_switched` event, near-zero overhead |
| Aerospace auto-routing | `home/programs/aerospace.nix` | `on-window-detected` rules send each app to its semantic workspace (terminal→1, editor→2, browser→3, …) |
| Ghostty scratchpad | `home/programs/ghostty/config` | Native `toggle_quick_terminal`, bound to hyper+`` ` `` — sits above aerospace's tiling |

**Caveat for the Ghostty scratchpad:** ctrl+backtick collapses to `^@`
(byte 0x00) which is IntelliShell's default search key. If Ghostty's global
hotkey ever fails to grab the chord (missing Accessibility permission,
Ghostty not restarted after config change), the chord falls through to the
shell and IntelliShell pops up instead. Fix: quit & relaunch Ghostty, then
grant Accessibility permission when macOS prompts. After that the OS layer
catches it before the shell ever sees it.

---

## 2. Pending features

Each feature here is "designed, ready to implement". Skim the trade-off,
decide if you still want it, then follow the implementation block.

---

### 2.1 Per-project sesh sessions (project bootstrap automation)

**Goal.** `prefix s` → "tzero-portal" → full IDE in one keystroke: nvim in
window 0, a scratch shell in window 1 for `pnpm dev:web` / tests.

**Pattern chosen.** Industry-standard 2025 convention for nvim + tmux + sesh
users: **session = project, ONE editor window, second window for runtime,
all other tools (claude, lazygit, terminal) invoked from inside nvim via
plugins.**

Why this over the older "one tmux window per tool" pattern:
- `lazygit.nvim` opens lazygit in a floating window inside the editor;
  returns you to the cursor on quit. Tighter than `prefix 2`.
- `snacks.nvim` / `toggleterm.nvim` give on-demand terminal splits — no
  need to pre-spawn shells you might use.
- `claude-code.nvim` (or similar) lets you yank between Claude buffer and
  source code without leaving the editor.

The old "tools as dedicated tmux windows" pattern is being phased out by
LazyVim, ThePrimeagen, AstroNvim, and most popular distros.

**Prerequisite.** Confirm your nvim config has (or add):
- A git plugin: `lazygit.nvim` or `neogit`
- A terminal manager: `snacks.nvim` (built-in terminal), `toggleterm.nvim`,
  or just rely on `:term`

If those aren't installed yet, the fallback is the 4-window-per-tool layout
(see section 2.1.b).

**Implementation — architecture change in `home/programs/sesh.nix`.**

The current `sessions` schema only supports a single `command` field per
session, dispatched via `respawn-pane -k`. To support multi-window layouts,
add a new `layout` field that runs raw tmux commands:

```nix
# Add a branch in toCase:
toCase = name: s:
  if s ? layout then ''
      ${name})
${s.layout}      ;;''
  else if s ? command then
    "  ${name}) exec tmux respawn-pane -k -t \"$name\" ${lib.escapeShellArg s.command} ;;"
  else "";
```

Then add the session entry:

```nix
tzero-portal = {
  path = "~/cp/tzero-x-unified-portal-ui";
  layout = ''
    tmux rename-window     -t "$name:0"  edit
    tmux respawn-pane  -k  -t "$name:0"  nvim
    tmux new-window        -t "$name:"   -n run -c "#{pane_current_path}"
    tmux select-window     -t "$name:0"
  '';
};
```

**Why `layout` bypasses sesh's startup_command race fix.** We're using raw
tmux commands (no `send-keys`), so the eval-based zsh plugin race that
motivated the hook-based dispatch doesn't apply. We're respawning the pane
directly and creating new windows with their command baked in via
`new-window`'s positional argument.

**Trade-off.** Each new project needs its own entry. The mechanism only
pays off for projects you open daily/weekly. Ad-hoc throwaway projects
should use plain `prefix s` → "main".

#### 2.1.b Fallback: 4-window-per-tool layout

Use this if you don't have lazygit.nvim / terminal-manager plugins yet:

```nix
tzero-portal = {
  path = "~/cp/tzero-x-unified-portal-ui";
  layout = ''
    tmux rename-window     -t "$name:0"  edit
    tmux respawn-pane  -k  -t "$name:0"  nvim
    tmux new-window        -t "$name:"   -n claude  -c "#{pane_current_path}" claude
    tmux new-window        -t "$name:"   -n git     -c "#{pane_current_path}" lazygit
    tmux new-window        -t "$name:"   -n run     -c "#{pane_current_path}"
    tmux select-window     -t "$name:0"
  '';
};
```

Switch tools with `prefix 0..3`. Heavier but works without nvim plugins.

---

### 2.2 Notifications + reminders stack

**Goal.** Daily check-in / check-out reminders, pomodoro complete banners,
nudge when no timer has run for 20 min, warn when active timer exceeds 2 h,
overdue task alert, daily review reminder.

**Tooling decision (battle-tested components, custom glue).**

| Need | Tool | Why |
|---|---|---|
| Pomodoro | `uair` (in nixpkgs) | Most popular CLI pomodoro in the dotfiles community; hooks on stage transitions; integrates cleanly with timew |
| macOS banners | `terminal-notifier` | De-facto Homebrew/Nix notification CLI since 2012 |
| Scheduler | launchd | Apple-native; this IS the standard on macOS |

**Trade-off in one line.** The 5 glue scripts are bespoke; the components
(uair, terminal-notifier, launchd, timew, task) are individually
battle-tested and replaceable. No all-in-one tool exists because the
timew↔task↔notification integration is inherently personal.

**Architecture.** One new module `home/programs/notifications.nix`:

```
home/programs/notifications.nix
├── home.packages         → uair, terminal-notifier
├── launchd.agents.*      → 6 scheduled jobs (HM-managed → ~/Library/LaunchAgents)
└── xdg.configFile."uair/uair.toml"  → pomodoro stage definitions + hooks
```

**Agents to declare.**

| Agent | Schedule | Trigger condition |
|---|---|---|
| `checkin` | M–F 9:30 am IST | unconditional: `notify "Start the day — check in"` |
| `checkout` | M–F 6:00 pm IST | unconditional: `notify "Wrap up — check out"` |
| `daily-review` | M–F 5:30 pm IST | `notify "Review today: $(task +PENDING count) open"` |
| `task-overdue` | hourly, work hours | `task +OVERDUE count > 0` → banner with count |
| `idle-nudge` | every 5 min, work hours | `timew dom.active != 1` for ≥20 min → "no timer running" (debounce: don't re-fire within 30 min of last fire) |
| `long-task` | every 10 min | `timew dom.active = 1` AND elapsed > 2 h → fire once per interval (key debounce on `dom.active.start` so it doesn't repeat after stopping/restarting) |

Debounce state lives in `~/.local/state/notifications/<agent>.last` —
each script `touch`es its file when it fires and compares mtime before
re-firing.

**Uair config sketch** (`~/.config/uair/uair.toml`):

```toml
loop_on_end = false

[[sessions]]
id = "work"
name = "Work"
duration = "25m"
command = "terminal-notifier -title 'Pomodoro' -message 'Break time'"
autostart = false
before_command = "timew start pomo"
after_command  = "timew stop"

[[sessions]]
id = "break"
name = "Break"
duration = "5m"
command = "terminal-notifier -title 'Pomodoro' -message 'Back to work'"
```

Then `uair` starts the loop; `uairctl pause` / `uairctl resume` for
interrupts; `uairctl fetch '{percent}'` for sketchybar integration if you
want a pomodoro pill on the bar later.

**Open questions to answer before implementing.**

1. **Work-hours window.** Assume Mon–Fri 9:30 am – 6:30 pm IST? Or
   different? Affects the launchd `StartCalendarInterval` blocks for
   `idle-nudge`, `task-overdue`, and the check-in/check-out fires.

2. **Pomodoro ↔ timew coupling.** Should `uair` auto-`timew start pomo`
   on a work session start and `timew stop` on session end (per the
   sketch above)? Pro: pomos show up in your timew history and on the
   sketchybar pill. Con: it overwrites any timew interval you started
   manually for a specific task.

3. **Meeting awareness (v1 or v2?).** Skip nudges during a Zoom / Teams /
   MS Meet call? Achievable by checking front-app via aerospace or
   parsing `lsappinfo` in each script. Adds complexity — recommend
   deferring to v2 unless meeting-time nudges become annoying in practice.

---

### 2.3 Raycast as command palette (configuration only — not Nix-managed)

**Status.** No code change to ship in this repo. Raycast settings aren't
declaratively manageable today (known HM gap). This is a **manual
Raycast configuration exercise** to do once.

**Goal.** Stop treating Raycast as "fancy app launcher"; start treating it
as a script runner with these four high-ROI additions:

1. **Script Commands wrapping taskwarrior** — `t add "X"`, `t start 4`,
   `t pending`. Driven from the palette instead of dropping into a
   terminal. Raycast → Extensions → Script Commands → New (bash/zsh).
2. **Clipboard history** — built-in. Raycast → Extensions → Clipboard
   History → enable. Replaces Maccy / Paste subscriptions.
3. **Quicklinks** for repo dashboards — `gh-pr` → opens your GitHub
   assigned-to-me PR list (`https://github.com/pulls/assigned`),
   `gl-tzero` → opens tzero GitLab board, etc.
4. **Snippets** — common boilerplate (commit prefixes, ssh host strings,
   sops invocations).

**Explicitly skip.** Raycast's window management — it'll fight aerospace.

---

## 3. Decisions banked

Paths we evaluated and rejected. Keeping the rationale so we don't
re-litigate next time someone (including future-us) suggests them.

| Proposal | Decision | Why |
|---|---|---|
| Named workspaces in aerospace (`code`, `web`, `chat` instead of `1..9`) | **Skip** | After ~1 week of muscle memory the cognitive translation cost evaporates. The cost is real and permanent: collides with `wm`-mode bindings (`h/j/k/l`/`f`), pills get noticeably wider, aerospace sorts string workspaces lexicographically (breaks `workspace-back-and-forth`). |
| `tmux-resurrect` / `tmux-continuum` | **Skip** | sesh already gives us *declarative* session definitions — that's strictly stronger than snapshot-based resurrection (survives project restructures, no command-replay surprises). Adding resurrect = two competing sources of truth. The right fix for "ad-hoc panes I never declared" is to add them to sesh. |
| Raycast window management | **Skip** | Aerospace already owns window management. Two managers fight for the same WM event taps; behavior becomes non-deterministic. |
| `remind` (BSD scheduler) | **Skip** | Duplicates what launchd already does cleanly on macOS, and adds a non-native DSL. launchd is the canonical answer on this OS. |
| `tmuxinator` for project bootstrap | **Skip** | sesh + the proposed `layout` extension does the same job with one tool instead of two. Same drift problem as tmux-resurrect — competing session-definition tools. |
| Hammerspoon for quake-style terminal | **Skip** | Ghostty has native `toggle_quick_terminal`. Native > Lua glue. |

---

## 4. Implementation order (suggested)

When you come back to build:

1. **Sesh per-project bootstrap** (1 file, ~15 lines) — highest daily-use
   leverage; pays off immediately.
2. **Raycast script commands** (no Nix change, ~30 min in Raycast UI) —
   independent of the rest, can be done anytime.
3. **Notifications + uair stack** (1 new Nix module, ~80 lines) — biggest
   batch; do this once you're sure about the three open questions in 2.2.

Nothing here blocks anything else — pick whichever has the most ROI for
your current workflow and ship it.

---

## 5. Further enhancements — evaluated

Comprehensive sweep across every layer of the stack. Each item is tagged
so you can prioritize at a glance:

- **[high]** — ship this; clear ROI for your workflow
- **[medium]** — ship if pain felt; nice but not transformative
- **[verify]** — you may already have it; check before adding
- **[skip]** — conflicts with current stack or over-budget

### 5.1 CLI augments (small Unix-y wins)

| Tool | Tag | Why |
|---|---|---|
| `git-absorb` | **[high]** | Auto-creates `fixup!` commits against the right historical commit. Massive for code-review iteration on long-running PRs. |
| `gh-dash` | **[high]** | TUI dashboard for assigned PRs/issues across your 3 GitHub identities. With your multi-account setup, single biggest forge-workflow win you don't yet have. |
| `mods` (Charm.sh) | **[high]** | Pipe-friendly LLM. `cat error.log \| mods "explain"`, `git diff \| mods "draft a commit message"`. Different shape than Claude Code; complements, not competes. |
| `mise` | **[medium]** | Per-project tool version manager. Direnv + nix-shell covers most cases; mise is standard for non-nix projects. Skip if you nixify everything. |
| `vhs` (Charm.sh) | **[medium]** | Declarative terminal recorder, `.tape` files → GIF/mp4. Useful for ADRs and showing teammates "how I do X". |
| `asciinema` | **[medium]** | Alt to vhs, web-shareable. Pick one. |
| `bandwhich`, `procs`, `dust` | **[verify]** | Modern alternatives to top/ps/du. Probably already in your TUI stack. |

### 5.2 Git & forge workflow

| Tool | Tag | Why |
|---|---|---|
| `gh-poi` (gh extension) | **[high]** | Delete merged local branches. Pairs naturally with multi-account workflow. |
| `pre-commit` framework | **[skip]** | lefthook (already used in tzero-portal) is faster and better. Don't run two. |
| `mergiraf` | **[medium]** | Structural merge driver, fewer conflicts on refactors. Newer; not yet ubiquitous. |
| `git-branchless` | **[skip]** | Powerful but heavy mental-model shift; only worth it if you do stacked PRs regularly. |
| `delta` | **[verify]** | Better diff renderer. Likely already in your git config. |

### 5.3 Nvim — biggest leverage area, you live here

| Tool | Tag | Why |
|---|---|---|
| `lazygit.nvim` + `snacks.nvim` | **[high]** | Prerequisite for the section 2.1 minimal-window sesh layout; without these you fall back to the 4-window layout. |
| `avante.nvim` / `codecompanion.nvim` | **[high]** | In-editor AI chat with code/selection context. Complement to Claude Code CLI: in-buffer chat with selection awareness. |
| `copilot.lua` / `codeium.nvim` | **[medium]** | Inline completions. Personal preference; some swear by them, some find them noisy. |
| `mason.nvim` + `mason-lspconfig` | **[verify]** | Auto-install LSPs/formatters. Probably already there. |
| `nvim-dap` + `nvim-dap-ui` | **[medium]** | Actual debugger (breakpoints/step). Real leverage for a Go/React monorepo; skip if grep-debug-fix is sufficient. |
| `flash.nvim` | **[high]** | Vim motions with treesitter awareness; replaces hop/leap/easymotion. Modern standard. |
| `oil.nvim` | **[medium]** | Directory-as-buffer. Many find it superior to netrw/neotree once tried. |

### 5.4 Window / desktop layer

| Item | Tag | Why |
|---|---|---|
| Aerospace floating-window rules | **[high]** | Auto-float small dialogs (1Password popup, file open dialogs, system prefs). Prevents tiling chaos. Pattern: `if.window-title` regex → `layout floating`. |
| Aerospace per-workspace gap settings | **[skip]** | Diminishing returns; gaps already look good. |
| Hammerspoon Spoon: `Caffeine` | **[medium]** | Toggle sleep-prevention from menu/hotkey. Useful for long builds/meetings. |
| Hammerspoon URL handler | **[medium]** | `hammerspoon://do-thing` URLs callable from Raycast scripts or Alfred-style chains. |

### 5.5 Sketchybar additions

| Item | Tag | Why |
|---|---|---|
| Aerospace mode indicator | **[high]** | Single pill showing `WM` when inside aerospace's wm-mode, blank otherwise. Eliminates "am I in normal mode or wm mode?" confusion. ~10 lines. |
| Pomodoro pill | **[high if 2.2 ships]** | When uair is installed, show `25:00 ▶` / `04:32 ●`. Trivial via `uairctl fetch`. |
| Calendar next-event pill | **[skip]** | meetingbar already does this as a separate menubar app; duplicating wastes space. |
| CPU/memory pills | **[skip]** | Permanent noise for occasional info. btop on-demand is better. |

### 5.6 Shell / prompt

| Tool | Tag | Why |
|---|---|---|
| `starship` | **[verify/medium]** | Declarative prompt config. If on powerlevel10k, starship is the modern community-preferred replacement. Either works. |
| `zoxide` | **[verify]** | Smart cd. Almost certainly already installed. |
| `atuin` sync | **[medium]** | You have atuin; consider self-hosted sync across machines if you have multiple. |

### 5.7 Notes / knowledge / AI

| Item | Tag | Why |
|---|---|---|
| `zk` daily-journal template | **[high]** | You have zk; adding a "daily note" template + alias gives frictionless Bullet-Journal-style daily logs. ~5 lines of zk config. |
| `glow` | **[verify]** | Markdown TUI viewer. Probably present. |
| Ollama | **[medium]** | Local LLMs for privacy-sensitive tasks. Skip unless you have offline/airgapped needs. |

### 5.8 Screenshots & recording

| Tool | Tag | Why |
|---|---|---|
| Shottr or CleanShot X | **[high]** | macOS native screenshot tool is anemic. Shottr is free; CleanShot is paid. Both blow native out of the water — scrolling capture, annotation, OCR, instant share. Pick one. |

### 5.9 Backup & sync

| Tool | Tag | Why |
|---|---|---|
| `restic` to B2/S3 | **[high]** | Time Machine is fine locally; restic adds offsite versioned backups. Combine with launchd nightly. Critical for sops-managed keys, ssh keys, unpushed code. |
| Syncthing | **[medium]** | Peer-to-peer file sync if you have a personal NAS or second machine. Skip for single-machine setup. |

### 5.10 Security

| Item | Tag | Why |
|---|---|---|
| GnuPG + yubikey for git signing | **[skip]** | Your verified SSH commit-signing setup is already industry-standard and arguably better. Don't add a parallel scheme. |
| `1password-cli` shell integration | **[verify]** | `op run --env-file=.env -- npm start` injects secrets without writing them to disk. You have `_1password-cli` in allowUnfree — verify the shell helper is enabled. |

### 5.11 Browser

| Item | Tag | Why |
|---|---|---|
| Vimium / Tridactyl | **[high]** | Vim keys in the browser. Massive ROI for keyboard-first workflow; among the highest single additions if not already installed. |

### 5.12 Meeting / focus automation

| Item | Tag | Why |
|---|---|---|
| macOS Focus mode triggered by calendar | **[high]** | Native macOS supports auto-enabling Focus during calendar events. Configure once in System Settings → Focus. Silences notification banners during meetings automatically. Solves question #3 from section 2.2 without writing code. |

### 5.13 Kubernetes (you have a k8s.nix module)

| Tool | Tag | Why |
|---|---|---|
| `k9s` | **[verify]** | Likely already there. THE k8s TUI. |
| `kubectx` + `kubens` | **[verify]** | Fast context/namespace switching. |
| `kubefwd` | **[medium]** | Bulk port-forward services to localhost; saves writing 10 individual `kubectl port-forward` lines. |

### 5.14 Deliberate non-adds (already covered or would conflict)

These are tracked here so future-you doesn't re-evaluate them from scratch:

- **Alternative window managers** (yabai, Raycast WM) — aerospace owns this layer
- **Alternative launchers** (Alfred, Spotlight Plus) — Raycast covers it
- **Alternative shells** (fish, nu) — zsh + your plugin stack is the polished path
- **tmux plugins beyond what you have** (tpm, resurrect, continuum) — sesh is your composition layer
- **Standalone pomodoro apps** (Be Focused, Forest) — uair will be canonical
- **Apple Notes / Bear / Notion as primary** — you have zk + Obsidian + Joplin already

### 5.15 Meta-recommendation

The stack is already top 1%. The next 5× isn't more tools — it's
**subtracting** unused ones and *deepening* what's there. Concretely:

- **Pick one notes tool** — zk OR Obsidian OR Joplin. Having all three
  guarantees you use none well.
- **Pick one journaling tool** — jrnl OR zk daily notes. Same logic.

Tool count beyond a threshold becomes maintenance debt that crowds out
actual work. Audit annually; delete what you haven't opened in 3 months.

---

## 6. Prioritized add-list (cherry-picked from section 5)

If you implement only the **[high]** items, this is the order I'd
recommend, top-down by leverage per hour of setup time:

1. **`gh-dash`** (one Nix package add + alias) — instant ROI on multi-account PR triage
2. **Vimium/Tridactyl** (one browser extension install) — keyboard-first browsing
3. **`flash.nvim`** (one nvim plugin) — better than any other motion plugin
4. **Aerospace mode indicator on sketchybar** (~10 lines) — eliminates a daily papercut
5. **`lazygit.nvim` + `snacks.nvim`** — unlocks the minimal-window sesh layout in 2.1
6. **macOS Focus auto-enable by calendar** (System Settings config, no code) — solves meeting-awareness for free
7. **Shottr / CleanShot X** (one cask) — daily screenshot tool upgrade
8. **`git-absorb`** (one package) — code-review iteration speedup
9. **Aerospace floating-window rules** (~5 lines per app) — quality-of-life
10. **`mods`** (one package + Anthropic key wiring) — terminal-native LLM piping
11. **`zk` daily journal template** (~5 lines) — frictionless daily logging
12. **`restic` offsite backups** (one Nix module + launchd) — disaster recovery
13. **`avante.nvim` or `codecompanion.nvim`** — in-editor AI chat
14. **Audit + delete unused tools** — biggest win is removing, not adding

---

## 7. Office-hours productivity — process, environment, self

Everything above optimizes the **tools** layer. This section covers the
two layers most engineers neglect: the **systems** layer (rituals, blocks,
discipline) and the **self** layer (sleep, energy, focus capacity).

> **Engineers optimize tools. Senior engineers optimize systems. Staff
> engineers optimize themselves.**

The tools layer is fully optimized in this repo. The next 5× is in
systems; the 10× after that is in self. They compound in that order —
you can't skip steps. A perfect Nix config with no sleep = a fast machine
running a tired brain.

Tag scheme is the same as section 5: **[high]** / **[medium]** /
**[verify]** / **[skip]**.

### 7.1 Daily rituals (no tools needed — just discipline)

| Practice | Tag | Why |
|---|---|---|
| Daily startup ritual (~5 min) | **[high]** | Open task list → pick top 3 → block calendar for them → start timer. Without this, mornings leak into Slack/email and the day stays reactive. |
| Daily shutdown ritual (~5 min) | **[high]** | Stop timer, dump unfinished thoughts as tasks, close non-essential tabs, mark `task end-of-day`. Prevents next-morning re-orientation tax. |
| Weekly review (Friday, ~30 min) | **[high]** | Review tasks done/missed, snapshot wins, plan next week's top 3. Single highest-leverage habit in any GTD-derived system. |
| 5-minute end-of-week retro | **[high]** | jrnl entry every Friday: "What worked? What didn't? One thing to try next week." Without this you repeat the same mistakes for years. |
| Quarterly stack audit | **[high]** | Every 3 months: list tools opened ≥1× in the quarter. Anything you didn't → remove. New additions otherwise crowd you out. |

### 7.2 Deep-work enforcement

| Item | Tag | Why |
|---|---|---|
| No-meeting blocks on calendar | **[high]** | Reserve 2× 2-hour blocks/day labeled "Focus" — declined by default. Meetings expand to fill available calendar; this is the only counter-pressure that works. |
| Batched comms windows | **[high]** | Slack/email checked 3× daily (10am, 1pm, 4pm), not continuously. Combine with macOS Focus auto-enabling during work blocks. |
| `Cold Turkey Blocker` (free) or **Freedom** (paid) | **[high]** | Site/app blocker with scheduled blocks. Stronger than self-control. The Pro version locks itself so you can't disable mid-block — that's the feature you're paying for. |
| `/etc/hosts` blocklist via launchd | **[medium]** | Free, Nix-native alternative — launchd writes `127.0.0.1 reddit.com` during work hours, removes it after. Less polished than Cold Turkey. |
| Phone in another room or Yondr pouch | **[high]** | No tool beats physical distance. The "I'll just check..." impulse needs friction. |

### 7.3 Health micro-habits (compound over months)

| Tool / Practice | Tag | Why |
|---|---|---|
| `Stretchly` or eye-break logic via uair | **[high]** | 20-20-20 rule (every 20 min, look 20ft away for 20s) prevents eye strain that drops afternoon productivity. uair can fire a 30-second mini-break every pomo cycle. |
| Hydration reminders via launchd or `Shimmer` | **[medium]** | Every 60–90 min: "drink water" banner. Dehydration silently kills focus. |
| Standing desk timer (if applicable) | **[medium]** | Alternate sit/stand every ~50 min via terminal-notifier banner. |
| F.lux or macOS Night Shift | **[verify]** | Blue-light reduction past sunset improves sleep → next-day productivity. |

### 7.4 Meeting hygiene

| Practice | Tag | Why |
|---|---|---|
| Decline meetings without agendas | **[high]** | Personal policy: reply "What's the agenda + desired outcome?" before accepting. Half the meetings collapse into Slack threads. |
| 30-min default, 15-min for sync | **[high]** | Google Calendar lets you set default duration. 60-min meetings expand to fill time; 15-min forces focus. |
| Walking 1:1s | **[medium]** | If your 1:1s are <30 min and topic-light, do them walking. AirPods + Slack huddle. Mental + physical refresh. |
| Recorded async updates | **[medium]** | For status meetings: record a 3-min Loom/Slack-clip update, post async. Eliminates the meeting entirely if no decisions are needed. |

### 7.5 Inbox & Slack discipline

| Practice | Tag | Why |
|---|---|---|
| Inbox-zero email with the 4D rule (Do/Defer/Delegate/Delete) | **[high]** | Process emails into actions; don't re-read them. Each re-read is wasted attention. |
| Slack notifications OFF by default | **[high]** | Only @mentions + keywords (your name, current project, on-call) ping. Everything else is pull, not push. |
| Slack DND scheduled for focus blocks | **[high]** | Native Slack supports recurring DND windows. Set 9:30am–11:30am and 2pm–4pm. |
| Scheduled-send for outbound | **[medium]** | Drafting Slack/email at 7am or 11pm? Schedule-send to 9am next workday. Trains team that off-hours replies aren't expected; sets the norm. |

### 7.6 Knowledge capture pipeline

| Item | Tag | Why |
|---|---|---|
| Meeting-notes template in zk | **[high]** | Every meeting → one zk note → action items extracted → become taskwarrior tasks via a script. Prevents "we agreed to X but I forgot". |
| `Readwise Reader` or `Omnivore` (free, OSS) | **[medium]** | Read-later + highlights pipeline. Highlights surface back via spaced repetition. Replaces the "I should read this later" tab graveyard. |
| PR/ADR discipline | **[high]** | Every non-trivial PR has a `## Why` section. Every architectural decision gets a 1-page ADR in `docs/adrs/`. Compounds for the next engineer (often you, 6 months later). |
| Prompt library in zk | **[medium]** | Save high-quality prompts that worked for Claude/Codex. `zk new --template prompt`. Treats prompts as code you can version, reuse, share. |

### 7.7 Energy management (the meta-level)

The highest-leverage layer nobody talks about:

| Practice | Tag | Why |
|---|---|---|
| Identify your peak 2 hours | **[high]** | Track energy in jrnl daily for 2 weeks. Most people have a clear 2-hour peak window (often 9–11 am, or post-coffee). Schedule deep work there; meetings elsewhere. |
| Sleep is the primary input | **[high]** | 7 hours of sleep > any productivity tool in this entire doc. Under 6h and no nvim plugin recovers what's lost. |
| Caffeine timing | **[medium]** | Last coffee ≥10 hours before bed (caffeine half-life ~5h). Most "can't focus in the afternoon" is poor sleep from late caffeine. |
| Exercise 4× / week | **[high]** | 20-min morning walk improves afternoon cognition more than any nootropic. Cheapest performance enhancer in existence. |

### 7.8 Top 5 habits to install (prioritized)

If you adopt nothing else from §7, do these five in order. Each
compounds; later ones don't work without the earlier ones:

1. **Sleep 7+ hours nightly** — non-negotiable, primary input to everything below
2. **Daily startup + shutdown ritual** (~10 min total) — bookends every day
3. **2× 2-hour no-meeting Focus blocks** on calendar — defended like sacred
4. **Slack/email batched 3× daily, DND otherwise** — the single most violated practice
5. **Weekly Friday review (30 min)** — keeps the system honest and improving

The tools in sections 1–6 amplify these habits. The habits work *without*
the tools. The tools without the habits don't.

### 7.9 Deliberate non-adds (process layer)

- **Time-tracking every minute** (RescueTime / Toggl always-on) — overhead exceeds insight for most engineers. Timew on intentional intervals is enough.
- **Productivity gamification apps** (Habitica, Forest constant) — novelty wears off; intrinsic motivation collapses afterwards.
- **Bullet Journal in physical notebook** — handsome, but breaks the zk/jrnl declarative loop. Pick one capture system.
- **Meditation apps as productivity tool** — meditation is great; framing it as a productivity hack undercuts the benefit. Do it for its own sake or skip.

---

## 8. Genuine remaining gaps vs community standard

After an honest sweep of the stack against the 2026 dotfiles-community
baseline, only **two tooling gaps** remain. These are NOT items I'd
add for breadth — they're items where the stack measurably lags the
mainstream senior-engineer pattern. Everything else is at or above
community standard.

### 8.1 In-editor AI agent integration

**The gap.** You have Claude Code as a CLI, but no in-editor AI surface
inside nvim. The 2026 community-standard pattern is **both**:

- **CLI agent** (Claude Code / Codex CLI) — for orchestration, multi-file
  edits, long-running tasks, file-system operations
- **In-editor agent** — for inline edits, "explain this function",
  "rename this across the file", refactor of a visual selection,
  conversational chat with the current buffer as context

These solve different problems; running both is the norm for senior
engineers in 2026, not a luxury.

**Recommended fill.**

| Tool | Why this one |
|---|---|
| **`avante.nvim`** | Cursor-style UX inside nvim. Inline diff suggestions, sidebar chat, visual-selection edit. Most popular in-editor AI plugin in the nvim community right now. |
| **alternative: `codecompanion.nvim`** | More minimal, less Cursor-mimicking. Pick if you find avante visually busy. |

Both support Anthropic as a provider — your existing Anthropic key wires
into either.

**Why not skip it.** "I already have Claude Code CLI" is the natural
objection. But context-switching to a terminal pane for "rename this
identifier across the file" is friction the in-editor plugin removes.
Senior engineers who use both report ~30% of edits stay in-editor and
~70% escalate to the CLI — different shapes of problem.

**Trade-off.** One more plugin to keep updated, and a second place that
needs your Anthropic credentials. The friction reduction on small edits
is worth it.

### 8.2 Self-observability — knowing where your time actually goes

**The gap.** You track time (timew) and tasks (task) but have no
**aggregate view**. "This week I shipped 4 PRs, spent 18h coding, 6h
in meetings, 2h on project X" — that report doesn't exist anywhere
in the current stack. You have the *inputs*; you don't have the
*reflection layer*.

Industry-standard pattern for senior+ engineers in 2026: **data-driven
introspection on where time actually goes**, reviewed weekly.
Without it, the weekly review (§7.1) is anecdotal — "I think I spent
a lot of time on X" — which is reliably wrong.

**Two fill options, pick one:**

| Option | Trade-off |
|---|---|
| **`arbtt`** (Haskell, in nixpkgs) | Automatic — captures window titles + active app every minute, queries via a rule DSL. Battle-tested since ~2009, used by serious time-trackers for years. Drawback: passive collection feels surveillance-y to some; the rule DSL has a learning curve. |
| **Scripted weekly report from timew + task** | Manual — a `weekly-report` shell script aggregates `timew summary :week :ids` and `task end:today-7d completed count` into a markdown report saved to zk. Cheaper, integrates with existing tools, but only as accurate as your timew discipline. |

The scripted option is the better starting point because it builds on
data you already capture; arbtt is the upgrade if you discover your
manual timew tracking has too many gaps to be useful.

**Sketch of the weekly-report script** (lives next to the notifications
module when 2.2 ships):

```bash
#!/usr/bin/env bash
# weekly-report: aggregate timew + task into a zk note
WEEK_START=$(date -j -v-7d '+%Y-%m-%d')
TODAY=$(date '+%Y-%m-%d')

{
  echo "# Weekly report — $WEEK_START → $TODAY"
  echo
  echo "## Time tracked"
  timew summary :week
  echo
  echo "## Tasks completed"
  task end.after:$WEEK_START status:completed export | jq -r '.[] | "- \(.description)"'
  echo
  echo "## Tasks still pending (top by urgency)"
  task +PENDING limit:10
} > "$HOME/Documents/zk/weekly/$TODAY.md"

terminal-notifier -title "Weekly report ready" \
                  -message "Review at zk/weekly/$TODAY.md"
```

Wired to a launchd agent firing every Friday 5:00pm, this becomes part
of your shutdown ritual.

**Trade-off in one line.** You give up ~5 minutes weekly to read the
report; you gain a feedback loop on where attention actually goes —
which is the input the weekly review needs to be useful.

### 8.3 Everything else: at or above community standard

So the answer to "are we fully covered on tooling and CLI vs community
standards?" is: **yes, with the two gaps in 8.1 and 8.2 as the only
honest exceptions** *for the dev-workflow surface*. The terminal-first
daily-app surface (music / mail / calendar / news / chat) is covered
separately in §9 below.

Beyond §8 and §9, the diminishing-returns curve gets very steep —
additional tools will add marginal value at growing maintenance cost.

---

## 9. Terminal-first daily workflow apps

If your daily workflow lives in the terminal (music, mail, calendar,
news, chat all driven from a TUI), the 2026 community-standard picks
are below. Tag scheme matches earlier sections.

### 9.1 Picks per category

| Category | Pick | Tag | Why this one |
|---|---|---|---|
| **Music** | `spotify_player` (Rust) | **[high]** if Spotify Premium user | Successor to the dead `spotify-tui`. Active development, official Spotify API, vim keys, integrates with sketchybar via its IPC for a "now playing" pill if wanted. |
| **Calendar** | `khal` + `vdirsyncer` | **[high]** | CalDAV sync (Google, iCloud, FastMail). Battle-tested ~10 years. Pair with `khalel` if you want nvim-side integration. Alt: `gcalcli` for a simpler Google-only path. |
| **Mail** | `aerc` | **[high]** | Modern Go-based mail TUI; the 2025–2026 community recommendation over neomutt. Built-in IMAP/SMTP, threaded view, embedded editor, HTML render via w3m. |
| **RSS / news** | `newsboat` | **[medium]** | Canonical for a decade. No real alternative. Worth it only if you actually subscribe to feeds. |
| **File manager** | `yazi` (Rust) | **[high]** | 2024–2025 community winner. Async preview pipeline replaces ranger/lf. Image preview via sixel / kitty protocol. |
| **Chat (Slack bridge)** | `weechat` + `wee-slack` | **[medium]** | Standard for Slack-in-terminal. Slack threads survive better than `slack-term` (abandoned). Limited value if you also keep Slack desktop open for huddles. |
| **PDF in terminal** | `tdf` (Rust) | **[medium]** | Renders to terminal via sixel. Niche but the standard pick. |

### 9.2 Prerequisites (one-time plumbing)

Before mail / calendar TUIs are usable, you'll need:

| Tool | Required for | Role |
|---|---|---|
| `mbsync` (isync) | aerc (offline) | IMAP → maildir sync |
| `msmtp` | aerc (send) | SMTP send queue |
| `vdirsyncer` | khal | CalDAV → local store sync |
| `notmuch` | aerc (optional) | Mail indexer; powerful search across aerc |
| `pass` or `_1password-cli` | mbsync / msmtp | Avoid storing IMAP/SMTP passwords in plaintext; pull from your existing secret store |

Wire all of these via Nix modules — none should land in `~` imperatively.

### 9.3 Deliberate non-adds (terminal-app layer)

- **`mutt` / `neomutt`** — still works but `aerc` is the modern replacement; pick one.
- **`calcurse`** — competes with khal but has a worse sync story (no proper CalDAV).
- **`ncmpcpp`** — relevant only with a local music library managed by mpd; most modern users don't have one.
- **`slack-term`**, **`cordless`**, **`spotify-tui`** — all abandoned or broken; don't reinvest.
- **`ranger`**, **`lf`** — superseded by `yazi`; migrate if you use either.
- **`ncdu`** — kept around if you use it, but `dust` is the modern equivalent.

### 9.4 Suggested implementation order

If you decide to ship the TUI-daily-apps layer:

1. **`yazi`** — file manager is the highest daily-use leverage; you touch files constantly
2. **`spotify_player`** — instant ROI if you listen during work; sets up the "I never leave the terminal" muscle
3. **`khal` + `vdirsyncer`** — calendar visibility from terminal, pair with meetingbar (which stays as the menubar alert layer)
4. **`aerc` + `mbsync` + `msmtp`** — mail is the most plumbing-heavy; do it last when the rest is settled
5. **`newsboat`** — only if you actively curate RSS; skip otherwise (most people overestimate how much RSS they'll read)

### 9.5 Trade-off in one line

Terminal-first daily apps move every workflow inside one keyboard-driven
surface (you never leave tmux); the cost is per-tool config + initial
plumbing (IMAP/CalDAV/OAuth) and accepting that GUI-only features
(Spotify Connect device switching, rich HTML email rendering, calendar
drag-resize) become awkward or unavailable.

---

## 10. Hidden gems — community-leveraged tools you may not know

Tools the dotfiles / HN / r/neovim community actively recommends in
2026 that aren't household names but punch well above their weight.
Curated specifically to skip the obvious picks already covered.

### 10.1 Daily-driver replacements

| Tool | Tag | Why |
|---|---|---|
| `difftastic` | **[high]** | Syntax-aware diff renderer. Replaces `git diff` output; dramatically improves code-review readability. Wire via `[diff] external = difft` in gitconfig. |
| `tealdeer` (Rust `tldr`) | **[verify]** | Fast simplified man pages. Most users have it; verify before adding. |
| `sd` | **[high]** | `sed` with sane syntax. `sd 'foo' 'bar' file.txt` — that's it. Most engineers don't know this exists. |
| `ouch` | **[high]** | Universal archive tool. `ouch decompress anything.{tar.gz,zip,7z,rar,...}`. Stops you re-googling tar flags forever. |
| `viddy` | **[medium]** | Modern `watch` with diff highlighting + time-travel scrubbing. |
| `hyperfine` | **[high]** | Statistical CLI benchmarking. `hyperfine 'cmd1' 'cmd2'` → properly compares. Standard for any perf work. |
| `topgrade` | **[medium]** | Runs every package manager's upgrade in one command (nix, brew, npm, pip, cargo, …). Less useful in a Nix-first setup but handy for the leaks. |

### 10.2 Tmux power moves

| Tool | Tag | Why |
|---|---|---|
| `tmux-thumbs` | **[high]** | Hit a hotkey → every URL/IP/hash on screen gets a 2-letter label → type the letters to copy. Eliminates "drag to select" permanently. |
| `extrakto` | **[medium]** | Same idea, fzf-based. Pick one. |

### 10.3 Aerospace / sketchybar community staples

| Tool | Tag | Why |
|---|---|---|
| `JankyBorders` (`borders`) | **[high]** | Colored border around the focused window. Standard companion to aerospace/yabai in the 2025–2026 ricer scene. ~30 lines of config; visual focus tracking becomes effortless. |
| `sketchybar-app-font` | **[medium]** | Icon font with thousands of macOS app glyphs. If you add app icons to the front_app pill (§ already-shipped), this is where the icons come from. |

### 10.4 Docker / local dev

| Tool | Tag | Why |
|---|---|---|
| `OrbStack` (cask) | **[high]** | Docker Desktop replacement on macOS. Faster, lower-memory, Apple-Silicon-native. The community has largely moved to this. |
| `lazydocker` | **[medium]** | TUI for Docker containers; by the lazygit author. Same UX language. |
| `dive` | **[medium]** | Inspect Docker image layers. Standard in container debugging. |

### 10.5 Data / DB

| Tool | Tag | Why |
|---|---|---|
| `lazysql` | **[medium]** | SQL TUI for Postgres/MySQL/SQLite. Lighter than TablePlus when you just want to run a query. |
| `jnv` | **[high]** | Interactive jq TUI — pipe JSON in, build the query live with feedback. Replaces "trial-and-error jq cycles". |

### 10.6 HTTP / API

| Tool | Tag | Why |
|---|---|---|
| `posting` (Textual) | **[high]** | TUI Postman. Active development, polished UX. Probably the best 2026 Postman alternative in terminal. |
| `slumber` | **[medium]** | Alternative; YAML-defined requests if you prefer file-based / git-versioned. |
| `xh` | **[medium]** | `httpie` rewritten in Rust. Replaces curl for human-readable responses. |

### 10.7 AI workflows beyond the obvious

| Tool | Tag | Why |
|---|---|---|
| `aider` | **[medium]** | AI pair programmer operating on git commits directly. Different shape than Claude Code: commit-per-prompt, git-native. |
| `llm` (Simon Willison) | **[medium]** | Pipe-friendly LLM CLI with a plugin for every provider. Competes with `mods`; more powerful plugin ecosystem. |

### 10.8 Shell scripts that don't look like 1995

| Tool | Tag | Why |
|---|---|---|
| `gum` (Charm.sh) | **[high]** | `gum choose "yes" "no"`, `gum input --placeholder "name"`, `gum spin --title "loading" -- long-cmd`. Turns shell scripts into proper TUIs in 3 lines. |
| `navi` | **[medium]** | Interactive cheatsheets bound to a hotkey. Replaces "let me grep my notes for that incantation". |
| `pet` | **[medium]** | Command snippet manager with fuzzy recall. Alternative to navi; pick one. |

### 10.9 macOS-specific community favorites

| Tool | Tag | Why |
|---|---|---|
| `AltTab` (cask) | **[high]** | Windows-style alt-tab with previews. Many find native cmd-tab inadequate; this fixes it. |
| `MonitorControl` (cask) | **[high if external monitor]** | Keyboard brightness/volume for non-Apple displays. Borderline mandatory with external monitors. |
| Karabiner community rules repo | **[medium]** | Community-shared complex modifications for vim-like nav system-wide. Source for ideas, not direct imports. |

### 10.10 File / network transfer

| Tool | Tag | Why |
|---|---|---|
| `magic-wormhole` or `croc` | **[medium]** | Peer-to-peer file send with no servers. `wormhole send file.zip` → recipient types a code. Standard among sysadmins for ad-hoc transfers. |
| `monolith` | **[medium]** | Save any webpage as a single self-contained HTML file. Useful for archival when content goes 404. |

### 10.11 Cloud (if AWS-heavy)

| Tool | Tag | Why |
|---|---|---|
| `granted` | **[medium]** | Secure AWS profile switcher with browser-tab isolation per role. Modern replacement for `aws-vault`. |

### 10.12 Presentations / sharing

| Tool | Tag | Why |
|---|---|---|
| `presenterm` | **[track]** | Markdown slides in terminal. Currently absent from HM module on your channel (see memory file `hm_module_gaps.md`); worth picking up when it lands. |
| `slides` (Charm.sh) | **[medium]** | Alternative; simpler. |

### 10.13 Top 5 hidden-gem installs (prioritized)

If you only adopt 5 from §10, this is the order:

1. **`difftastic`** — every code-review session benefits immediately
2. **`gum`** — every future shell script you write becomes nicer
3. **`OrbStack`** — replaces Docker Desktop, immediate perf/RAM win
4. **`JankyBorders`** — visual focus tracking on aerospace, daily payoff
5. **`tmux-thumbs`** — copy URLs/hashes without ever leaving keyboard

### 10.14 Trade-off in one line

Hidden gems are hidden because they target a *narrow* pain point each;
the cost is incremental config and the risk that the bus factor on
some of these is 1–2 maintainers — prefer the ones backed by Charm.sh,
jesseduffield (lazygit/lazydocker), or a Rust-foundation-shaped community.

---

## 11. Final sweep — categories the previous sections did not cover

The earlier sections cover **tools**. This section covers everything the
tool-shaped lens misses: practices, identity isolation, Nix-infra,
cross-device, AI infra beyond Claude, and the contractor-specific layer.

### 11.1 Practice / process layer (no tools — rituals)

These are zero-install. They beat any tool because they shape *what* you
do with the tools you already have.

| Practice | Tag | Why |
|---|---|---|
| **Weekly review** (GTD) — Friday 30 min: empty `task next`, reconcile `timew summary`, write 5-line journal | **[high]** | Without it, the productivity stack accumulates entropy. The single most-recommended ritual across HN/Reddit productivity threads. |
| **Decision journal** — separate `jrnl --type decisions` for non-trivial choices, reviewed quarterly | **[medium]** | Calibrates your own decision-making over time. Cited by Daniel Kahneman, Annie Duke, Shane Parrish. |
| **Brag doc / accomplishments log** — append-only file (`~/Documents/journal/brag.md`) updated weekly | **[high]** | Performance reviews, raise conversations, end-of-contract handover — you will not remember Q1 by Q4. Julia Evans' canonical post. |
| **Personal OKRs** — quarterly, 3 objectives × 3 key results, stored in `~/Documents/zk` | **[medium]** | Long-horizon counterweight to taskwarrior's day-by-day pull. |
| **Learning log** — one zk note per book/article finished + 3 takeaways | **[medium]** | Closes the loop: input (reading) → retention (notes) → recall (search). |

### 11.2 Spaced repetition + read-later

The reading-input side is currently unmanaged.

| Tool | Tag | Why |
|---|---|---|
| **Anki** (or `mochi`) | **[medium]** | Spaced repetition for technical concepts. Industry standard among medical students; underused by engineers. Ankidroid + ankiweb syncs to phone. |
| **Wallabag** (self-hosted) or **Readwise Reader** | **[medium]** | Read-later queue. Wallabag is the OSS choice; Readwise is the paid king with highlight-export integrations. |
| **`readwise-export`** → zk integration | **[low]** | Pipe Kindle/web highlights into zk as notes. The Readwise → Obsidian/zk pipeline is widely shared on r/PKM. |

### 11.3 Identity / context isolation (you are a contractor)

Per memory `employer_context.md`: tzero is a temporary contract, GeekyAnts
is primary. Today these identities share too much state.

| Gap | Tag | Recommendation |
|---|---|---|
| Browser profiles per identity not enforced | **[high]** | Already noted in §5 (Brave Profiles by domain); wire it explicitly: GeekyAnts profile, tzero profile, personal profile, with bookmark bars segregated. Aerospace `on-window-detected` can route Brave windows to different workspaces by profile via window title. |
| SSH agent isolation | **[medium]** | Per-identity agent sockets (`SSH_AUTH_SOCK` switched in zsh based on `$PWD` prefix). Prevents leaking the wrong key when a repo URL is ambiguous. |
| Secrets per-identity not separated | **[medium]** | tzero credentials in `~/.config/tzero/`, GeekyAnts in `~/.config/geekyants/`, sourced via direnv `.envrc` per project root. |
| Time-tracking → invoice | **[high]** | `timew export :month | jq` → CSV → invoice template. Contractors lose money to under-billed time. The `timewarrior-report` community has 3-4 jq snippets that handle this. |
| Tax/expense ledger | **[medium]** | `hledger` plain-text accounting. The contractor-friendly OSS choice; integrates with timew export. |

### 11.4 Nix-infrastructure improvements

Your Nix config itself has unmanaged layers.

| Gap | Tag | Recommendation |
|---|---|---|
| **Secrets in Nix** — currently any token committed is in plaintext | **[high]** | `sops-nix` or `agenix` for encrypted secrets in the flake. The community is roughly split 60/40 sops/agenix; sops-nix is the more "industrial" choice (used by NixOS itself). |
| **Per-project devenvs** — global `home.packages` keeps growing | **[medium]** | `devenv.sh` (or plain `flake.nix` + direnv) per project so tzero-portal's node version is pinned independent of GeekyAnts repos. |
| **Faster nix eval** — current evaluation is slow on rebuild | **[low]** | `lix` (fork of nix with eval improvements) — community has shifted significantly toward it since 2024-25. |
| **CI for your dotfiles flake** — no test that switch will succeed before pushing | **[medium]** | GitHub Action running `nix flake check` + `nix build .#darwinConfigurations.<host>.system` on PRs. Catches breakage before `darwin-rebuild switch` does. |
| **Restore-test ritual** — bootstrap-this-machine-from-scratch playbook | **[high]** | Quarterly: `nix-darwin` build on a fresh user account or VM. If your flake can't rebuild your machine, the flake is a lie. |

### 11.5 AI infrastructure beyond Claude Code

| Tool | Tag | Why |
|---|---|---|
| **`aider`** (already listed in §10) — terminal-native code assistant with git-commit-per-edit | **[medium]** | Different niche than Claude Code: tighter git loop, supports local models. |
| **Ollama** + `qwen2.5-coder` or `deepseek-coder-v2` | **[medium]** | Local LLM for offline / private code (tzero proprietary code stays on-device). 32GB RAM machines run 14B comfortably. |
| **`llm`** CLI (Simon Willison) | **[medium]** | Unified interface over OpenAI / Anthropic / local. `cat file.py | llm 'explain this'` from any pipe. Most-starred LLM-CLI on GH. |
| **`whisper.cpp`** + hotkey → clipboard | **[medium]** | Voice-to-text for journal entries, commit messages, longer prompts. Hammerspoon hotkey → record → whisper → paste. Power-user workflow on r/macapps. |
| **`fabric`** (Daniel Miessler) | **[low]** | Curated library of LLM prompts as CLI verbs (`fabric -p summarize`). Becoming the de-facto prompt-pattern library. |
| **Embeddings over `~/Documents/zk`** | **[low]** | `llm embed-multi notes` → semantic search across your notes. Closes the "I know I wrote this somewhere" gap. |

### 11.6 Cross-device + mobile continuity

| Gap | Tag | Recommendation |
|---|---|---|
| **Push notifications from Mac → phone** | **[medium]** | `ntfy.sh` (OSS, self-hostable). `curl -d "deploy done" ntfy.sh/yourtopic` from any script; phone app gets push. Replaces Pushover for the cost-conscious. |
| **SSH from phone** | **[medium]** | Blink Shell (iOS, paid, gold-standard) or Termius. With ntfy you can trigger long jobs on the Mac and check from anywhere. |
| **iPhone Focus modes synced with timew** | **[low]** | Shortcuts.app + ntfy webhook: when timew starts a `@deep` task, phone enters Do-Not-Disturb. Closes the "phone interrupts deep work" loop. |
| **iPad as second display** — Sidecar | **[low]** | Native; already there. Underused for `btop` / sketchybar mirror. |

### 11.7 Energy / biology layer

Productivity tooling without energy management is a luxury car with no fuel gauge.

| Gap | Tag | Recommendation |
|---|---|---|
| **Sleep → workflow integration** | **[medium]** | Apple Health → shortcut → ntfy → if previous-night sleep < 6h, sketchybar shows red dot, suggests no-meeting day. Niche but the r/quantifiedself crowd swears by it. |
| **Hydration / posture reminders** | **[low]** | Just another launchd agent in §2.2. `terminal-notifier -message "stand up"` every 50 min during work hours. |
| **Morning light exposure cue** | **[low]** | First sketchybar render of the day pings if sunrise was >30 min ago. Trivial but the Huberman crowd is huge. |

### 11.8 Documentation / diagramming

| Tool | Tag | Why |
|---|---|---|
| **`d2`** (Terrastruct) | **[medium]** | Text → diagram. The modern community choice over PlantUML/Mermaid for architecture diagrams. Renders to SVG/PNG, lives next to code in PRs. |
| **`excalidraw`** + `excalidraw-cli` export | **[medium]** | Whiteboard-style; the de-facto choice across the JS/Notion-adjacent crowd. |
| **`mermaid`** | **[low]** | GitHub renders it natively in markdown — pick this over d2 when the audience is GitHub PRs. |

### 11.9 Network / privacy layer

| Gap | Tag | Recommendation |
|---|---|---|
| **DNS-level ad/tracker block** | **[medium]** | `NextDNS` (paid, no infra) or `pi-hole` (self-hosted). Works on every device including phone, browser-extension-independent. |
| **VPN per context** | **[low]** | Tailscale (already widely adopted) for tzero-internal services + personal devices. Free tier covers solo use. |
| **Encrypted DNS** | **[low]** | Already on macOS via Settings → Network → DNS-over-HTTPS once NextDNS configured. |

### 11.10 Disaster-recovery rituals

Already touched in §5/§11.4 but worth their own block:

| Item | Tag | Why |
|---|---|---|
| **Quarterly restore test** | **[high]** | The only way to know your backup works. Spin a fresh macOS user, run the flake, time-to-productive should be < 30 min. |
| **Encrypted off-site backup** | **[high]** | `restic` → Backblaze B2 (already in §5). Automate via launchd; rotate keys yearly. |
| **Lost-laptop runbook** | **[medium]** | One-page note in zk: revoke SSH keys, revoke GH/GL tokens, rotate Apple ID password, file insurance. Written *before* you need it. |

### 11.11 What is genuinely NOT missing (closing this loop)

To name the boundary so future-you doesn't keep adding:

- **Editor** — nvim + LazyVim + claude-code.nvim is at the frontier
- **Shell** — zsh + atuin + intelli-shell + carapace is the 2026 stack
- **WM** — aerospace + sketchybar + karabiner-hyper covers macOS tiling fully
- **Terminal** — Ghostty with quake mode is the current frontier
- **Multiplexer** — tmux + sesh is the converged community choice
- **Tasks/time** — taskwarrior + timewarrior + dijo cover the data side completely
- **Git forges** — gh + glab + git-with-per-identity-signing is fully wired
- **Notes** — zk + journal-cli covers Zettelkasten + chronological

Anything more *inside* these categories is sidegrade, not upgrade.

### 11.12 Top 5 from this section (prioritized)

1. **Weekly review ritual** (§11.1) — zero install, biggest leverage
2. **sops-nix or agenix** (§11.4) — closes the plaintext-secrets risk
3. **Brag doc** (§11.1) — pays dividends at every review/handover
4. **Browser profile isolation per identity** (§11.3) — contractor hygiene
5. **Quarterly restore test** (§11.10) — proves the whole flake actually works

### 11.13 Trade-off in one line

§11 items are *meta* — process, identity, infra, biology — not flashy
tool installs; the cost is they need recurring discipline, not a
one-time `nix flake update`, but they're the layer where mature
practitioners separate from accumulators of tools.
