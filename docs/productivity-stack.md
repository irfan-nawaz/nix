# The Productivity Stack — User Guide

A complete walkthrough of how to use the layered tooling on this machine to
move fast and stay organized. Written assuming nothing — read it once
top-to-bottom and you will understand the whole system.

---

## 1. The mental model

Three independent layers cooperate to turn your laptop into one big
hotkey-driven cockpit. Each layer does ONE job and does not step on the
others. Knowing which layer owns which key is the secret to never being
confused.

```
┌───────────────────────────────────────────────────────────────┐
│  Layer 3  — TMUX + SESH      (panes & sessions inside one terminal)
├───────────────────────────────────────────────────────────────┤
│  Layer 2  — AEROSPACE        (windows across the whole desktop)
├───────────────────────────────────────────────────────────────┤
│  Layer 1  — HAMMERSPOON      (chord → action: launch apps, run scripts)
├───────────────────────────────────────────────────────────────┤
│  Layer 0  — KARABINER        (physical keys → logical keys: caps→hyper)
└───────────────────────────────────────────────────────────────┘
```

Read from the bottom: Karabiner rewrites a key BEFORE anything else sees
it. Hammerspoon then catches the rewritten chord. Aerospace owns its own
chord. Tmux only lives inside the terminal. Sketchybar is just the
heads-up display showing you what is going on.

If something "doesn't work," ask: **which layer is supposed to handle that
key?** That diagnoses 90% of issues.

---

## 2. The most important key on the keyboard: Caps Lock

Caps Lock has been rewired. It now does TWO things depending on how you
press it:

| Action | Result |
|---|---|
| Tap Caps Lock alone (press + release quickly) | Sends **Escape** |
| Hold Caps Lock + press another key | Sends **Hyper + that key** |

"Hyper" is the four-finger modifier combo `Cmd + Ctrl + Option + Shift`
held all at once. No human can press that combo cleanly, which is the
whole point — Hyper chords are guaranteed not to collide with any normal
app shortcut. Caps Lock is the single, comfortable, home-row gateway to
the Hyper layer.

### Caps Lock as a navigation layer

While holding Caps Lock, your right hand becomes an arrow / movement
cluster without leaving the home row:

| Hold Caps + ... | What it does |
|---|---|
| `h` | Left arrow |
| `j` | Down arrow |
| `k` | Up arrow |
| `l` | Right arrow |
| `u` | Page Up |
| `i` | Page Down |
| `y` | Home (jump to start of line) |
| `o` | End (jump to end of line) |
| `Backspace` | Forward Delete (the key Mac keyboards don't have) |

This works in **every app**: browser, Slack, code editor, Notes — anywhere
the arrow keys would normally work. Once your fingers learn it, you stop
reaching for the arrow cluster. Less wrist travel = faster, less pain.

### Recovering "real" Caps Lock

If you ever genuinely need Caps Lock (typing an acronym in all caps),
press **left Shift hold + right Shift click** and Caps Lock toggle.

---

## 3. Launching apps without your mouse — Hammerspoon

Holding Caps Lock and tapping **Space** triggers the **Leader**. A small
HUD appears at the bottom of your screen listing what you can do next.
This is exactly like Vim's leader key — once you are in the leader, any
key you press is interpreted as a *command*, not as a regular letter.

### Top-level leader

```
LEADER
  a   apps  +
  r   reload-hs
  esc cancel
```

- `a` opens the **apps submode** (a second HUD with the actual app
  bindings — see below)
- `r` reloads Hammerspoon's config file (rarely needed by hand; it auto-
  reloads on file change)
- `esc` exits without doing anything

### Apps submode

After `caps+space, a` you see:

```
LEADER > APPS
  b   brave
  t   ghostty
  s   slack
  v   cursor
  n   obsidian
  f   finder
  m   meeting
  esc back
```

Press the highlighted letter and the app launches (or comes to the front
if already running). The leader then exits automatically — you are back to
typing normally.

### The mental rhythm

```
caps+space  →  a  →  b
   ↑           ↑     ↑
 leader      apps   brave
```

