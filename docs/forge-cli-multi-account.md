# Forge CLIs — using `gh` and `glab` across multiple accounts

This machine has four git identities (see `docs/commit-signing-kt.md` for the full picture). When you start using `gh` and `glab` for repo / PR / MR / key management from the command line, you immediately hit the question: *which account does this command run as?*

The answer is different for the two tools because the underlying problem is different.

- `gh` has **two accounts on the same host** (`github.com`): personal `irfan-nawaz` and work `irfan-ga`. GitHub can't tell them apart from the hostname alone, so `gh` keeps both tokens and lets you pick which is "active" at any moment.
- `glab` has **two different hosts**: `gitlab.com` (account `inawaz.ctr`) and `git.geekyants.com` (account `irfan.nawaz`). One account per host means `glab` doesn't need a concept of "active account" at all — the host fully determines the credentials.

The rest of this doc explains how each tool's model works and the workflow patterns that fall out of it.

---

## 1. `gh` — same host, two accounts

### How `gh` thinks about accounts

`gh auth login` saves a token in your system keyring tagged with `(host, username)`. You can have many `(host, username)` pairs at once. At any given moment, **one of them is marked Active**. Every `gh` command implicitly uses the Active account's token.

Check current state:

```bash
gh auth status
```

Sample output on this machine:

```
github.com
  ✓ Logged in to github.com account irfan-ga (keyring)
  - Active account: true
  - Git operations protocol: ssh
  - Token: gho_************************************
  - Token scopes: 'admin:public_key', 'admin:ssh_signing_key', 'gist', 'read:org', 'repo'

  ✓ Logged in to github.com account irfan-nawaz (keyring)
  - Active account: false
  ...
```

Two accounts on `github.com`, `irfan-ga` is active right now.

### Switching the active account

```bash
gh auth switch -u irfan-nawaz   # switch to personal
gh auth switch -u irfan-ga      # switch to work
```

After a switch, **every subsequent `gh` command** uses that account until you switch again or restart your shell (the active-account choice is persisted in `~/.config/gh/`, so it survives shell restarts too — you have to actively switch back).

### What "auto-detection inside a repo" does and doesn't do

`gh` does auto-detect *which repo* you mean by reading the git remote of your current directory. So `gh pr list` inside `~/work/some-repo` automatically targets `some-repo` without you having to type the owner/name.

But the **account** still comes from whatever is currently Active. `gh` does **not** look at the remote URL to figure out which of your logged-in accounts should be used. If your active account doesn't have access to the repo your `cwd`'s remote points at, you get a 404 or permission error.

Concretely:

```bash
# Active account is irfan-nawaz (personal).
cd ~/work/some-geekyants-repo   # remote: git@github.com:geekyants/foo.git
gh pr list                       # FAILS — personal account has no access to geekyants/foo

# Fix: switch first.
gh auth switch -u irfan-ga
gh pr list                       # works
```

This is the most common gotcha. The mental model to internalise: **the remote tells `gh` which repo, but you tell `gh` which account**.

### Adding a new account

If you ever need to add a third GitHub account to this setup:

```bash
gh auth login
```

Pick `GitHub.com` → `SSH` → device-code flow. `gh` will detect that you already have other accounts logged in and add the new one alongside them. Then `gh auth switch -u <new-account>` to use it.

### Per-command override (advanced, rarely worth it)

There's no first-class `--account` flag, but you can override the token for one invocation with the `GH_TOKEN` env var:

```bash
GH_TOKEN=<paste-token-here> gh pr list
```

This is fiddly because you have to know the raw token. In practice, just use `gh auth switch` — it's two keystrokes.

---

## 2. `glab` — different hosts, one account each

### How `glab` thinks about accounts

`glab auth login --hostname <host>` saves credentials per host in `~/.config/glab-cli/config.yml`. Because each host has exactly one account in this setup, the host fully determines which account is used. There is no "active account" concept and no equivalent of `glab auth switch`.

