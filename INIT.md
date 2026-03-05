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
```

Expected:

- `CLAUDE_CONFIG_DIR=/home/<user>/.agents/claude`
- `CODEX_HOME=/home/<user>/.agents/codex`

## Notes

- No symlink is required.
- Existing `~/.claude` and `~/.codex` are preserved if present.
- The script is idempotent and safe to re-run.