Three keys, no modifiers held down (after the initial Caps), pure muscle
memory. After a week you stop seeing the HUD because your fingers are
already done before it renders.

### Adding a new app

Edit `home/programs/hammerspoon.nix`, find the `appBindings` table, add
one row:

```lua
{ key = "x", app = "Some App",     label = "thing" },
```

The exact `app` string is the macOS application name (case-sensitive — the
same name Spotlight shows). Save the file; the watcher reloads
Hammerspoon automatically.

---

## 4. Window management — Aerospace

Aerospace is a tiling window manager. Instead of dragging windows around
with the mouse, it splits your screen into rectangles and you tell it where
to put windows using the keyboard.

### Workspaces

You have 9 numbered workspaces (1 through 9). Think of each workspace as a
separate desktop. Each window lives on exactly one workspace.

A typical convention (this is your call, but pick one and stick to it):

| Workspace | Purpose |
|---|---|
| 1 | Terminal / coding |
| 2 | Browser |
| 3 | Slack / comms |
| 4 | Notes / Obsidian |
| 5 | Music / media |
| 6–9 | Scratch / project-specific |

### Entering WM mode

Aerospace uses a **modal** approach (Vim-style). You enter "window
management mode" with one chord, then everything you press is a window
command, until you press Escape to exit:

```
Hold Caps + W   →  enters wm-mode (sticky)
```

While in wm-mode, your status bar should visibly change focus (the
workspace pills repaint as you move). Normal typing is suspended while
inside this mode — every key is a window command.

### Inside wm-mode

| Key | What it does |
|---|---|
| `h` `j` `k` `l` | Move focus left / down / up / right (between windows) |
| `H` `J` `K` `L` (shift + hjkl) | Move the focused window in that direction |
| `1` … `9` | Switch to workspace N |
| `Shift + 1` … `Shift + 9` | Send the focused window to workspace N |
| `Tab` | Jump back to the previous workspace |
| `/` | Toggle horizontal/vertical tiling |
| `,` | Switch to accordion layout |
| `-` / `=` | Shrink / grow the focused window |
| `f` | Fullscreen the focused window |
| `Space` | Toggle floating <-> tiling for this window |
| `;` | Enter "service mode" (advanced ops; rarely needed) |
| `Esc` or `Enter` | Exit wm-mode (back to normal typing) |

### A worked example

You're editing code in your terminal on workspace 1. A teammate pings
you in Slack on workspace 3. You want to read the message, write a reply,
then come back.

```
caps + w        →  enter wm-mode
3               →  jump to workspace 3 (Slack)
esc             →  exit wm-mode, type your reply
caps + w        →  enter wm-mode again
1               →  jump back to workspace 1 (terminal)
esc             →  resume coding
```

That whole round-trip is six keystrokes. No mouse, no Mission Control
swipe, no Cmd-Tab guessing.

### Sending a window somewhere

You opened a browser by accident on workspace 1 (your code workspace) and
want it on workspace 2 (your browser workspace):

```
caps + w        →  enter wm-mode
Shift + 2       →  move this window to workspace 2 (it disappears)
2               →  follow it to workspace 2
esc             →  done
```

### The status bar pills tell you where you are

The numbers 1–9 at the top-left of your screen are workspace pills. The
**filled pill is your current workspace**. They live-update every time
you switch.

---

## 5. The top bar — Sketchybar

Sketchybar is the strip at the top of your screen. It is read-only — it
shows information, you don't click it (with one exception below).

### What each item means

```
[1] 2 3 4 5 6 7 8 9            [4]              Mon May 26  14:32   85%
 \________workspaces________/    \_clock_/       \__date+time_/   battery
                                                                    \
                                                                     stays
                                                                  green when
                                                                  AC plugged
                                                                  in, turns
                                                                  red < 20%
                                                                  on battery

                          [tag · 23m]   <- active timew tracker (auto-hides
                                          when nothing is tracking)
                          [3]           <- count of pending taskwarrior
                                          tasks (auto-hides at 0)
```

### Interaction

- **Click a workspace pill (1–9)** → jumps to that workspace. This is the
  one mouse-friendly interaction in the bar.
- **Click the timew label** → stops the currently-tracked timer.