Check current state:

```bash
glab auth status                          # all hosts
glab auth status --hostname gitlab.com    # one host
```

### Picking the host for a one-off command

Three ways, in increasing order of explicitness:

#### Method A — let `glab` auto-detect from your `cwd`'s git remote

```bash
cd ~/work/some-geekyants-repo   # remote: git@git.geekyants.com:irfan.nawaz/foo.git
glab mr list                     # uses git.geekyants.com automatically
```

This is the everyday path. As long as you're inside a repo whose remote points at a host you're logged into, `glab` figures everything out.

#### Method B — `GITLAB_HOST` environment variable

For commands run **outside any repo** (e.g. creating a brand-new repo, listing all your projects):

```bash
GITLAB_HOST=gitlab.com         glab repo list
GITLAB_HOST=git.geekyants.com  glab repo list
```

This overrides auto-detection and forces `glab` to use the named host's credentials.

#### Method C — full URL in the command

A few `glab` commands accept a full `<host>/<owner>/<repo>` path, which removes all ambiguity:

```bash
glab repo view git.geekyants.com/irfan.nawaz/some-repo
glab repo clone gitlab.com/inawaz.ctr/other-repo
```

### Adding a new host

For a third GitLab instance:

- **gitlab.com**: works out of the box — `glab auth login --hostname <new-gitlab-instance> --git-protocol ssh --web` is enough.
- **Any self-hosted GitLab**: needs a one-time OAuth-app registration on that instance first. Steps are in `docs/commit-signing-kt.md` §9 (search for "Self-hosted GitLab detour"). Summary: register `glab CLI` app under your user settings on the new instance, copy its Application ID, run `glab config set client_id <id> -g --host <host>`, then `glab auth login`.

---

## 3. Quick reference card

| You want to… | Run |
|---|---|
| See all GitHub accounts you're logged into | `gh auth status` |
| See which GitHub account is currently active | `gh auth status` (look for `Active account: true`) |
| Switch to your personal GitHub account | `gh auth switch -u irfan-nawaz` |
| Switch to your work GitHub account | `gh auth switch -u irfan-ga` |
| Create a repo on the active GitHub account | `gh repo create <name> --private` |
| Open a PR for the current repo | `cd <repo>` then `gh pr create` — make sure active account has access |
| Run a `glab` command against gitlab.com | `glab <cmd>` from inside a gitlab.com repo, or `GITLAB_HOST=gitlab.com glab <cmd>` |
| Run a `glab` command against git.geekyants.com | `GITLAB_HOST=git.geekyants.com glab <cmd>`, or `cd` into a git.geekyants.com repo first |
| Create a private repo on git.geekyants.com | `GITLAB_HOST=git.geekyants.com glab repo create <name> --private --defaultBranch main` |
| List MRs in the current repo | `cd <repo>` then `glab mr list` — auto-detects host from remote |
| Add a new SSH key to an account | `gh ssh-key add <pub> --title <name> --type signing` (after switching to the right gh account) **or** `GITLAB_HOST=<host> glab ssh-key add <pub> --title <name> --usage-type signing` |

---

## 4. The one trap to remember

Both tools auto-detect *the repo* from your `cwd`'s git remote. But only `glab` also auto-detects *which account* to use. With `gh`, the active account is a separate switch you have to flip yourself.

So the day you find yourself in a `geekyants/foo` directory and `gh pr list` returns "Could not resolve to a Repository," the fix is almost always `gh auth switch -u irfan-ga` — not anything to do with the repo or the remote URL.

---

## 5. Related docs

- `docs/commit-signing-kt.md` — full KT for the per-identity SSH commit signing setup, including the self-hosted GitLab OAuth registration procedure that `glab` depends on.
- `~/.ssh/config` — the per-host SSH alias setup that makes `git@github-personal:` route to the personal-account key. The forge CLIs don't read this file, but `git push` / `git pull` do.
