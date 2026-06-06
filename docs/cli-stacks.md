# CLI stacks — beginner walkthrough

This document explains how the personal-productivity CLI tooling installed
by `modules/packages/{personal,comms}.nix` actually fits together, and how
to use it day-to-day. It assumes zero prior experience with TUI mail,
calendars, password managers, or audiophile playback.

Conventions in this doc:

- `$` = shell prompt; lines starting with `#` are explanatory comments.
- Paths like `~/.config/<tool>` are macOS user config locations.
- All keyboard shortcuts are listed as they appear in the upstream
  defaults — most tools let you rebind in their config file.

---

## Table of contents

1. [Audiophile music stack (MPD + clients + wrtag)](#1-audiophile-music-stack-mpd--clients--wrtag)
2. [Email (mbsync + notmuch + meli + msmtp + himalaya)](#2-email-mbsync--notmuch--meli--msmtp--himalaya)
3. [Calendar + contacts (vdirsyncer + khal + khard)](#3-calendar--contacts-vdirsyncer--khal--khard)
4. [RSS (newsboat)](#4-rss-newsboat)
5. [TUI browser (w3m)](#5-tui-browser-w3m)
6. [Password manager (1Password CLI)](#6-password-manager-1password-cli)
7. [TOTP fallback (oath-toolkit)](#7-totp-fallback-oath-toolkit)
8. [macOS housekeeping](#8-macos-housekeeping)
9. [Backups (restic)](#9-backups-restic)

> **Important**: HM stub modules now exist at `home/programs/{mbsync,himalaya,
> meli,vdirsyncer,mpd,ncmpcpp,khal,khard,newsboat,wrtag,rmpc}.nix` -- each is
> committed as a commented-out skeleton with a TODO. Uncomment the relevant
> block (and fill PLACEHOLDER values via sops) once you have the upstream
> credentials. The samples below remain useful as a reference for the
> config shape.

---

## 1. Audiophile music stack (MPD + clients + wrtag)

### The pipeline

```
   FLAC / ALAC / DSD files (~/Music/library)
                  │
                  ▼
              MPD daemon  ── output: Core Audio (exclusive mode)
                  │                          │
                  │                          └─► USB DAC (bit-perfect)
                  ▼
          ncmpcpp / rmpc  (TUI clients query MPD over a socket)
```

### Why MPD and not just `cmus`?

- **One library, many clients.** MPD is a daemon. It holds the
  playlist/queue. Any number of clients (ncmpcpp, rmpc, an iOS app on
  your network) all see the same state.
- **Bit-perfect output** to your DAC. macOS by default routes audio
  through its system mixer (resampling, level adjustments). With
  `mixer_type "none"` and `exclusive "yes"` in `mpd.conf`, MPD grabs the
  Core Audio device directly — the bits leaving your Mac match the bits
  in the FLAC/DSD file.
- **Hi-res friendly**: 32-bit/384 kHz PCM and DSD over DoP supported.

### Directory layout

```
~/Music/library/             # your audio files (FLAC/ALAC/MP3/DSD)
~/.config/mpd/mpd.conf       # daemon config (you write this)
~/.local/share/mpd/db        # MPD's library index (auto)
~/.local/share/mpd/log       # MPD's log (auto)
~/.local/share/mpd/state     # last-played state (auto)
```

### Minimal `~/.config/mpd/mpd.conf`

```
music_directory     "~/Music/library"
db_file             "~/.local/share/mpd/db"
log_file            "~/.local/share/mpd/log"
state_file          "~/.local/share/mpd/state"
pid_file            "~/.local/share/mpd/pid"

bind_to_address     "127.0.0.1"
port                "6600"

audio_output {
  type        "coreaudio"
  name        "DAC"
  mixer_type  "none"
  exclusive   "yes"
}

# Optional: format. If unset MPD passes the file's native format.
# Don't force a format here — that's the opposite of bit-perfect.
```

### Starting MPD

For now (until home-manager wires a launchd agent):

```
$ mkdir -p ~/Music/library ~/.local/share/mpd
$ mpd                       # foreground; Ctrl-C to stop
$ mpd --no-daemon            # if you want logs in the terminal
```

A future PR will add `launchd.user.agents.mpd` so it autostarts on login.

### Tagging and importing music with `wrtag`

`wrtag` is a Go-based MusicBrainz tagger — same idea as beets, but
single-binary and faster. We use it because beets' nixpkgs closure is
broken on aarch64-darwin (chromaprint + aacgain).

Minimal workflow:

```
# Inspect what wrtag would do without moving anything:
$ wrtag copy -dry-run ~/Downloads/some-album

# Tag + move into ~/Music/library:
$ wrtag move \
    -path-format '{{ artists .Release.Artists | join ", " }}/{{ .Release.Title }}/{{ printf "%02d" .Track.Position }} - {{ .Track.Title }}' \
    ~/Downloads/some-album

# Tell MPD to rescan after import:
$ mpc update
```

Useful flags:

- `-dry-run` — print what would happen, don't touch files.
- `-yes` — skip confirmations (use after you trust the path format).
- `-keep-files` — leave originals; copy into library.

Config lives at `~/.config/wrtag/config`. See `wrtag --help` for the
full template DSL. For one-off ID3 edits you can also install `id3v2`
or `mid3v2` separately if needed.

> Note: wrtag's nixpkgs test suite expects a case-sensitive
> filesystem; macOS APFS is case-insensitive by default, so the build
> would fail. The repo overlays `wrtag` to skip tests (the binary is
> unaffected). See `hosts/common/darwin.nix`.

### Using `ncmpcpp` (TUI client)

```
$ ncmpcpp
```

Common keys:

| Key   | Action                       |
| ----- | ---------------------------- |
| `1`   | Playlist (current queue)     |
| `2`   | Browse library               |
| `3`   | Search                       |
| `q`   | Quit (MPD keeps playing)     |
| `p`   | Play / pause                 |
| `s`   | Stop                         |
| `>`/`<` | Next / previous track      |
| `a`   | Add highlighted to queue     |
| `c`   | Clear queue                  |
| `Enter` | Play highlighted           |

### Using `rmpc` (modern Rust client)

```
$ rmpc
```

Why try it: gorgeous album art rendered as terminal pixels (works in
Ghostty / Kitty), nicer defaults, vim-style keys.

### One-off playback with `mpv`

For files not yet in the library, or for video / YouTube:

```
$ mpv ~/Downloads/track.flac
$ mpv 'https://www.youtube.com/watch?v=...'
$ mpv --audio-exclusive=yes track.flac    # bit-perfect one-off
```

mpv hotkeys: `space` pause, `9/0` volume, `[/]` speed, `q` quit.

### Apple Music interop (no nix CLI)

There is no nix-packaged Apple Music CLI. If you want a "now playing"
readout from the macOS Apple Music app:

```
$ osascript -e 'tell application "Music" to get name of current track'
$ osascript -e 'tell application "Music" to get artist of current track'
$ osascript -e 'tell application "Music" to playpause'
```

You can wrap these in a shell function in `~/.zshrc`.

---

## 2. Email (mbsync + notmuch + meli + msmtp + himalaya)

### The pipeline

```
                Gmail IMAP                          local Maildir
   Gmail server ───────────► mbsync (from isync) ──────────────► ~/Mail/gmail/
                                                                      │
                                                                      ▼
                                                              notmuch index
                                                                      │
                                       ┌──────────────────────────────┘
                                       ▼
                                     meli  ── compose ──► msmtp ──► Gmail SMTP
                                       ▲
                                       │  (scripts / one-liners)
                                       │
                                    himalaya
```

Five pieces, each doing one thing:

| Piece      | Role                                                  |
| ---------- | ----------------------------------------------------- |
| `mbsync`   | Bi-directional sync between Gmail IMAP and a local Maildir folder (one file per message). |
| `notmuch`  | Indexes the Maildir. Provides fast search + tags.     |
| `meli`     | Modern Rust TUI for reading and composing.            |
| `msmtp`    | Outbound SMTP relay. meli hands a message to msmtp, msmtp talks to Gmail SMTP. |
| `himalaya` | Non-interactive CLI ("send / list / read"). For scripts and shell one-liners, not daily reading. |

### Step 1 — Gmail App Password

Gmail no longer accepts plain passwords for IMAP. You need either an
**App Password** (simpler, what we'll use) or OAuth (more setup).

1. Go to <https://myaccount.google.com/security>.
2. Turn on **2-Step Verification** if it isn't already.
3. Open **App passwords** → name it "macOS mbsync" → copy the 16-char
   password Google shows.
4. Save that password using sops:

   ```
   $ sops secrets/personal.yaml         # add: gmail_app_password: "xxxx xxxx ..."
   ```

   For now (until the home-manager plan wires this), put the password in
   `~/.mbsync-gmail-pass` and `chmod 600` it.

### Step 2 — `~/.mbsyncrc`

```
IMAPAccount gmail
Host              imap.gmail.com
Port              993
User              you@gmail.com
PassCmd           "cat ~/.mbsync-gmail-pass"
SSLType           IMAPS
AuthMechs         LOGIN

IMAPStore gmail-remote
Account           gmail

MaildirStore gmail-local
Subfolders        Verbatim
Path              ~/Mail/gmail/
Inbox             ~/Mail/gmail/INBOX

Channel gmail
Far               :gmail-remote:
Near              :gmail-local:
Patterns          *
Expunge           Both
SyncState         *
Create            Both
```

### Step 3 — First sync

```
$ mkdir -p ~/Mail/gmail
$ mbsync -a       # -a = all channels; first run can take a while
```

You should now have `~/Mail/gmail/INBOX/cur`, `new`, `tmp` etc.

### Step 4 — notmuch index

```
$ notmuch setup    # interactive, point it at ~/Mail
$ notmuch new      # initial index
```

Search examples:

```
$ notmuch search from:invoices
$ notmuch search 'tag:unread and date:7d..'
```

### Step 5 — msmtp for sending

`~/.msmtprc`:

```
defaults
auth           on
tls            on
tls_starttls   on

account        gmail
host           smtp.gmail.com
port           587
from           you@gmail.com
user           you@gmail.com
passwordeval   "cat ~/.mbsync-gmail-pass"

account default : gmail
```

`chmod 600 ~/.msmtprc`.

### Step 6 — meli config

`~/.config/meli/config.toml`:

```toml
[accounts.gmail]
root_mailbox     = "~/Mail/gmail"
format           = "maildir"
identity         = "you@gmail.com"
display_name     = "Your Name"
index_style      = "Conversations"      # threaded view
html_filter      = "w3m -I %{charset} -T text/html -dump"

[accounts.gmail.mailboxes."INBOX"]
[accounts.gmail.mailboxes."[Gmail]/Sent Mail"]
[accounts.gmail.mailboxes."[Gmail]/All Mail"]
[accounts.gmail.mailboxes."[Gmail]/Drafts"]

# Sending. meli has a built-in SMTP client; we use msmtp instead so
# everything else (himalaya, future automation) shares one config.
[accounts.gmail.send_mail]
type             = "smtp"
hostname         = "smtp.gmail.com"
port             = 587
auth             = { type = "auto",
                     username = "you@gmail.com",
                     password = { type = "command",
                                  value = "cat ~/.mbsync-gmail-pass" } }
security         = { type = "STARTTLS" }

[composing]
send_mail        = "shell-command"
mailer_cmd       = "/run/current-system/sw/bin/msmtp -t"
editor_command   = "nvim"
```

Launch:

```
$ meli
```

Common keys: `?` help, `j/k` next/prev, `Enter` open thread, `M`
compose new, `r` reply, `R` reply-all, `d` delete, `s` save (move),
`Tab` switch account/folder, `/` search, `:` command-line.

Threaded view, mouse support, and themes work out of the box.

### Step 7 — HTML email rendering

The `html_filter = "w3m -I %{charset} -T text/html -dump"` line in the
config above is all you need — meli pipes HTML parts through `w3m`
automatically when a message has no plain-text alternative. No
`~/.mailcap` plumbing required.

### Step 8 — Schedule mbsync (deferred)

A future home-manager PR will install a launchd agent running
`mbsync -a` every 5 minutes. For now, run it manually or alias it:

```
alias mailsync='mbsync -a && notmuch new'
```

### Optional upgrade: OAuth via `lieer`

If you ever want to drop App Passwords (Google may deprecate them), the
`lieer` tool syncs Gmail via the Gmail API + OAuth instead of IMAP. It's
installed; setup is `gmi init you@gmail.com` followed by browser
consent. Pairs with notmuch the same way.

### Scripted mail via `himalaya`

`himalaya` is *not* a TUI — it's a `git`-style CLI for mail. Use it
alongside meli when you want non-interactive workflows: cron jobs,
shell prompts, "send this file as an email" one-liners.

`~/.config/himalaya/config.toml`:

```toml
[accounts.gmail]
default          = true
email            = "you@gmail.com"
display-name     = "Your Name"

backend          = "maildir"
maildir.root-dir = "~/Mail/gmail"

message.send.backend = "smtp"
smtp.host        = "smtp.gmail.com"
smtp.port        = 587
smtp.encryption  = "start-tls"
smtp.login       = "you@gmail.com"
smtp.auth        = { type = "passwd", cmd = "cat ~/.mbsync-gmail-pass" }
```

Daily commands:

```
$ himalaya envelope list                       # latest in INBOX
$ himalaya envelope list -f '[Gmail]/All Mail'
$ himalaya message read 42                     # by index
$ himalaya message send < draft.eml            # send raw RFC 5322
$ himalaya message attachments 42 -d ~/Downloads
```

Useful shell snippet — unread-count for your zsh prompt or tmux
status bar:

```sh
unread() {
  himalaya envelope list -f INBOX --filter 'flag unseen' 2>/dev/null \
    | awk 'END{print NR}'
}
```

Send a file as an attachment in one line:

```
$ himalaya message send \
    --to friend@example.com \
    --subject 'logs' \
    --attachment /tmp/output.log \
    --body 'See attached.'
```

---

## 3. Calendar + contacts (vdirsyncer + khal + khard)

### The pipeline

```
   Google CalDAV ──┐
                   ├─► vdirsyncer ──► ~/.local/share/vdirsyncer/{cal,contacts}
   (Fastmail etc.)─┘                            │
                                                ├──► khal  (TUI calendar)
                                                └──► khard (TUI address book)
```

`vdirsyncer` is a generic CalDAV/CardDAV sync engine. It writes the
remote calendar and contacts into a local "vdir" (a directory of
`.ics` and `.vcf` files). khal and khard read that vdir.

### Step 1 — Google CalDAV App Password

Reuse the same App Password mechanism as Gmail (a single App Password
works for IMAP + CalDAV + CardDAV).

### Step 2 — `~/.config/vdirsyncer/config`

```
[general]
status_path = "~/.local/share/vdirsyncer/status/"

# ---------- calendar ----------
[pair my_calendar]
a = "calendar_local"
b = "calendar_remote"
collections = ["from a", "from b"]
metadata = ["color", "displayname"]
conflict_resolution = "b wins"

[storage calendar_local]
type = "filesystem"
path = "~/.local/share/vdirsyncer/calendars/"
fileext = ".ics"

[storage calendar_remote]
type = "google_calendar"
token_file = "~/.local/share/vdirsyncer/google_calendar_token"
client_id = "<your-client-id>"
client_secret = "<your-client-secret>"

# ---------- contacts ----------
[pair my_contacts]
a = "contacts_local"
b = "contacts_remote"
collections = ["from a", "from b"]

[storage contacts_local]
type = "filesystem"
path = "~/.local/share/vdirsyncer/contacts/"
fileext = ".vcf"

[storage contacts_remote]
type = "google_contacts"
token_file = "~/.local/share/vdirsyncer/google_contacts_token"
client_id = "<your-client-id>"
client_secret = "<your-client-secret>"
```

> Google's CalDAV access has shifted toward OAuth — vdirsyncer's
> `google_calendar` storage handles it. You'll create an OAuth client at
> <https://console.cloud.google.com> (CalDAV API + People API enabled).
> First-run `vdirsyncer discover` opens a browser for consent.

If you prefer App Password + plain CalDAV (still supported by Google as
of writing), swap `google_calendar` for `caldav` and point it at
`https://apidata.googleusercontent.com/caldav/v2/your_email/events`.

### Step 3 — First sync

```
$ vdirsyncer discover
$ vdirsyncer sync
```

### Step 4 — khal

```
$ khal configure        # walks you through config
$ khal list today 7d    # next 7 days
$ khal calendar         # month view
$ khal new              # create event interactively
```

### Step 5 — khard

```
$ khard list
$ khard show 0
$ khard new
$ khard email john      # search by name fragment
```

meli has no built-in address-book integration today, but you can use
khard from the compose buffer via shell escape:

```
:!khard email <fragment>
```

Or from outside meli, look someone up:

```
$ khard email john     # search by name fragment, prints rfc-5322 lines
```

### Step 6 — Schedule (deferred)

Future home-manager PR adds a launchd agent: `vdirsyncer sync` every
15 minutes.

---

## 4. RSS (newsboat)

### Subscriptions

`~/.config/newsboat/urls` — one URL per line:

```
https://news.ycombinator.com/rss          "~Hacker News"  hn
https://this-week-in-rust.org/rss.xml     "~TWiR"         rust
https://rachelbythebay.com/w/atom.xml     "~rachelbythebay"
```

The `~Name` part is the display title. Words after that are tags.

### Running

```
$ newsboat       # first run downloads all feeds
```

Keys:

| Key   | Action                  |
| ----- | ----------------------- |
| `R`   | Reload all feeds        |
| `r`   | Reload current feed     |
| `Enter` | Open feed / article   |
| `o`   | Open article in browser |
| `A`   | Mark feed read          |
| `n`   | Next unread             |
| `q`   | Back / quit             |

### Import from another reader

Export OPML from Feedly/Inoreader/etc., then:

```
$ newsboat -i feeds.opml
```

---

## 5. TUI browser (w3m)

w3m is installed primarily so meli can render HTML email parts inline
(via `html_filter` in meli's config — see section 2, step 6). You can
also use it as a browser:

```
$ w3m https://news.ycombinator.com
```

Keys: `Tab` next link, `Enter` follow, `B` back, `q` quit, `/` search.

---

## 6. Password manager (1Password CLI)

You already have 1Password (desktop + CLI) installed. We'll use the CLI
for everything — but we leverage the desktop app for Touch ID unlock so
you never type a master password.

### One-time setup

1. Open the 1Password desktop app.
2. Settings → **Developer** → enable
   **Integrate with 1Password CLI**.
3. (Same panel) enable **Biometric unlock for 1Password CLI**.
4. In a shell:

   ```
   $ op signin
   ```

   Touch ID prompt appears. After this, every `op` command auto-prompts
   Touch ID; no master password.

### Daily commands

```
$ op item list                            # everything in all vaults
$ op item list --vault Personal
$ op item get gmail                       # full record
$ op item get gmail --field password      # password only
$ op item get gmail --otp                 # 6-digit TOTP
$ op item get gmail --fields username,password,one-time password

# create a new login
$ op item create --category=login \
                 --title='Acme Corp' \
                 --vault=Personal \
                 --url=https://acme.example \
                 username=me@example.com \
                 password='generate'   # 'generate' = let 1Password create a strong one

# secret references — paste this anywhere instead of the real password
$ op read 'op://Personal/gmail/password'
```

### TOTP — replace Google Authenticator

When you set up 2FA on a site:

1. Site shows a QR code or a secret string.
2. In 1Password CLI:

   ```
   $ op item edit gmail \
       'one-time password=otpauth://totp/Google:you@gmail.com?secret=ABCDEF...&issuer=Google'
   ```

   Or use the desktop app to scan the QR and save it on the item.
3. Future codes:

   ```
   $ op item get gmail --otp
   ```

This replaces Google Authenticator / Authy. Codes sync across all your
devices via 1Password.

### Useful aliases for `~/.zshrc`

```
alias opg='op item get'
alias opotp='op item get --otp'
alias oppw='op item get --field password'
```

### Using secrets in shell scripts

```
# Never hard-code secrets in dotfiles. Use op read:
export AWS_ACCESS_KEY_ID=$(op read 'op://Personal/aws-prod/access-key-id')
export AWS_SECRET_ACCESS_KEY=$(op read 'op://Personal/aws-prod/secret')

# Or inject into a single command:
op run --env-file=.env -- terraform plan
```

---

## 7. TOTP fallback (oath-toolkit)

For services whose TOTP seed you don't want to store in 1Password
(e.g., a recovery code generator that should be cold-stored), use
`oathtool`:

```
$ oathtool --totp -b ABCDEFGHIJKLMNOP
482931                              # current 6-digit code
```

The seed (`-b` = base32) typically appears on the QR code's setup page
as "Can't scan? Type this key manually".

Wrap as a script in `~/.local/bin/totp`:

```sh
#!/bin/sh
# usage: totp SERVICE
seed=$(cat ~/.secrets/totp/"$1")
oathtool --totp -b "$seed"
```

Then `chmod 700 ~/.secrets`, `chmod 600 ~/.secrets/totp/*`. (Or, better,
store the seed file via sops too.)

---

## 8. macOS housekeeping

### `pinentry_mac`

GPG and `pass` need a way to prompt for passphrases. `pinentry_mac` is
the native macOS prompt. After the home-manager PR wires it, the GPG
agent will pop a native sheet whenever it needs your key passphrase. For
now, set it in `~/.gnupg/gpg-agent.conf`:

```
pinentry-program /run/current-system/sw/bin/pinentry-mac
```

Then `gpgconf --reload gpg-agent`.

### `rmtrash` — safer `rm`

Moves files to macOS Trash instead of `unlink`-ing them. Add to
`~/.zshrc` if you want it as default:

```
alias rm='rmtrash'                # opt-in safety net
alias rmf='/bin/rm'               # bypass when you really mean it
```

### Apple Music now-playing

See section 1's "Apple Music interop" — `osascript` one-liners.

---

## 9. Backups (restic)

`restic` is an encrypted, incremental, deduplicating backup tool.
Repositories live on S3, Backblaze B2, a local disk, or any rclone
remote.

Minimal first-time setup against B2:

```
$ export B2_ACCOUNT_ID=$(op read 'op://Personal/backblaze/account-id')
$ export B2_ACCOUNT_KEY=$(op read 'op://Personal/backblaze/account-key')
$ export RESTIC_REPOSITORY=b2:mybucket:/restic
$ export RESTIC_PASSWORD=$(op read 'op://Personal/restic/password')

$ restic init                              # one-time
$ restic backup ~/Documents ~/Code         # first snapshot
$ restic snapshots                         # list
$ restic restore latest --target /tmp/r    # restore latest snapshot
```

Schedule the backup via launchd (deferred to home-manager).

---

## What's deferred

Everything in this doc assumes you wrote the config files by hand. The
follow-up home-manager PR will:

- Render `mpd.conf`, `mbsync`, `msmtp`, `notmuch`, `meli`, `himalaya`, `vdirsyncer`,
  `khal`, `khard`, `newsboat` configs from Nix.
- Wire launchd agents for `mpd`, `mbsync -a`, `vdirsyncer sync`,
  `restic backup`.
- Decrypt Gmail App Password / Google OAuth tokens / restic key from
  `secrets/personal.yaml` via sops.
- Provide `programs.gnupg.agent.pinentryPackage = pkgs.pinentry_mac;` so
  GPG/pass work without manual config.

Until then this doc is the source of truth for hand-rolling each tool.
