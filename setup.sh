#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Google Antigravity Environment Bootstrap & Setup
# Optimized for macOS (Darwin) and Linux systems
# -----------------------------------------------------------------------------

set -euo pipefail

# ANSI color escape codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Logging helpers
log_info()    { printf "${BLUE}[INFO]${NC} %s\n" "$1"; }
log_success() { printf "${GREEN}[SUCCESS]${NC} %s\n" "$1"; }
log_warn()    { printf "${YELLOW}[WARN]${NC} %s\n" "$1"; }
log_error()   { printf "${RED}[ERROR]${NC} %s\n" "$1" >&2; }

# Print Banner
printf "${CYAN}${BOLD}"
printf "===================================================\n"
printf "        ANTIGRAVITY ENVIRONMENT BOOTSTRAP         \n"
printf "===================================================\n"
printf "${NC}\n"

# Verify dependencies
for cmd in git python3; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        log_error "Missing required dependency: $cmd"
        exit 1
    fi
done

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENTS_DST="$HOME/.agents"
SETTINGS_PATH="$HOME/.gemini/antigravity-cli/settings.json"

# Step 1: Copy agents instructions and skills
log_info "Synchronizing AGENTS.md rules and active skills..."
mkdir -p "$AGENTS_DST"

if [ -f "$REPO_DIR/AGENTS.md" ]; then
    cp "$REPO_DIR/AGENTS.md" "$AGENTS_DST/AGENTS.md"
    log_success "Workspace rules (AGENTS.md) copied to $AGENTS_DST"
else
    log_error "AGENTS.md not found in repository root!"
    exit 1
fi

if [ -d "$REPO_DIR/skills" ]; then
    rm -rf "$AGENTS_DST/skills"
    cp -R "$REPO_DIR/skills" "$AGENTS_DST/"
    log_success "Custom skills synchronized to $AGENTS_DST/skills"
fi

# Step 2: Configure TUI Statusline
log_info "Configuring active TUI Statusline command..."
STATUSLINE_SCRIPT="$REPO_DIR/statusline-command.sh"

if [ -f "$STATUSLINE_SCRIPT" ]; then
    chmod +x "$STATUSLINE_SCRIPT"
    
    python3 -c "
import json
import os
path = os.path.expanduser('$SETTINGS_PATH')
os.makedirs(os.path.dirname(path), exist_ok=True)
try:
    with open(path, 'r') as f:
        data = json.load(f)
except Exception:
    data = {}
data['statusLine'] = {
    'type': 'command',
    'command': '$STATUSLINE_SCRIPT',
    'enabled': True
}
with open(path, 'w') as f:
    json.dump(data, f, indent=2)
"
    log_success "Statusline successfully pointed to $STATUSLINE_SCRIPT"
else
    log_warn "statusline-command.sh not found. Skipping statusline config."
fi

# Step 3: Register Auto-Sync Watcher (Systemd for Linux, Launchd for macOS)
log_info "Registering file watcher daemon for auto-sync..."
OS_TYPE="$(uname -s)"

if [ "$OS_TYPE" = "Darwin" ]; then
    LAUNCHD_DST="$HOME/Library/LaunchAgents"
    mkdir -p "$LAUNCHD_DST"
    PLIST_FILE="$LAUNCHD_DST/com.thiraphat.antigravity-sync.plist"
    
    # Unload existing agent if loaded
    launchctl unload "$PLIST_FILE" 2>/dev/null || true
    
    # Copy and load new agent
    cp "$REPO_DIR/systemd/com.thiraphat.antigravity-sync.plist" "$PLIST_FILE"
    chmod 644 "$PLIST_FILE"
    
    launchctl load "$PLIST_FILE"
    log_success "macOS Launchd auto-sync agent registered and loaded successfully."
    
elif command -v systemctl >/dev/null 2>&1; then
    SYSTEMD_DST="$HOME/.config/systemd/user"
    mkdir -p "$SYSTEMD_DST"
    
    cp "$REPO_DIR/systemd/sync.service" "$SYSTEMD_DST/antigravity-sync.service"
    cp "$REPO_DIR/systemd/sync.path" "$SYSTEMD_DST/antigravity-sync.path"
    
    systemctl --user daemon-reload
    systemctl --user enable --now antigravity-sync.path
    log_success "Linux Systemd auto-sync watcher registered and enabled successfully."
else
    log_warn "Neither Launchd (macOS) nor Systemd (Linux) daemon manager configured. Skipping auto-sync registration."
fi

printf "\n${GREEN}${BOLD}Bootstrap completed successfully!${NC}\n"