Everything else is just a display.

### Why these specific items?

| Item | Purpose |
|---|---|
| Workspace pills | Always know which workspace you're in without thinking |
| Task count | A glanceable "do I have anything pending" indicator |
| Timew tracker | Live feedback that time tracking is on (catches "oh I forgot to stop the timer" failures) |
| Clock | Self-explanatory |
| Battery | Color codes danger (red < 20%) so you notice without checking |

---

## 6. Inside the terminal — Tmux

Tmux is a "terminal multiplexer." It lets you have many shells inside one
terminal window, organized into **sessions**, **windows**, and **panes**.

| Concept | What it is |
|---|---|
| Session | A named workspace (e.g., `main`, `nix`, `tasks`). Roughly = "a project." |
| Window | A tab inside a session |
| Pane | A split inside a window (left half + right half, etc.) |

### The prefix

Tmux commands start with a **prefix**: `Ctrl + a`. (The default is
`Ctrl + b`, but `a` is closer to home row and easier on the pinky.) So:

```
Ctrl-a , then |    →  split current pane vertically (a new pane to the right)
Ctrl-a , then -    →  split current pane horizontally (a new pane below)
```

Note the rhythm: press `Ctrl-a`, RELEASE, then press the next key. It is
not a chord.

### Essential bindings

| Prefix + key | What it does |
|---|---|
| `\|` (pipe) | Split current pane vertically |
| `-` | Split current pane horizontally |
| `h` `j` `k` `l` | Move focus between panes (vim style) |
| `c` | Create a new window |
| `n` / `p` | Next / previous window |
| `1` … `9` | Jump to window N |
| `,` | Rename current window |
| `d` | Detach (hide tmux, leave it running in background) |
| `r` | Reload tmux config |
| `[` | Enter copy mode (vim-style scroll/select) |
| `s` | **Open the sesh session picker** (see next section — this is the killer feature) |
| `K` | Jump to the last session you were in |

### Copy mode (scrollback)

```
Ctrl-a [             →  enter copy mode
(use h j k l, /search, n, N to navigate)
v                    →  start visual selection (like vim)
y                    →  copy to system clipboard
q or Esc             →  exit copy mode
```

Mouse scroll also works (mouse mode is on), but the keyboard version is
faster once you have it.

### Persistence

Sessions stay alive even after you close Ghostty or detach. Reopen the
terminal, run `tmux a` (or open a sesh session — see next section) and
you're back exactly where you left off. `exit-empty off` and
`detach-on-destroy off` are set so killing the last pane of a session
hops you to the next session instead of crashing tmux.

---

## 7. The session ecosystem — Sesh

Sesh is the layer that makes tmux fast and pleasant. It is a fuzzy session
picker + lifecycle manager.

### Opening the picker

Inside any tmux session, press:

```
Ctrl-a s
```

A fuzzy picker pops up in the middle of the screen with all defined
sessions. Type a few letters to narrow it, hit Enter, and you are
attached.

### The pre-defined sessions

