# Daily Operating System

Work hours: **12:00 PM → 9:00 PM**

Tools in play: `task` (tasks), `timew` (time tracking), `dijo` (habits),
`jrnl` (journal), `zk` (notes), `uair`/`uairctl` (pomodoro), sesh (sessions).

---

## Morning Ritual — before 12:00 PM

Do this before you open any work app. Takes ~10 min.

**1. Review open tasks**
```sh
task next
```
Shows your highest-priority pending tasks. Scan what today looks like.

**2. Check what's overdue**
```sh
task overdue
```
Anything here needs to be done today or explicitly pushed to tomorrow.

**3. Plan your top 3 for today**
Pick 3 tasks max that MUST be done today. Tag them:
```sh
task <id> modify +today
task next +today
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

**2. Start time tracking**

Always track what you're working on:
```sh
timew start "task name or project"
```
Examples:
```sh
timew start "tzero auth refactor"
timew start "nix config"
timew start "code review"
```
The timew pill in sketchybar goes live instantly.

**3. Open your project session**

`prefix+P` → pick the project → 4 windows open (shell · claude · git · run).

Or pick any named session:
`prefix+s` → fuzzy search → enter.

---

## Mid-Day Ritual — 3:30 PM (halfway point)

A hard stop mid-afternoon to prevent drift. Takes 5 min.

**1. Stop the current timer and check how time was spent**
```sh
timew stop
timew summary :day
```
Are you spending time where you planned?

**2. Check task progress**
```sh
task +today
```
How many of your top 3 are done? Adjust if needed.

**3. Take a proper break**
Step away from the screen. 10–15 min. No phone. Return, then restart:
```sh
uairctl toggle
timew start "afternoon session"
```

---

## Evening Wind-Down — 8:30 PM (30 min before checkout)

Sketchybar fires a notification at 9:00 PM. Start winding down at 8:30.

**1. Stop the timer**
```sh
timew stop
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
task all status:pending
```
Anything stale (no activity for 7+ days)?

**3. Purge or reschedule stale tasks**
```sh
task <id> delete        # if it's no longer relevant
task <id> modify due:someday  # if it's real but not urgent
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

```sh
timew start "label"       # start tracking
timew stop                # stop
timew summary :day        # today's breakdown
timew summary :week       # this week
timew summary :month      # this month
timew tags                # see all labels you've used
timew continue            # resume last interval
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

## The One Rule

**Never leave timew stopped during work hours.**
If the sketchybar timew pill is dark, you're not tracking. Start it.
The 12:30 PM idle-nudge notification fires every 20 min if nothing is running — that's your reminder.
