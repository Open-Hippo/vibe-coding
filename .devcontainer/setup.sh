#!/usr/bin/env bash
# Devcontainer toolchain bootstrap for the prepaid-v2 sandbox mission (v2_specifications/v1_v2_migration_plan.md §5.2).
#
# The base image (mcr.microsoft.com/devcontainers/python:2-3.12-bookworm) ships Python 3.12,
# pip, pipx, git and zsh — but NOT Node/npx, the Claude Code CLI, or the supabase/stripe CLIs.
# This script installs the rest. It is idempotent: every step is guarded so re-running (e.g.
# after a rebuild) is cheap and safe. Wired from devcontainer.json via postCreateCommand.

set -euo pipefail

# Keep the whole bootstrap non-interactive — this runs unattended at container create,
# so nothing may stop to ask for confirmation.
export DEBIAN_FRONTEND=noninteractive   # apt never prompts (tzdata, "Do you want to continue?")
export npm_config_yes=true              # npx auto-confirms package fetches ("Ok to proceed?")

NODE_MAJOR=22
ARCH="$(dpkg --print-architecture)"   # amd64 | arm64 — host may be Apple Silicon
log() { printf '\n\033[1;36m[setup]\033[0m %s\n' "$*"; }

# --- Node.js (gives us npx; needed for claude, playwright, vite/console) -----------------
if ! command -v node >/dev/null 2>&1; then
  log "Installing Node.js ${NODE_MAJOR}.x (NodeSource)"
  curl -fsSL "https://deb.nodesource.com/setup_${NODE_MAJOR}.x" | sudo -E bash -
  sudo apt-get install -y nodejs
else
  log "Node already present: $(node --version)"
fi

# Use a user-owned global npm prefix so `npm i -g` and Claude Code self-update need no sudo.
NPM_GLOBAL="${HOME}/.npm-global"
mkdir -p "${NPM_GLOBAL}"
npm config set prefix "${NPM_GLOBAL}"
export PATH="${NPM_GLOBAL}/bin:${HOME}/.local/bin:${PATH}"

# The export above only lives for THIS script. Persist the toolchain PATH into the shell
# startup files so every future terminal (login and non-login, bash and zsh) can find
# claude/uv/playwright. Uses runtime $HOME so it expands correctly (unlike remoteEnv's
# ${containerEnv:HOME}, which can resolve empty). Guarded so re-runs don't duplicate the line.
PATH_LINE='export PATH="$HOME/.npm-global/bin:$HOME/.local/bin:$PATH"'
for rc in "${HOME}/.bashrc" "${HOME}/.zshrc" "${HOME}/.profile"; do
  touch "${rc}"
  grep -qF "${PATH_LINE}" "${rc}" || printf '\n%s\n' "${PATH_LINE}" >> "${rc}"
done

# --- Claude Code CLI ---------------------------------------------------------------------
if ! command -v claude >/dev/null 2>&1; then
  log "Installing Claude Code CLI"
  npm install -g @anthropic-ai/claude-code
else
  log "claude already present: $(claude --version 2>/dev/null || echo '?')"
fi

# --- opencode (alternative AI coding agent CLI) ------------------------------------------
# Installs into the user-owned npm-global prefix set above, so it lands on PATH with no sudo
# and self-updates cleanly. Binary is `opencode`; the npm package is `opencode-ai`.
if ! command -v opencode >/dev/null 2>&1; then
  log "Installing opencode CLI"
  npm install -g opencode-ai
else
  log "opencode already present: $(opencode --version 2>/dev/null || echo '?')"
fi

# --- uv (repo uses `uv run` for python/pytest) -------------------------------------------
if ! command -v uv >/dev/null 2>&1; then
  log "Installing uv"
  curl -LsSf https://astral.sh/uv/install.sh | sh
else
  log "uv already present: $(uv --version)"
fi

# --- Playwright + headless Chromium (drives the console for visual diffs) ----------------
if ! npm ls -g playwright >/dev/null 2>&1; then
  log "Installing Playwright + Chromium"
  npm install -g playwright
  # --yes so npx never stops to ask "Ok to proceed?" during the unattended build.
  # `sudo env PATH=...` keeps the user's npm-global bin visible to root, so npx finds the
  # just-installed playwright instead of trying to fetch it (which is what triggers the prompt).
  sudo env "PATH=${PATH}" npx --yes playwright install-deps chromium
  npx --yes playwright install chromium
else
  log "Playwright already present"
fi
