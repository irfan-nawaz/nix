# Multi-forge SSH commit signing — knowledge transfer

This document is the end-to-end story of how this machine ended up signing every git commit with the correct SSH key for whichever forge that commit belongs to. It is written as if you have never touched any of this before. The goal is: if everything got wiped tomorrow, you (or future-me) could redo the whole thing from this page alone.

The work covered here corresponds to two audit findings from earlier:
- **L.4** — per-identity SSH commit signing across all 4 forges
- **L.7** — declarative `/etc/nix/nix.custom.conf`

Both are now done and verified on `2026-05-24`.

---

## 1. The big picture, in one paragraph

You have four different "you"s on the internet — a personal GitHub, a work GitHub, a work self-hosted GitLab, and a client GitLab on gitlab.com. Each of those four accounts has its own email address and its own SSH key on disk. When you make a commit, git can attach a **cryptographic signature** to that commit using one of those SSH keys. The forge (GitHub or GitLab) then shows a green **Verified** badge if the signature lines up with a key it has on file under the right account. Before this work, your laptop was using the *same one* SSH key to sign every commit — regardless of which forge the commit was destined for. That meant commits pushed to three out of four forges showed up as "Unverified" forever, because those forges had never seen that key. This work makes your laptop use the **right key for the right forge, automatically, based on the remote URL of the repo**.

If that sentence made sense, the rest of this document is just the details. If not, the next few sections explain every piece.

---

## 2. Background: what is "commit signing" anyway?

A git commit is, internally, a small text object stored in the repo. By default it just contains: who made it (your name + email), when, what changed, and what the previous commit was. Nothing about that proves *you* actually made it — anyone can put any name and email on a commit. If I set my git config to `user.email = "linus@torvalds.com"` and commit something, git won't stop me, and GitHub will happily show "Linus Torvalds" as the author. That's been the case since git was invented.

**Commit signing** fixes this. When signing is turned on, git takes the commit object and runs it through a cryptographic signing operation using a private key that only you have. The result — the signature — gets attached to the commit. The signature travels with the commit forever, in every clone of the repo. When you push the commit to a forge, the forge takes the public half of your key (which it stores in your account settings), checks the signature against it, and if it all lines up: green "Verified" badge. If somebody steals your laptop but doesn't have your SSH key passphrase, they can still commit, but the signature will be missing or wrong, and the badge won't appear. So the badge is a way for people reading your commits to know they really came from you.

Git supports three signing formats: GPG (old, complex), X.509 (corporate PKI), and **SSH** (newest, simplest — same keys you already use for `git push`). We use SSH because the keys already exist for authentication; we just reuse them for signing too.

### Authentication key vs signing key — easy mix-up

When people say "SSH key for git" they could mean two different things:

- **Authentication key**: the SSH private key that lets `git push` and `git pull` work. The forge's SSH server uses it to identify your account during the connection. Without it, you can't push code at all.
- **Signing key**: the SSH private key that git uses at *commit time* to attach a signature to the commit object. Different stage entirely — happens on your laptop before any network call.

The same SSH keypair can fill **both roles**. Both GitHub and GitLab let you register the same public key twice (or with a single "Authentication & Signing" usage type) so it works for both purposes. This is what we do — one keypair per identity, doing both jobs. The alternative is two separate keypairs per identity (one for auth, one for signing). That's a stronger security posture in theory but doubles the number of keys to rotate and back up, and the realistic compromise scenario for a solo developer is "laptop's `~/.ssh/` directory is read by malware", which exposes everything anyway. So one keypair per role is the pragmatic default and that's what we picked.

### How GitHub and GitLab decide whether a signature is "Verified"

Important to understand because the rules are different:

- **GitHub** (with default settings): the signature is cryptographically valid against any SSH key registered on the account whose user is the commit author. That's it. The committer email doesn't have to match anything special. If you turn on **Vigilant Mode** in GitHub settings, GitHub additionally requires the committer email to match one of the verified emails on your account.
- **GitLab** (always, no toggle): the signature must be valid against an SSH key registered on the account, **and** the committer email must match a verified email on that same account. Both conditions, no exceptions. This is stricter than GitHub.

The consequence: a commit signed with key A but authored under email B will be Verified on GitHub (default mode) but Unverified on GitLab. So if you push the same commit to both forges, it could show Verified on one and Unverified on the other. This is what was happening before this work — the github-geekyants key was signing everything, including commits pushed to GitLab as a totally different identity, and GitLab silently said "Unverified".