Each entry below is a one-keystroke jump to a working environment. The
**second column** is the command sesh runs automatically when you create
the session (you don't have to type it).

| Session  | Path                  | What auto-runs when you open it          |
|----------|----------------------|------------------------------------------|
| `main`    | `~`                   | nothing — plain shell                    |
| `nix`     | `~/nix`               | `nvim .` (opens this whole repo in nvim) |
| `claude`  | `~/nix`               | `claude` (Claude Code CLI)               |
| `notes`   | `~/Documents/zk`      | `zk edit --interactive`                  |
| `tasks`   | `~`                   | `taskwarrior-tui`                        |
| `habits`  | `~`                   | `dijo` (habit tracker TUI)               |
| `journal` | `~/Documents/journal` | `jrnl --edit`                            |
| `sys`     | `~`                   | `btop` (system monitor)                  |
| `clock`   | `~`                   | `clock-rs` (terminal clock)              |

### The pattern

You don't think "I want to open my task manager." You think **"go to my
tasks workspace,"** type `Ctrl-a s`, type `tas`, hit Enter — and
taskwarrior-tui is already on screen. Same for notes, journal, code,
etc. The terminal acts as your filing cabinet: one drawer per area of
your life.

### Adding a new session

Edit `home/programs/sesh.nix`, find the `sessions = { ... }` block, add a
row. Example:

```nix
docs = { path = "~/Documents"; command = "lf"; };
```

Save, rebuild (`darwin-rebuild switch`), and the new session is in the
picker.

### Sessions persist independently

If you start the `tasks` session, do some work, and then jump to `notes`,
the `tasks` session keeps running in the background. Hop back to it
later (`Ctrl-a s`, pick `tasks`) and your taskwarrior-tui is in the same
state you left it.

---

## 8. Task tracking — Taskwarrior + Timewarrior

These two work together. Taskwarrior tracks WHAT to do; Timewarrior tracks
how long you spent on it. They are wired so that **starting a task
automatically starts a timer**, and **completing or stopping a task
automatically stops the timer**.

### Basic taskwarrior usage

```bash
task add "Fix login bug" project:work +bug
task                            # list pending tasks
task 3 start                    # start task #3 (this also starts timew)
task 3 done                     # mark done (this also stops timew)
task 3 stop                     # stop without completing
task 3 modify priority:H        # bump priority
task burndown                   # weekly progress chart
```

Inside the `tasks` sesh session, **taskwarrior-tui** gives you a TUI with
arrow-key navigation — no need to memorize taskwarrior's flag syntax for
day-to-day use.

### Time tracking — automatic

Don't run `timew start` yourself. Just `task <id> start` and timew picks
up the task's project, tags, and description as the interval's tags. When
you `task <id> done` or `task <id> stop`, the timer stops cleanly.

```bash
timew                          # show what's tracking right now
timew summary :week            # week-to-date breakdown
timew summary :day             # today's breakdown
```

### The status bar reflects state instantly

When you `task 3 start`, the `[tag · Nm]` label on the top bar lights up
within a second (the on-modify hook fires a sketchybar event — no polling
delay). When you `task 3 done`, it disappears. This is your "is the
timer still on?" canary.

### Tags worth knowing

Two tag patterns get special treatment:

| Tag | Effect |
|---|---|
| `+next` | Bumps urgency score by 15 (Getting-Things-Done's "next action" pattern). Use this to mark what you should be working on right now. |
| `+PENDING` | Auto-applied to everything that isn't done. Used by the task-count item on the status bar. |

---

## 9. A complete daily workflow

The whole stack in one walkthrough.

### Morning startup

You sit down. Hit Caps + Space (Hammerspoon leader), `a` (apps), `t`
(Ghostty). Terminal pops up. Ctrl-a s, type `tas`, Enter — you are in
taskwarrior-tui, eyeballing your queue. The status bar shows `[5]` pending.

You decide which one to start. Press `s` in taskwarrior-tui to start the
selected task. The status bar lights up: `[bug · 1m]`. Time is now being
tracked.

### Switching context to write code

Ctrl-a s, type `nix`, Enter. You're now in `~/nix` with Neovim already
open on the project. The `tasks` session is still running in the
background.

Make some changes. Need to open the browser to look up docs?

```
Caps + Space, a, b
```

Brave is now in front. Find the docs.

The browser is on workspace 2; your terminal is on workspace 1. Switch
back:

```
Caps + w, 1, Esc
```

Back in Neovim. Keep coding.

### Need to check Slack

```
Caps + w, 3, Esc
```

Workspace 3 (Slack). Read the message. Reply. Hop back:

```
Caps + w, 1, Esc
```

### Finishing a task

You're done with the task you started this morning. Open the tasks
session:

```
Ctrl-a s, tas, Enter
```

Move to the task, press `d` (done). The status bar timer disappears.
Task count drops from 5 to 4.

### Detour for a note

You want to jot down an idea before you forget. Ctrl-a s, type `not`,
Enter — you are in zk's interactive note editor inside `~/Documents/zk`.
Write the note. Ctrl-a s, `nix`, Enter to go back to coding. The note
session keeps running.

### End of day

Want to see how you spent the day:

```bash
timew summary :day
```

Tag breakdown of every minute that was tracked.

Need to detach everything and shut the laptop:

```
Ctrl-a d        →  detach from tmux (sessions keep running)
Cmd + Q         →  quit Ghostty (sessions STILL running in background)
```

Next morning, open Ghostty, `tmux a`, and every session is still where
you left it.

---

## 10. When something doesn't work — quick triage

| Symptom | Probably the layer that's broken |
|---|---|
| Caps Lock acts like normal Caps Lock | Karabiner not running. Check `~/Library/Application Support/Karabiner-Elements`. |
| Caps + Space does nothing, but Caps tapped alone correctly emits Escape | Karabiner is fine; Hammerspoon isn't running. Launch `Hammerspoon.app`. |
| Hammerspoon leader HUD shows but pressing the app key does nothing | App name mismatch in `home/programs/hammerspoon.nix`. The `app = "..."` string must match the macOS application name exactly. |
| Caps + W enters wm-mode but pills don't update | Aerospace can't find sketchybar. Check that `sketchybar` is on PATH. |
| `Ctrl-a s` shows the picker but session won't connect | Sesh's `respawn-pane` couldn't run the command. The tool may not be installed — check `home.packages`. |
| Top bar is missing entirely | Sketchybar agent died. `launchctl kickstart -k gui/$(id -u)/org.nix-community.home.sketchybar` |

### Reload paths

```bash
# Karabiner: GUI reloads automatically on karabiner.json change
# Hammerspoon: file-watcher auto-reloads init.lua

# Tmux config reload
Ctrl-a r

# Aerospace config reload (inside wm-mode, then service mode)
Caps + w, ;, Esc       # ; enters service mode, Esc inside service mode reloads

# Sketchybar reload
sketchybar --reload

# Full rebuild (anytime you change a .nix file)
sudo darwin-rebuild switch --flake ~/nix#shaikmdirfannawaz
```

---

## 11. One-page cheat sheet

```
KARABINER (always on)
  caps (tap)              Escape
  caps + hjkl             arrows
  caps + ui               page up/down
  caps + yo               home/end
  caps + backspace        forward delete
  L-shift + R-shift       real caps lock (toggle)

HAMMERSPOON (apps)
  caps + space            leader HUD
    a                     apps submode
      b brave   t ghostty   s slack   v cursor
      n obsidian   f finder   m meeting
    r                     reload Hammerspoon
    esc                   cancel

AEROSPACE (windows)
  caps + w                enter wm-mode (sticky)
  inside wm-mode:
    h j k l               focus left/down/up/right
    H J K L               move window
    1..9                  switch workspace
    shift + 1..9          send window to workspace
    tab                   previous workspace
    f                     fullscreen
    space                 float/tile toggle
    / ,                   layout: tiles / accordion
    - =                   resize smaller / larger
    esc                   exit wm-mode

TMUX (inside terminal)
  prefix = ctrl-a
  ctrl-a |                vertical split
  ctrl-a -                horizontal split
  ctrl-a h j k l          pane focus
  ctrl-a c                new window
  ctrl-a 1..9             jump to window N
  ctrl-a d                detach
  ctrl-a [                copy/scroll mode
  ctrl-a s                SESH PICKER
  ctrl-a K                last session

SESH SESSIONS
  main      ~                   shell
  nix       ~/nix               nvim .
  claude    ~/nix               claude
  notes     ~/Documents/zk      zk edit --interactive
  tasks     ~                   taskwarrior-tui
  habits    ~                   dijo
  journal   ~/Documents/journal jrnl --edit
  sys       ~                   btop
  clock     ~                   clock-rs

TASK + TIME
  task add "..."          new task
  task 3 start            start task + auto-start timer
  task 3 done             complete + auto-stop timer
  task 3 stop             stop timer without completing
  task +next              high-urgency tag
  timew summary :day      today's time breakdown
  timew summary :week     week-to-date
```

---

## 12. The philosophy in one sentence

**Keyboard for movement, terminal for work, tmux for organization, time
tracked automatically.** Once your hands stop reaching for the mouse,
your context-switching cost collapses, and the system starts to feel
less like a stack of tools and more like a single instrument.
