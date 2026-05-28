# Daily Operating System

Work hours: **12:00 PM → 9:00 PM**

Tools in play: `task` (tasks), `timew` (time tracking), `dijo` (habits),
`jrnl` (journal), `zk` (notes), `uair`/`uairctl` (pomodoro), sesh (sessions).

---

## Day Schedule

```
12:00 – 12:30   Morning ritual      plan top 3, journal, task review
12:30 – 1:30    Call 1
─────────────────────────────────────────────────────────────────────
1:30  – 3:30    Focus Block 1       deep work — hardest task first
3:30  – 4:30    Lunch
─────────────────────────────────────────────────────────────────────
4:30  – 6:30    Focus Block 2       second priority task
6:30  – 7:30    Buffer              reviews, async replies, light admin
7:30  – 8:30    Call 2
─────────────────────────────────────────────────────────────────────
8:30  – 9:00    Wind-down           journal, task close, dijo
```

**Pomodoro rhythm inside each 2-hour focus block:**
```
25m focus → 5m break → 25m focus → 5m break → 25m focus → done
```
3 pomodoros per block. Start each block with:
```sh
task <id> start
uairctl toggle
```

---

## Morning Ritual — before 12:00 PM

Do this before you open any work app. Takes ~10 min.

**1. Review open tasks**
```sh
vit
```
Full interactive view of all pending tasks. Better than `task next` for
planning — you can see everything, filter, and edit in one place.

**2. Check what's overdue and plan your top 3**
Inside vit, filter to overdue tasks:
```sh
vit +OVERDUE
```
Pick 3 tasks max that MUST be done today. Tag them inside vit (`m` to
modify) or from the shell:
```sh
task <id> modify +today
```
Then confirm your today list:
```sh
vit +today
```

**4. Log the journal**
```sh
jrnl
```
Write 2–3 lines: what you're starting with, what you want to accomplish, how you feel. Keep it short.

**5. Mark your habit check-in**
```sh
dijo
```
Log yesterday's habits if you haven't. Then close it.

---

## Starting Work — 12:00 PM (Day Start)

Sketchybar will fire a notification at 12:30 PM as a nudge. Aim to be at your desk by 12:00.

**1. Start your first focus session**

Start the pomodoro timer:
```sh
uairctl toggle
```
25 min work, 5 min break. The `○ 24m 30s` counter appears in your sketchybar.

**2. Start tracking by starting a task**

`task start` automatically fires `timew start` via the on-modify hook —
no separate timew command needed:
```sh
task <id> start
```
The timew pill in sketchybar goes live instantly, labelled with the
task description and project. Stop tracking by stopping or completing:
```sh
task <id> stop   # pause work, keep task pending
task <id> done   # complete it (also stops timew)
```

**3. Open your project session**

`prefix+P` → pick the project → 4 windows open (shell · claude · git · run).

Or pick any named session:
`prefix+s` → fuzzy search → enter.

---

## Lunch Break — 3:30 PM (halfway point)

A hard stop mid-afternoon to prevent drift. Takes 5 min.

**1. Stop the current task and check how time was spent**
```sh
task <id> stop
timew summary :day
```
Are you spending time where you planned?

**2. Check task progress**
```sh
vit +today
```
How many of your top 3 are done? Adjust if needed — edit inline with `m`.

**3. Take a proper break**
Step away from the screen. 10–15 min. No phone. Return, then restart:
```sh
task <id> start
uairctl toggle
```

---

## Evening Wind-Down — 8:30 PM (30 min before checkout)

Sketchybar fires a notification at 9:00 PM. Start winding down at 8:30.

**1. Stop the current task**
```sh
task <id> stop
```

**2. Mark completed tasks done**
```sh
task <id> done
```

**3. Push anything incomplete to tomorrow**
```sh
task <id> modify due:tomorrow
```
Or just leave it — `task next` will surface it tomorrow automatically.

**4. Review the day's time log**
```sh
timew summary :day
```
See where your time actually went vs where you intended it.

**5. Journal the close**
```sh
jrnl
```
Write what you shipped, what blocked you, one thing to carry forward. 3–5 lines.

**6. Log habits**
```sh
dijo
```
Track today's habits before you close the machine.

---

## Weekly Ritual — Friday (or last working day of week)

Takes ~30 min. Block it in your calendar.

**1. Review the full week's time**
```sh
timew summary :week
```
Which projects got the most time? Does it match where you wanted to focus?

**2. Review all tasks**
```sh
vit
```
Scan everything pending. Use `D` to delete stale tasks, `m` to
reschedule — all without leaving vit.