---

## 3. The four identities

This machine has four different git identities. Each one is a (forge URL + account username + email + SSH keypair) bundle.

| Remote URL prefix | Forge + Account | Committer email | SSH key on disk |
|---|---|---|---|
| `git@github-personal:` | GitHub.com / `irfan-nawaz` | `shaikmd.irfannawaz2020@gmail.com` | `~/.ssh/id_ed25519_github_personal` |
| `git@github.com:` | GitHub.com / `irfan-ga` (work) | `irfan.nawaz@geekyants.com` | `~/.ssh/id_ed25519_github_geekyants` |
| `git@git.geekyants.com:` | self-hosted GitLab / `irfan.nawaz` | `irfan.nawaz@geekyants.com` | `~/.ssh/id_ed25519_gitlab_geekyants` |
| `git@gitlab.com:` | GitLab.com / `inawaz.ctr` (client) | `inawaz.ctr@tzero.com` | `~/.ssh/id_ed25519_gitlab_tzero` |

A note on `git@github-personal:` — that's not a real hostname. It's an alias defined in `~/.ssh/config` that routes to `ssh.github.com` over port 443 (so it works on networks that block port 22) and points to the personal SSH key. You need this kind of alias when you have two GitHub accounts on the same machine, because GitHub's SSH server can't tell the two accounts apart from the connection alone — it identifies the account purely by which SSH key authenticated. The alias lets you say "push this repo *as the personal account*" by setting the remote to `git@github-personal:user/repo.git`.

The other three forges have one account each on this machine, so no alias trick needed — `git@github.com:`, `git@git.geekyants.com:`, `git@gitlab.com:` each map to their respective account because only one key per host is configured.

---

## 4. What was wrong before

Two specific things:

**Problem 1: same signing key for every commit, regardless of forge.** `home/users/profile.nix` had this single line at the top level of the `programs.git` block:

```nix
signing.key = "~/.ssh/id_ed25519_github_geekyants.pub";
```

That meant every commit on this machine was signed with the work-GitHub key. The four `programs.git.includes` entries did switch `user.name` and `user.email` per remote URL (so the *author* on the commit changed correctly), but they did **not** switch `user.signingkey`. So a commit pushed to `git@gitlab.com:inawaz.ctr/foo.git` would have author `inawaz.ctr / inawaz.ctr@tzero.com` but a signature from the github-geekyants key. GitLab.com would look at that key, see it was not registered on the `inawaz.ctr` account, and silently render the commit as Unverified.

**Problem 2: silent failure mode.** Even if you fixed problem 1 by adding per-include `signingkey`, what happens if a repo's remote URL doesn't match *any* of the four `hasconfig:` patterns? Git would fall back to the global `signing.key` and use the wrong key, silently. There was no way to notice the misconfiguration until you happened to look at the commit's badge on the forge.

---

## 5. What we changed in the code

Three files changed in `~/nix` to fix this.

### 5a. `home/users/profile.nix` — the `programs.git` block

The new shape (simplified):

```nix
programs.git = {
  enable = true;
  signing = {
    format = "ssh";
    signByDefault = true;
    # Fail-loud default: any repo whose remote does NOT match an include
    # below will fail to sign rather than silently signing with the wrong key.
    key = "/dev/null";
  };

  settings = {
    user = {
      name = "irfan-ga";
      email = "irfan.nawaz@geekyants.com";
    };
    init.defaultBranch = "main";
    pull.rebase = true;
    merge.conflictStyle = "diff3";
    gpg.ssh.allowedSignersFile = "~/.config/git/allowed_signers";
  };

  includes = [
    { condition = "hasconfig:remote.*.url:git@github-personal:*/**";
      contents.user = {
        name = "irfan-nawaz";
        email = "shaikmd.irfannawaz2020@gmail.com";
        signingkey = "~/.ssh/id_ed25519_github_personal.pub";
      };
    }
    { condition = "hasconfig:remote.*.url:git@github.com:*/**";
      contents.user = {
        name = "irfan-ga";
        email = "irfan.nawaz@geekyants.com";
        signingkey = "~/.ssh/id_ed25519_github_geekyants.pub";
      };
    }
    { condition = "hasconfig:remote.*.url:git@git.geekyants.com:*/**";
      contents.user = {
        name = "irfan.nawaz";
        email = "irfan.nawaz@geekyants.com";
        signingkey = "~/.ssh/id_ed25519_gitlab_geekyants.pub";
      };
    }
    { condition = "hasconfig:remote.*.url:git@gitlab.com:*/**";
      contents.user = {
        name = "inawaz.ctr";
        email = "inawaz.ctr@tzero.com";
        signingkey = "~/.ssh/id_ed25519_gitlab_tzero.pub";
      };
    }
  ];
};
```

