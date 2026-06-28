#!/bin/bash
set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
AGENTS_DST="$HOME/.agents"

echo "[1/3] AGENTS.md and skills"
mkdir -p "$AGENTS_DST"
cp "$REPO_DIR/AGENTS.md" "$AGENTS_DST/AGENTS.md"
if [ -d "$REPO_DIR/skills" ]; then
  cp -R "$REPO_DIR/skills" "$AGENTS_DST/"
fi

echo "[2/3] statusline configuration"
# Ensure statusline command is executable
chmod +x "$REPO_DIR/statusline-command.sh"

# Update settings.json to point to the repo statusline-command.sh
python3 -c "
import json
path = '$HOME/.gemini/antigravity-cli/settings.json'
try:
    with open(path, 'r') as f:
        data = json.load(f)
except Exception:
    data = {}
data['statusLine'] = {
    'type': 'command',
    'command': '$REPO_DIR/statusline-command.sh',
    'enabled': True
}
with open(path, 'w') as f:
    json.dump(data, f, indent=2)
"

echo "[3/3] auto-sync watcher"
if command -v systemctl >/dev/null 2>&1; then
  mkdir -p "$HOME/.config/systemd/user"
  cp "$REPO_DIR/systemd/sync.service" "$HOME/.config/systemd/user/antigravity-sync.service"
  cp "$REPO_DIR/systemd/sync.path" "$HOME/.config/systemd/user/antigravity-sync.path"
  systemctl --user daemon-reload
  systemctl --user enable --now antigravity-sync.path
  echo "done — all restored and auto-sync active for Antigravity"
else
  echo "systemctl not found (not on Linux), skipping systemd watcher registration."
  echo "done — all restored (run ./sync.sh manually to push changes on macOS)"
fi
