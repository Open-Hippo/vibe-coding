#!/usr/bin/env bash
# Container startup for the coding box. Runtime-only: print a short banner proving the baked
# toolchain resolves, then `exec` the real command (CMD — `sleep infinity` by default, or
# whatever you pass to `docker run`/`compose run`).
#
# Wired as the image ENTRYPOINT in exec form, so signals (docker stop) pass straight through
# to PID 1's child instead of being swallowed by a wrapper shell.
set -uo pipefail

log() { printf '\033[1;36m[box]\033[0m %s\n' "$*"; }

log "node $(node --version 2>/dev/null) · claude $(claude --version 2>/dev/null | awk '{print $1}') · opencode $(opencode --version 2>/dev/null) · uv $(uv --version 2>/dev/null | awk '{print $2}')"
log "ready — exec in and run: screen -S work  then  claude   (or an overnight  opencode run …)"

exec "$@"
