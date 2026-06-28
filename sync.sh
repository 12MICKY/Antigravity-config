#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Google Antigravity Configuration Synchronizer
# Automates staging, committing, and pushing rules/skills to GitHub
# -----------------------------------------------------------------------------

set -euo pipefail

# ANSI color escape codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Logging helpers
log_info()    { printf "${BLUE}[INFO]${NC} %s\n" "$1"; }
log_success() { printf "${GREEN}[SUCCESS]${NC} %s\n" "$1"; }
log_warn()    { printf "${YELLOW}[WARN]${NC} %s\n" "$1"; }
log_error()   { printf "${RED}[ERROR]${NC} %s\n" "$1" >&2; }

REPO_DIR="$HOME/antigravity-config"
AGENTS_SRC="$HOME/.agents/AGENTS.md"
SKILLS_SRC="$HOME/.agents/skills"

# Verify repo folder exists
if [ ! -d "$REPO_DIR" ]; then
    log_error "Repository directory not found at $REPO_DIR"
    exit 1
fi

log_info "Syncing local modifications back to repository..."

# Copy AGENTS.md back to repo
if [ -f "$AGENTS_SRC" ]; then
    cp "$AGENTS_SRC" "$REPO_DIR/AGENTS.md"
    log_success "Synchronized AGENTS.md back to repository root."
else
    log_warn "Local AGENTS.md rules not found at $AGENTS_SRC"
fi

# Archive skills folder to a single compressed tarball
if [ -d "$SKILLS_SRC" ]; then
    log_info "Archiving custom skills to skills.tar.gz..."
    tar -czf "$REPO_DIR/skills.tar.gz" -C "$HOME/.agents" skills
    log_success "Synchronized custom skills back to repository as skills.tar.gz"
fi

# Commit and Push
cd "$REPO_DIR"
git add -A

if git diff --staged --quiet; then
    log_info "No changes detected. Repository is already up-to-date."
    exit 0
fi

COMMIT_MSG="auto-antigravity: $(date '+%Y-%m-%d %H:%M')"
log_info "Committing changes with message: '$COMMIT_MSG'..."
git commit -m "$COMMIT_MSG"

log_info "Pushing updates to origin..."
if git push; then
    log_success "Successfully synchronized configuration to GitHub!"
else
    log_error "Failed to push updates to GitHub. Please check network connection/permissions."
    exit 1
fi