Three things to notice:

1. **`signing.key = "/dev/null"`** is the fail-loud default. `/dev/null` is a special file that exists on every Unix system but is always empty. If git tries to read a signing key from it, it gets nothing, the signing operation fails, and the commit refuses to happen. That's what we want — if no include matched, we'd rather have a loud error than a quietly-wrong signature.
2. Each `includes` entry sets `signingkey` *alongside* `name` and `email`. All three are tied together in one block, so the moment a remote URL matches the `hasconfig:` condition, the right identity (name + email + signing key) gets applied as a unit.
3. The condition shape is `hasconfig:remote.*.url:<host>:*/**` — note the `:*/**` at the end. This is critical and is gotcha #1 from section 7 below.

### 5b. `home/users/profile.nix` — the allowed_signers file

For `git log --show-signature` to verify signatures *locally* on your laptop (so you can see "Good signature" without needing to ask the forge), git needs an "allowed signers" file that maps committer emails to public keys it should trust. Format is one line per identity: `<email> ssh-ed25519 <key-body>`.

This was wired up via `xdg.configFile`:

```nix
xdg.configFile."git/allowed_signers".text = ''
  shaikmd.irfannawaz2020@gmail.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN2ZO1/YR/bAgxPFfWvwLU2oIOljgT684bDT4YOiJVe2
  irfan.nawaz@geekyants.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMo3yIVsdzADsAMg41v4bI4PvmCrurGWTTlQOWzWYWj+
  irfan.nawaz@geekyants.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM2EMJd+smznpvUBuGZBByWhpdauNvbJn46QFhpwzWOb
  inawaz.ctr@tzero.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOs553WHdyGIvsg/7ODUuJps2AuYIo1BjDyvtxDw8eyT
'';
```

That writes `~/.config/git/allowed_signers` with the four entries. Two of them share the email `irfan.nawaz@geekyants.com` (because both your work GitHub and your work GitLab use the same email under the hood) — git is fine with that; it tries every line whose email matches.

The `gpg.ssh.allowedSignersFile = "~/.config/git/allowed_signers"` line in the settings block above tells git where to find this file.

### 5c. `home/users/profile.nix` — the .pub files on disk

This is gotcha #2 from section 7 below: SSH signing reads the **public key file from disk** at the path you set as `user.signingkey`. But `sops-nix` (the secret manager this flake uses) only deploys the **private key halves** — it doesn't deploy the `.pub` files because public keys aren't secrets and don't need encryption. So the `.pub` paths in `signingkey` would point to files that don't exist, and signing would fail with a confusing "no such file" error.

Fix: also deploy the public-key files explicitly via `home.file`. Public keys are not secrets, so it's fine to write the body inline in the Nix file:

```nix
home.file.".ssh/id_ed25519_github_personal.pub".text =
  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN2ZO1/YR/bAgxPFfWvwLU2oIOljgT684bDT4YOiJVe2 github-personal\n";
home.file.".ssh/id_ed25519_github_geekyants.pub".text =
  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMo3yIVsdzADsAMg41v4bI4PvmCrurGWTTlQOWzWYWj+ github-geekyants\n";
home.file.".ssh/id_ed25519_gitlab_geekyants.pub".text =
  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM2EMJd+smznpvUBuGZBByWhpdauNvbJn46QFhpwzWOb gitlab-geekyants\n";
home.file.".ssh/id_ed25519_gitlab_tzero.pub".text =
  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOs553WHdyGIvsg/7ODUuJps2AuYIo1BjDyvtxDw8eyT gitlab-tzero\n";
```

After the next `darwin-rebuild switch`, those four `.pub` files exist on disk alongside the private keys.

### 5d. `hosts/common/darwin.nix` — declarative nix.custom.conf (L.7)

