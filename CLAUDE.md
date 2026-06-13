# CLAUDE.md — nix-darwin config

Project context for Claude Code. Read this before making changes.

---

## What this is

nix-darwin + home-manager configuration for two Apple Silicon Macs:

| Host | Machine | Notes |
|---|---|---|
| `irfan-personal` | M4 Pro 48 GB | Primary workstation; also runs dolphin3:70b |
| `shaikmdirfannawaz` | Work laptop | Shared subset; no 70b model config |

Single flake at `~/nix`. Both hosts share `hosts/common/darwin.nix` and
`home/programs/` modules; per-host divergence lives in
`hosts/darwin/<host>/extras.nix` and `home/users/<username>.nix`.

---

## Key commands

```sh
just build          # build irfan-personal closure (default host)
just switch         # activate irfan-personal (requires sudo)
just build shaikmdirfannawaz   # build other host
just switch shaikmdirfannawaz  # activate other host

just check          # nix flake check --show-trace (all hosts + treefmt)
just fmt            # nix fmt (nixfmt-rfc-style + statix + deadnix)
just update         # nix flake update (all inputs)
just gc             # nix-collect-garbage --delete-older-than 14d
```

Prefer `just build` before `just switch` to catch eval errors without
activating. `just nh-build` is a lighter dry-run via `nh` (no sudo).

---

## Architecture

```
flake.nix
├── hosts/
│   ├── common/darwin.nix        # shared system config (launchd, fonts, sops, defaults)
│   └── darwin/<host>/
│       ├── default.nix          # sets networking.hostName, imports extras
│       └── extras.nix           # per-host system overrides (usually empty)
├── home/
│   ├── users/<username>.nix     # per-user HM config (colima RAM, 70b aliases, etc.)
│   ├── users/profile.nix        # shared HM imports (nix-index-database, etc.)
│   └── programs/                # one file per tool (86 modules)
│       ├── default.nix          # imports all program modules
│       └── stubs/               # commented-out skeletons awaiting activation
├── modules/packages/            # system packages by category (11 files)
│   ├── base.nix  dev.nix  k8s.nix  cloud.nix  iac.nix
│   ├── network.nix  security.nix  observability.nix
│   └── productivity.nix  personal.nix  comms.nix
├── lib/
│   └── mkdarwin.nix             # shared host builder (nixpkgs.config, overlays)
└── docs/                        # reference docs (16 files)
```

---

## Conventions

### Adding a system package

Put it in the appropriate `modules/packages/<category>.nix` file.
It goes into `environment.systemPackages` and is available on both hosts.

### Adding a home-manager program

1. Create `home/programs/<tool>.nix` with `{ pkgs, lib, ... }: { programs.<tool> = { ... }; }`
2. Add `./tool.nix` to `home/programs/default.nix` imports
3. If the tool needs to diverge per-host, add the override in `home/users/<username>.nix`

### Per-host config

- System-level overrides: `hosts/darwin/<host>/extras.nix`
- HM-level overrides: `home/users/<username>.nix` (use `lib.mkForce` for lists)

### Stubs

`home/programs/stubs/` holds commented-out skeletons for tools that need manual
one-time setup (mail credentials, calendar auth, etc.). See `docs/stubs.md`.
Never delete stubs — uncomment and fill placeholders when ready to activate.

---

## Security rules

- **Never commit unencrypted secrets.** Secrets go through sops-nix (age-encrypted).
- New secrets: follow `docs/fresh-host-bootstrap.md` + `docs/secret-rotation.md`.
- API keys (ANTHROPIC_API_KEY, OPENAI_API_KEY, etc.) are exported from sops secrets,
  never pinned in nix files.
- `secrets/secrets.yaml` is the encrypted store; `secrets/secrets.yaml.dec` must
  never be committed.

---

## Known gotchas

**Determinate Nix** (`nix.enable = false` in darwin.nix)
: nix-darwin must not fight Determinate's daemon. All `nix.*` options in darwin.nix
  are inert. Substituters, trusted-users, and experimental-features live in
  `/etc/nix/nix.custom.conf` (see `docs/nix.custom.conf.example`).

**statix W20 `repeated_keys` suppressed**
: The project uses dot-notation paths (`foo.bar = x; foo.baz = y`) intentionally
  throughout. `statix.toml` at the repo root disables this check so pre-commit
  hooks stay clean. All other statix checks are active.

**Ollama models are imperative**
: Models (~5–40 GB) are too large for the Nix store. After each rebuild, pull
  manually: `ollama pull dolphin3:8b && ollama create personal -f ~/.config/ollama/Modelfile.personal`.
  The daemon auto-starts via launchd; the `llm-ollama` plugin installs via `home.activation`.

**HM module vs system package**
: Tools with declarative settings go in `home/programs/` (HM module).
  Tools that are just binaries go in `modules/packages/` (system package).
  Some tools need both (e.g. `ollama` binary in dev.nix, settings in `home/programs/ollama.nix`).

**continue.dev / oterm / VS Code**
: Cursor reads extensions from `~/.cursor/extensions/` which is symlinked to
  `~/.vscode/extensions/` by a `home.activation` script in `home/programs/vscode.nix`.
  If Cursor doesn't see extensions after rebuild, run `darwin-rebuild switch` again
  to re-run the activation.

**Sketchybar color env vars**
: All Catppuccin Mocha colors are exported at the top of `sketchybarrc`
  (`BAR_BG`, `FG`, `DIM`, `ACCENT`, `SURFACE`, `RED`, `GREEN`, `SKY`, `MAUVE`,
  `YELLOW`, `PEACH`). Plugin scripts inherit these — reference `$SKY` not `0xff89dceb`.
