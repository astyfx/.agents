# Init On A New Device

## 1) Clone

```bash
git clone git@github.com:astyfx/.agents.git ~/.agents
cd ~/.agents
```

## 2) Run bootstrap

```bash
bash scripts/init.sh
```

## 3) Reload shell

```bash
# zsh
source ~/.zshrc

# bash
source ~/.bashrc

# fallback
source ~/.profile
```

## 4) Verify

```bash
echo "$CLAUDE_CONFIG_DIR"
echo "$CODEX_HOME"
perl -MJSON::PP -e 'print "perl + JSON::PP OK\n"'
```

Expected:

- `CLAUDE_CONFIG_DIR=/home/<user>/.agents/claude`
- `CODEX_HOME=/home/<user>/.agents/codex`

## Notes

- `~/.claude` and `~/.codex` should be symlinks to `~/.agents/claude` and
  `~/.agents/codex`.
- Existing `~/.claude` and `~/.codex` are migrated into `~/.agents` and then
  replaced with symlinks.
- The script is idempotent and safe to re-run.
- **Runtime dependency**: the bootstrap and several hooks use `perl` with the
  `JSON::PP` module (the harness is Python-free, not dependency-free). `perl` +
  `JSON::PP` ship with macOS and most Linux by default; if missing, install Perl
  before running `init.sh`, or the settings merge in step 2 will fail.
- Aside from their bridge policy files, `claude/` and `codex/` under this repo are
  treated as local runtime/state folders.
- `~/.agents/AGENTS.md` is the canonical shared policy for all agents.
- `~/.agents/CLAUDE.md` is Claude-specific supplemental guidance read via the
  `~/.claude/CLAUDE.md` bridge and also when Claude's workspace root is
  `~/.agents`.
- `claude/CLAUDE.md` and `codex/AGENTS.md` should stay as thin runtime entry
  files; the Claude bridge loads `~/.agents/AGENTS.md` and `~/.agents/CLAUDE.md`.
