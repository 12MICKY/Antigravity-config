#!/bin/bash
set -e

REPO_DIR="$HOME/antigravity-config"
AGENTS_SRC="$HOME/.agents/AGENTS.md"

cp "$AGENTS_SRC" "$REPO_DIR/AGENTS.md"
if [ -d "$HOME/.agents/skills" ]; then
  mkdir -p "$REPO_DIR/skills"
  cp -R "$HOME/.agents/skills/" "$REPO_DIR/skills/"
fi

cd "$REPO_DIR"
git add -A

if git diff --staged --quiet; then
  exit 0
fi

git commit -m "auto-antigravity: $(date '+%Y-%m-%d %H:%M')"
git push