Determinate Nix uses `/etc/nix/nix.custom.conf` as a place for site-local overrides on top of the main `/etc/nix/nix.conf`. Before this change, that file existed on disk but was managed by hand — easy to drift away from what's checked into the repo. Fix: have nix-darwin write the file declaratively from the example in `docs/`:

```nix
environment.etc."nix/nix.custom.conf".source = ../../docs/nix.custom.conf.example;
```

Now `/etc/nix/nix.custom.conf` is a symlink into `/nix/store/...` pointing at the materialised example. Any edit to `docs/nix.custom.conf.example` propagates to the system on the next switch. No drift possible.

### 5e. `modules/packages/dev.nix` — add gh + glab

We needed the GitHub CLI (`gh`) and GitLab CLI (`glab`) to register the signing keys against the forges from the command line. Added them under a clearly-named comment:

```nix
# Forge CLIs (GitHub + GitLab) -- repo / PR / SSH-key management.
gh
glab
```

---

## 6. Activating it — running darwin-rebuild switch

After the code changes, run:

```bash
darwin-rebuild switch --flake ~/nix
```

You may hit one of these speed bumps on the first run:

- **"Operation not permitted" on `/Applications` or similar** — macOS App Management permission needs to be granted to whichever terminal you're running from. Open System Settings → Privacy & Security → App Management, toggle on your terminal app (Terminal/iTerm2/Ghostty/etc), then re-run.
- **"would clobber existing file" for things like `~/.config/atuin/config.toml`** — some tools regenerate their own config files outside home-manager's knowledge, and the next switch refuses to overwrite. Fix: move the offending file to `<path>.before-nix-darwin` and re-run.
- **Sudo password prompt fails because stdin is not a TTY** — in this session we used `echo '<password>' | sudo -S ...`, but normally `darwin-rebuild` handles this itself when run from an interactive terminal.

After the switch succeeds, confirm a few things:

```bash
# The four public-key files exist alongside their private halves.
ls -la ~/.ssh/id_ed25519_*.pub

# The allowed_signers file is materialised.
cat ~/.config/git/allowed_signers

# The global signing key is the fail-loud sentinel.
git config --global --get user.signingkey
# expected output: /dev/null

# nix.custom.conf is now a /nix/store symlink (declarative).
readlink /etc/nix/nix.custom.conf
# expected: a /nix/store/... path
```

---

## 7. The two gotchas that took empirical debugging

These are the non-obvious bits that made the initial config silently broken. Worth burning into memory.

### Gotcha 1: `hasconfig:` patterns need the shape `<host>:*/**`

Git's `hasconfig:` matcher uses a wildcard library called **wildmatch**, and it runs with the `WM_PATHNAME` flag turned on. That flag changes the matching rules:

- A single `*` matches any characters **except `/`**. So `git@github.com:*` matches `git@github.com:user` but does **not** match `git@github.com:user/repo.git` (because of the `/`).
- A double `**` is only meaningful when written as `/**` (preceded by a slash). Bare `**` is treated as one `*` followed by another, and the second one still can't cross `/`. So `git@github.com:**` is essentially `git@github.com:*` and has the same problem.
- The right shape is `<host>:*/**` — read it as "one URL segment, then a slash, then anything at any depth". That matches GitHub's flat `user/repo.git` and GitLab's nested `group/subgroup/repo.git` equally.

If you write the pattern as just `git@github.com:` (no glob at all), it matches the literal string `git@github.com:` and nothing else — which is to say, nothing real. The include never fires. No error message. Just silently never applied. This is what was broken in the initial L.4 attempt and only got noticed when we actually pushed a test commit and saw the wrong key was being used.

To check whether your patterns are matching, from inside a real repo:

```bash
git config --get-all --show-origin user.signingkey
```

If the only line is the global `/dev/null` and not one of the per-identity keys, the include didn't match. Then fix the glob shape.

### Gotcha 2: `.pub` files must exist on disk

This is a more straightforward systems-integration trap. The `ssh-keygen -Y sign` command that git invokes to actually sign a commit needs to **read the public key file from disk** at the path you give in `user.signingkey`. It opens the file, parses out the key, and uses it as part of the signing protocol.

`sops-nix` (the secret-management system this flake uses) only decrypts and deploys the **private** key halves to `~/.ssh/`. It does not deploy public keys, because public keys aren't secrets — there's nothing to encrypt — so it leaves them out as a non-goal.

