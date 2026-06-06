# Stubs

Modules under `home/programs/stubs/` are HM modules that exist only as
commented-out templates. Each ships a config skeleton in its
`programs.*` or `xdg.configFile` block; the file gets a TODO comment at
the top explaining what's needed before activation makes sense.

The bodies evaluate to no-ops, so they cost nothing at build time --
they live in version control so the skeleton is easy to find when you
finally have what the tool needs (creds, a cluster, a maildir, etc).

## Activating a stub

1. `home/programs/stubs/<tool>.nix` — uncomment the relevant block, fill
   any PLACEHOLDER values (use sops-nix for anything secret; never inline
   tokens or passwords).
2. If the tool belongs to a `mySystem.home.<tier>` group, wire its
   `programs.<tool>.enable` into `modules/home/<tier>.nix`. Otherwise the
   stub's own `programs.<tool>.enable = true` is enough.
3. Optionally `git mv home/programs/stubs/<tool>.nix home/programs/<tool>.nix`
   and drop it from `home/programs/stubs/default.nix` once the module is
   no longer really a stub.

## Pending stubs

Mail stack (mbsync pulls → notmuch indexes → meli/himalaya read → msmtp sends):

| File | Blocker |
|---|---|
| `mbsync.nix` | IMAP creds via sops-nix; replace PLACEHOLDERs in `accounts.email.accounts.<name>`. |
| `notmuch.nix` | mbsync has pulled at least once; run `notmuch new` after first sync. |
| `meli.nix` | Hand-write `~/.config/meli/config.toml` (no HM module); point at mbsync Maildir. |
| `himalaya.nix` | Add `accounts.email.accounts.<name>.himalaya` block alongside mbsync. |
| `msmtp.nix` | Per-account block paired with mbsync. |

Calendar / contacts (vdirsyncer pulls → khal/khard read):

| File | Blocker |
|---|---|
| `vdirsyncer.nix` | Per-remote pair blocks; run `vdirsyncer discover` once. CalDAV/CardDAV creds via sops-nix. |
| `khal.nix` | vdirsyncer has populated a calendar vdir. |
| `khard.nix` | vdirsyncer has populated a contacts vdir. |

Music stack (mpd daemon + tagger + clients):

| File | Blocker |
|---|---|
| `mpd.nix` | Point `musicDirectory` at your library; flip enable. |
| `ncmpcpp.nix` | MPD running + indexed. |
| `rmpc.nix` | Drop `./rmpc/config.ron` and uncomment xdg.configFile. |
| `wrtag.nix` | Drop `./wrtag/config.toml`. |

Standalone:

| File | Blocker |
|---|---|
| `newsboat.nix` | Populate `urls` list. |
| `restic.nix` | Pick a repo URL; put `RESTIC_PASSWORD` in sops. |
| `wtfutil.nix` | Drop `./wtfutil/config.yml` (use sops for any per-mod creds). |
| `xplr.nix` | Drop `./xplr/init.lua`, or pick lf/yazi as daily driver and delete this stub. |
