#!/usr/bin/env bash
#
# actmon installer.
# Symlinks the CLI into ~/.local/bin and the slash command into ~/.claude/.
#
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_SRC="$REPO_DIR/bin/actmon"
CMD_SRC="$REPO_DIR/commands/actmon.md"

LOCAL_BIN="$HOME/.local/bin"
CLAUDE_SCRIPTS="$HOME/.claude/scripts"
CLAUDE_COMMANDS="$HOME/.claude/commands"

[[ -f "$BIN_SRC" ]] || { echo "actmon: $BIN_SRC not found" >&2; exit 1; }
[[ -f "$CMD_SRC" ]] || { echo "actmon: $CMD_SRC not found" >&2; exit 1; }

mkdir -p "$LOCAL_BIN" "$CLAUDE_SCRIPTS" "$CLAUDE_COMMANDS"
chmod +x "$BIN_SRC"

safe_link() {
  local src=$1 dst=$2
  if [[ -e "$dst" && ! -L "$dst" ]]; then
    echo "  skipped:   $dst exists and is not a symlink — leaving alone" >&2
    return 0
  fi
  ln -sfn "$src" "$dst"
  echo "  installed: $dst -> $src"
}

echo "installing actmon..."
safe_link "$BIN_SRC" "$LOCAL_BIN/actmon"
safe_link "$BIN_SRC" "$CLAUDE_SCRIPTS/actmon"
safe_link "$CMD_SRC" "$CLAUDE_COMMANDS/actmon.md"
echo "done."
echo

case ":$PATH:" in
  *":$LOCAL_BIN:"*)
    echo "try it: actmon"
    ;;
  *)
    cat <<'EOF'
warning: ~/.local/bin is not in your PATH.
  add this to your shell config (~/.zshrc or ~/.bashrc):
    export PATH="$HOME/.local/bin:$PATH"
  then run: actmon
EOF
    ;;
esac
echo "in Claude Code: /actmon"