The consequence: `user.signingkey = "~/.ssh/id_ed25519_github_personal.pub"` points to a file that does not exist on disk. Signing fails with an error like `cannot open '/Users/.../id_ed25519_github_personal.pub'`. Confusing because the private key right next to it works fine for `git push`.

Fix: explicitly create the four `.pub` files via `home.file` (section 5c above). Public-key bodies are safe to inline in Nix source — they're literally designed to be public.

---

## 8. Registering the public keys on each forge

The Nix changes set up the laptop to *sign* commits with the right key. But the forges still need to know that those keys *belong to those accounts*, otherwise no green badge. So for each of the four identities, you have to register the public key on its respective forge account.

For GitHub the CLI workflow is automated. For GitLab the picture is mixed — gitlab.com works out of the box with `glab`; self-hosted GitLab needs a one-time OAuth-app setup first (section 9).

### 8a. GitHub — personal account (`irfan-nawaz`)

```bash
# Switch the active gh account to the personal one if it isn't already.
gh auth switch -u irfan-nawaz

# Upload the public key as a Signing Key (different from Authentication Key —
# the same key can be both, but they're separate registrations).
gh ssh-key add ~/.ssh/id_ed25519_github_personal.pub \
  --title "mac-signing-key-2026" \
  --type signing
```

If your `gh` token doesn't have the `admin:ssh_signing_key` scope, the command will tell you to run `gh auth refresh -h github.com -s admin:ssh_signing_key` first. That triggers the device-code flow (an 8-character code + a URL to paste into your browser).

### 8b. GitHub — work account (`irfan-ga`)

`gh` supports multiple accounts on the same host. If both are already logged in (check with `gh auth status`), switch:

```bash
gh auth switch -u irfan-ga
gh ssh-key add ~/.ssh/id_ed25519_github_geekyants.pub \
  --title "mac-signing-key-2026" \
  --type signing
```

If the second account isn't logged in yet, run `gh auth login` and pick "GitHub.com" + "SSH" + the device-code flow. `gh` will add the second account to its config and let you switch between them.

### 8c. GitLab.com — client account (`inawaz.ctr`)

`glab` ships with gitlab.com's OAuth app pre-registered, so the login flow Just Works:

```bash
glab auth login --hostname gitlab.com --git-protocol ssh --web
```

Press Enter through the prompts (defaults are fine), let the browser open, click **Allow**. Then:

```bash
glab ssh-key add ~/.ssh/id_ed25519_gitlab_tzero.pub \
  --title "mac-signing-key-2026" \
  --usage-type signing
```

In our case the key was *already* on the account from a prior upload as `auth_and_signing`, so the add failed with `fingerprint_sha256 has already been taken` — which is fine; the key is registered for signing already, nothing to do.

### 8d. git.geekyants.com — work self-hosted GitLab (`irfan.nawaz`)

Same `glab ssh-key add` command as gitlab.com, just with `--hostname git.geekyants.com`. **But** before that works, you need to set up `glab`'s OAuth client_id for this host — see section 9.

In our case the key was already registered there as `auth_and_signing` from earlier, so once auth was set up no upload was needed.

---

## 9. The self-hosted GitLab detour — `glab` OAuth setup

Self-hosted GitLab instances don't ship a pre-registered OAuth app for `glab`. Each user has to register one in their own user settings before `glab auth login --web` can work. This is a one-time setup per (user, GitLab host) pair.

### Why this is necessary at all

When `glab auth login --web` runs against gitlab.com, it uses a `client_id` baked into the `glab` source code — that ID corresponds to an OAuth application that the `glab` maintainers registered on gitlab.com once, for everyone's use. Self-hosted instances don't have that pre-registered app, so `glab` has no `client_id` to send. The error you get is:

```
ERROR
Set 'client_id' first with `glab config set client_id <client_id> -g --host <hostname>`.
```

You fix this by registering your own OAuth app on the self-hosted GitLab instance, getting its Application ID, and giving that ID to `glab`.

### Step-by-step

1. Open `https://<your-self-hosted-gitlab>/-/user_settings/applications` in your browser (for us: `https://git.geekyants.com/-/user_settings/applications`).
2. Click **Add new application**.
3. Fill the form exactly:
   - **Name**: `glab CLI` (or anything memorable)
   - **Redirect URI**: `http://localhost:7171/auth/redirect` — this must match `glab`'s hard-coded callback exactly, character-for-character. See aside below for what this URL is.
   - **Confidential**: **uncheck this box**. `glab` uses PKCE (Proof Key for Code Exchange), which is the modern OAuth pattern designed for clients that can't safely store a secret. We don't need or want a client secret.
   - **Scopes**: tick `api`, `read_user`, `read_repository`, `write_repository`. These are the minimum for `glab` to manage SSH keys, list and create projects, and push code.
