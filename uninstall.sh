#!/usr/bin/env bash
#
# actmon uninstaller. Removes only symlinks created by install.sh.
#
set -euo pipefail

targets=(
  "$HOME/.local/bin/actmon"
  "$HOME/.claude/scripts/actmon"
  "$HOME/.claude/commands/actmon.md"
)

removed=0
for f in "${targets[@]}"; do
  if [[ -L "$f" ]]; then
    rm "$f"
    echo "removed: $f"
    removed=$((removed + 1))
  elif [[ -e "$f" ]]; then
    echo "skipped: $f (not a symlink, leaving alone)"
  fi
done

if [[ $removed -eq 0 ]]; then
  echo "nothing to uninstall."
fi