**3. Purge or reschedule stale tasks**
Inside vit: `D` to delete, `m` → modify due date. Or from shell:
```sh
task <id> delete
task <id> modify due:someday
```

**4. Check habit streaks**
```sh
dijo
```
See where streaks broke. No guilt — just notice and reset.

**5. Write a weekly journal entry**
```sh
jrnl weekly
```
Or just open jrnl and prefix with `[weekly]`. Cover:
- What shipped
- What didn't and why
- One thing to do differently next week

**6. Plan next week's top 3**
```sh
task add "next week goal" due:monday
```

---

## Pomodoro Mechanics

| Command | What it does |
|---|---|
| `uairctl toggle` | Start / pause the timer |
| `uairctl next` | Skip to next session (work→break or break→work) |
| `uairctl finish` | End the current session early |

The bar shows `○ 24m 30s` while running. At 0 you get a macOS notification.
After the break notification, toggle again to start the next work block.

**Ideal pomodoro rhythm:**
- 25 min focus → `uairctl next` → 5 min break → repeat × 4 → take a longer break (15–20 min)

---

## Task Commands Cheatsheet

```sh
task add "do the thing"                   # add a task
task add "do the thing" due:today +work   # with due date and tag
task next                                  # what to work on now
task <id> start                           # mark as in-progress
task <id> done                            # complete it
task <id> modify due:tomorrow             # push due date
task <id> delete                          # remove it
task overdue                              # what's past due
task +today                               # tasks tagged for today
task +work                                # filter by tag
task summary                              # breakdown by project/tag
```

---

## Time Tracking Cheatsheet

Tracking is driven by taskwarrior — never run `timew start/stop` manually.

```sh
task <id> start           # starts timew automatically (hook)
task <id> stop            # stops timew automatically (hook)
task <id> done            # completes task + stops timew (hook)
timew summary :day        # today's breakdown
timew summary :week       # this week
timew summary :month      # this month
timew tags                # see all labels used
```

---

## Session Navigation Cheatsheet

| Binding | Action |
|---|---|
| `prefix+s` | Fuzzy pick any session |
| `prefix+P` | Pick a project from ~/cp or ~/pp |
| `prefix+K` | Jump to last session |
| `prefix+1..9` | Switch window within session |
| `prefix+\|` | Split pane horizontally |
| `prefix+-` | Split pane vertically |

---

## vit Cheatsheet

Visual interactive taskwarrior — better than `task next` for review sessions.

```sh
vit              # open full task list
vit +today       # filter to today's tasks
vit +work        # filter by tag
vit project:foo  # filter by project
```

Inside vit:

| Key | Action |
|---|---|
| `Enter` | Edit selected task |
| `d` | Mark done |
| `s` | Start task |
| `S` | Stop task |
| `D` | Delete task |
| `u` | Undo |
| `m` | Modify |
| `a` | Add new task |
| `/` | Search / filter |
| `q` | Quit |

---

## jrnl Cheatsheet

```sh
jrnl                          # open editor for a new entry (today)
jrnl "quick note without editor"
jrnl -n 5                     # show last 5 entries
jrnl today                    # show today's entries
jrnl yesterday                # show yesterday's entries
jrnl --edit                   # edit last entry
jrnl @work                    # filter entries tagged @work
jrnl -from "last monday"      # entries since last monday
jrnl -to "yesterday"          # entries up to yesterday
```

Tag anything in an entry with `@tag` — searchable later.

---

## dijo Cheatsheet

```sh
dijo             # open the habit tracker TUI
```

Inside dijo:

| Key | Action |
|---|---|
| `a` | Add a new habit |
| `d` | Delete selected habit |
| `n` / `p` | Next / previous month |
| `k` / `j` | Move up / down |
| `v` | Toggle today's entry |
| `q` | Quit |

Habits are stored in `~/.local/share/dijo/`. Track one habit per meaningful behaviour — don't over-track.

---

## zk Cheatsheet

```sh
zk new "note title"           # create a new note
zk edit --interactive         # fuzzy search and open a note
zk list                       # list all notes
zk list --match "keyword"     # search notes by content
zk list --tag "tag"           # filter by tag
zk graph                      # show note link graph
```

Notes live in `~/Documents/zk`. Use `[[wikilinks]]` inside notes to link them.

---

## The One Rule

**Never leave timew stopped during work hours.**
If the sketchybar timew pill is dark, no task is active. Run `task <id> start`.
The idle-nudge notification fires every 20 min if nothing is running — that's your reminder.