4. Click **Save application**.
5. The next page shows an **Application ID** (a long hex string) and possibly a **Secret** field. **Copy the Application ID** — that's the value you need. **Ignore the Secret** — we configured this as non-confidential, so the secret isn't used.
6. On your laptop, tell `glab` what the client_id is:

   ```bash
   glab config set client_id <paste-application-id-here> -g --host git.geekyants.com
   ```
7. Now the web login flow works:

   ```bash
   glab auth login --hostname git.geekyants.com --git-protocol ssh --web
   ```

   Press Enter through the prompts. The browser opens, you click **Authorize**, and `glab` reports `Logged in as <username>`.

### What is `http://localhost:7171/auth/redirect`?

It's the address on your own laptop where `glab` listens for the OAuth callback. The flow goes:

1. You run `glab auth login --web`. `glab` starts a tiny web server on your laptop at port `7171`.
2. `glab` opens your browser pointed at GitLab and says "Hi, I'm the `glab` app, the user wants to log in. When you're done, send the result back to `http://localhost:7171/auth/redirect`."
3. You click **Authorize** in the browser.
4. GitLab calls back to `http://localhost:7171/auth/redirect?code=...`. Your laptop's `glab` server catches the callback, exchanges the code for an access token, and shuts the server down.

The whole thing lives and dies in 30 seconds, and only your own laptop can ever reach `localhost:7171` (it's not exposed to the internet — `localhost` literally means "this machine"). GitLab requires you to **pre-declare** which redirect URI is allowed when you register the OAuth app, so a hostile site can't trick GitLab into sending the callback elsewhere. Hence the Redirect URI field must match `glab`'s expected callback exactly.

### A quirk of the interactive flow

`glab auth login --web` is an interactive command — it asks a few prompts (which API protocol, which container registry domains, etc.) and waits for keypresses. It does **not** work when piped into from a non-interactive shell (e.g. via an automation tool). It just hangs forever. So this step has to be run from your own real terminal, not from inside an automation harness. Once it succeeds, the token is saved to `~/.config/glab-cli/config.yml` and subsequent `glab` commands don't need any further interaction.

---

## 10. End-to-end verification

After all the keys were registered, we verified the whole pipeline by pushing one test commit per forge and asking the forge's API whether the signature was accepted.

### The shape of one verification round

```bash
# 1. Create a throwaway private repo on the forge.
gh repo create irfan-ga/signtest-2026 --private              # github
glab repo create signtest-2026 --private --defaultBranch main # gitlab.com
GITLAB_HOST=git.geekyants.com glab repo create signtest-2026 --private --defaultBranch main

# 2. Init a local repo, set the remote with the right URL prefix
#    (which is how the right hasconfig: include gets triggered).
mkdir /tmp/signtest && cd /tmp/signtest && git init sample && cd sample
git remote add origin git@<host>:<owner>/signtest-2026.git

# 3. Make a single signed empty commit and push it.
git commit --allow-empty -m "signing verification test"
git push -u origin HEAD:main

# 4. Confirm locally that the right key was used.
git log -1 --show-signature
# expected: Good "git" signature for <correct-email> with ED25519 key SHA256:...
git config user.signingkey
# expected: ~/.ssh/id_ed25519_<correct-identity>.pub

# 5. Ask the forge's API whether IT accepts the signature.
# GitHub:
gh api repos/<owner>/<repo>/commits/<sha> \
  --jq '{verified: .commit.verification.verified, reason: .commit.verification.reason}'
# expected: {"verified": true, "reason": "valid"}

# GitLab (either):
glab api projects/<urlencoded-path>/repository/commits/<sha>/signature
# expected: {"signature_type": "SSH", "verification_status": "verified", ...}
```

The **local** check (step 4) only proves the allowed_signers file is correct and the key is being read properly. The **API** check (step 5) is the real verification — it proves the forge's verifier recognises the signature, which is what drives the green badge in the web UI.

### Our results

All four forges verified:

| Forge | Test commit | API result |
|---|---|---|
| github.com / `irfan-nawaz` | `e6a46a9` (pushed to the nix repo itself, so no throwaway needed) | Verified |
| github.com / `irfan-ga` | `9e078ac` in `signtest-2026` | `verified: true` |
| gitlab.com / `inawaz.ctr` | `103427a` in `signtest-2026` | `verification_status: verified` |
| git.geekyants.com / `irfan.nawaz` | `23c8c03` in `signtest-2026` | `verification_status: verified` |

### One environmental fixup we hit

When we tried to push to `git.geekyants.com` for the first time from this session, ssh failed with `Host key verification failed.` That's because `~/.ssh/known_hosts` had no entry for `git.geekyants.com`. Fixed by:

```bash
ssh-keyscan -t ed25519,rsa git.geekyants.com >> ~/.ssh/known_hosts
```

This is "trust on first use" — fine in this case because the host is the user's own work GitLab, but in general you should compare the scanned fingerprint against one published by the host operator before adding it.

---

## 11. Cleanup

After verification, three pieces to clean up:

```bash
# 1. The three throwaway signtest-2026 repos on the forges.
gh repo delete irfan-ga/signtest-2026 --yes
glab repo delete inawaz.ctr/signtest-2026 --yes
GITLAB_HOST=git.geekyants.com glab repo delete irfan.nawaz/signtest-2026 --yes

# 2. The local /tmp dir.
rm -rf /tmp/signtest

# 3. The OAuth app on git.geekyants.com can stay — it's tied to your user
#    account and doesn't expire. If you ever want to revoke `glab`'s access
#    on that host, delete the app from
#    https://git.geekyants.com/-/user_settings/applications.
```

The `gh repo delete` command requires the `delete_repo` token scope, which isn't granted by default. If it complains, run `gh auth refresh -h github.com -s delete_repo` first, click through the device-code flow, then retry.

---

## 12. How to do this end-to-end again from scratch

Suppose the laptop dies and you bootstrap a fresh one with this nix flake. The order of operations to get back to the same state:

1. **Run the flake's normal install path** (see `docs/fresh-host-bootstrap.md`). That gets you `darwin-rebuild`, `home-manager`, `sops-nix`, the four private SSH keys deployed via sops, and (because of this work) the four `.pub` files, the allowed_signers file, and the per-identity `programs.git.includes`.
2. **Verify the global signing default is the fail-loud sentinel** — `git config --global --get user.signingkey` should print `/dev/null`. If it doesn't, the `programs.git` block didn't apply correctly; check `home-manager` switch logs.
3. **Verify each public key file exists** — `ls -la ~/.ssh/id_ed25519_*.pub`. Four files.
4. **Verify the allowed_signers file is materialised** — `cat ~/.config/git/allowed_signers`. Four lines.
5. **Register each public key on its forge.** For the two GitHub accounts: `gh auth switch -u <account>` then `gh ssh-key add <pub> --title <name> --type signing`. For gitlab.com: `glab auth login --hostname gitlab.com --git-protocol ssh --web` then `glab ssh-key add <pub> --title <name> --usage-type signing`. For self-hosted git.geekyants.com: register the `glab CLI` OAuth app (section 9), `glab config set client_id ...`, `glab auth login --hostname git.geekyants.com --git-protocol ssh --web`, then `glab ssh-key add` as above.
6. **Verify each forge accepts signatures.** Throwaway repo + empty signed commit + API check, per forge (section 10).
7. **Clean up throwaway repos and /tmp** (section 11).

Total time on a familiar machine: ~30 minutes, most of it spent waiting on browser-based OAuth flows.

---

## 13. Pointers to related files in this repo

- `home/users/profile.nix` — the `programs.git` block, `xdg.configFile."git/allowed_signers"`, and the four `home.file.".ssh/id_ed25519_*.pub"` entries.
- `hosts/common/darwin.nix` — the `environment.etc."nix/nix.custom.conf".source` line that makes Determinate Nix's custom.conf declarative.
- `modules/packages/dev.nix` — the `gh` and `glab` package additions.
- `docs/nix.custom.conf.example` — the source-of-truth for `/etc/nix/nix.custom.conf`.

And the git commits that made the changes:

- `fa1e086` — initial L.4 + L.7 implementation.
- `6062cca` — gotcha fixes: `hasconfig:` glob shape + materialise `.pub` files.
- `e6a46a9` — add `gh` + `glab` to `dev.nix`.

---

**End of document.**
